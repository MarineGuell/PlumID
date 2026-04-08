import csv
import os

import cv2 as cv
import numpy as np
from PIL import Image
from ultralytics import SAM

# Base directory for preprocessed outputs (relative to project root)
_BASE_DIR = os.path.join(os.path.dirname(__file__), "preprocessed")


def _subdir(name):
    """Return the absolute path to a preprocessed sub-directory."""
    path = os.path.join(_BASE_DIR, name)
    os.makedirs(path, exist_ok=True)
    return path


# ─────────────────────────────────────────────────────────────────────────────
# MASK CLEANING
# ─────────────────────────────────────────────────────────────────────────────

def clean_mask(mask, close_kernel=5, min_component_area=500):
    """Morphological clean-up + remove tiny connected components."""
    if close_kernel and close_kernel > 0:
        k = cv.getStructuringElement(cv.MORPH_ELLIPSE, (close_kernel, close_kernel))
        mask = cv.morphologyEx(mask.astype(np.uint8), cv.MORPH_CLOSE, k)

    num_labels, labels, stats, _ = cv.connectedComponentsWithStats(
        mask.astype(np.uint8), connectivity=8)
    cleaned = np.zeros_like(mask, dtype=np.uint8)
    for lab in range(1, num_labels):
        if stats[lab, cv.CC_STAT_AREA] >= min_component_area:
            cleaned[labels == lab] = 1
    return cleaned


# ─────────────────────────────────────────────────────────────────────────────
# SHAPE ANALYSIS
# ─────────────────────────────────────────────────────────────────────────────

def analyze_feather_shape(mask, bbox_w, bbox_h):
    """
    Score how feather-like the mask contour looks (0-100).

    - Elongation is a HARD GATE: aspect ratio too low returns 0 immediately.
    - Solidity penalty catches flat solid objects (labels, cards, rulers).
    """
    contours, _ = cv.findContours(
        mask.astype(np.uint8), cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
    if not contours:
        return 0, {}

    main_contour = max(contours, key=cv.contourArea)
    features = {}

    # 1. ELONGATION — hard gate
    aspect_ratio = max(bbox_w, bbox_h) / max(min(bbox_w, bbox_h), 1)
    if 2.0 <= aspect_ratio <= 15.0:
        features['elongation_score'] = 30
    elif 1.5 <= aspect_ratio < 2.0:
        features['elongation_score'] = 15
    elif aspect_ratio > 15.0:
        features['elongation_score'] = 5       # shadow / thread
    else:
        features['elongation_score'] = 0       # too round -> instant fail

    if features['elongation_score'] == 0:
        return 0, {k: 0 for k in [
            'elongation_score', 'tapering_score', 'smoothness_score',
            'symmetry_score', 'texture_score', 'solidity_penalty']}

    # 2. TAPERING
    if len(main_contour) >= 5:
        _, (minor_axis, major_axis), _ = cv.fitEllipse(main_contour)
        if major_axis > 0 and minor_axis > 0:
            ea = major_axis / minor_axis
            features['tapering_score'] = 25 if ea >= 1.8 else (15 if ea >= 1.3 else 5)
        else:
            features['tapering_score'] = 0
    else:
        features['tapering_score'] = 0

    # 3. SMOOTHNESS (circularity)
    perimeter = cv.arcLength(main_contour, True)
    area = cv.contourArea(main_contour)
    if perimeter > 0:
        circ = (4 * np.pi * area) / (perimeter ** 2)
        if 0.2 <= circ <= 0.8:
            features['smoothness_score'] = 20
        elif 0.1 <= circ < 0.2:
            features['smoothness_score'] = 10
        elif circ > 0.9:
            features['smoothness_score'] = 0
        else:
            features['smoothness_score'] = 5
    else:
        features['smoothness_score'] = 0

    # 4. SYMMETRY (Hu moments)
    moments = cv.moments(main_contour)
    if moments['m00'] > 0:
        hu = cv.HuMoments(moments).flatten()
        sym = abs(hu[1])
        features['symmetry_score'] = 15 if sym < 0.01 else (10 if sym < 0.1 else 5)
    else:
        features['symmetry_score'] = 0

    # 5. CONVEXITY DEFECTS (barb proxy)
    hull_idx = cv.convexHull(main_contour, returnPoints=False)
    if len(hull_idx) > 3 and len(main_contour) > 3:
        defects = cv.convexityDefects(main_contour, hull_idx)
        if defects is not None:
            n_sig = sum(1 for i in range(defects.shape[0])
                        if defects[i, 0][3] / 256.0 > 5)
            features['texture_score'] = 10 if n_sig <= 8 else (5 if n_sig <= 15 else 0)
        else:
            features['texture_score'] = 10
    else:
        features['texture_score'] = 5

    # 6. SOLIDITY PENALTY
    # Very solid + only mildly elongated = ruler, stick, label, card.
    hull_poly = cv.convexHull(main_contour)
    hull_area = cv.contourArea(hull_poly)
    solidity = float(mask.sum()) / hull_area if hull_area > 0 else 1.0
    features['solidity_penalty'] = -25 if (solidity > 0.92 and aspect_ratio < 2.5) else 0

    return max(0, sum(features.values())), features


# ─────────────────────────────────────────────────────────────────────────────
# TEXTURE / COLOUR ANALYSIS
# ─────────────────────────────────────────────────────────────────────────────

def analyze_feather_texture(cropped_bgr):
    """
    Inspect pixel content of the cropped+masked region.
    Returns (texture_score 0-100, breakdown dict).

    Detectors
    ---------
    1. High colour saturation    -> synthetic/painted object (green ruler ...)
    2. Uniform saturated hue     -> solid-colour manufactured object
    3. Flat brightness           -> blank surface (white card, plastic)
    4. Low Laplacian variance    -> smooth surface (ruler face, card stock)
    5. Dense regular edges       -> printed tick-marks / ruler text
    6. Skin colour via YCrCb     -> hands and fingers
    7. Near-white blank surface  -> white paper / labels / cards
    """
    scores = {}

    mask_px = np.any(cropped_bgr > 10, axis=2)
    n_px = int(mask_px.sum())
    if n_px == 0:
        return 0, {}

    hsv  = cv.cvtColor(cropped_bgr, cv.COLOR_BGR2HSV)
    s_ch = hsv[:, :, 1][mask_px]
    v_ch = hsv[:, :, 2][mask_px]
    h_ch = hsv[:, :, 0][mask_px]
    gray = cv.cvtColor(cropped_bgr, cv.COLOR_BGR2GRAY)

    mean_sat = float(s_ch.mean())
    mean_val = float(v_ch.mean())

    # 1. Saturation
    if mean_sat > 120:
        scores['sat_penalty'] = -40
    elif mean_sat > 80:
        scores['sat_penalty'] = -15
    else:
        scores['sat_penalty'] = 0

    # 2. Hue uniformity
    hue_std = float(h_ch.std())
    if hue_std < 5 and mean_sat > 60:
        scores['hue_uniformity_penalty'] = -30
    elif hue_std < 8:
        scores['hue_uniformity_penalty'] = -10
    else:
        scores['hue_uniformity_penalty'] = 0

    # 3. Brightness flatness
    val_std = float(v_ch.std())
    if val_std < 15:
        scores['brightness_penalty'] = -20
    elif val_std < 25:
        scores['brightness_penalty'] = -10
    else:
        scores['brightness_penalty'] = 0

    # 4. Laplacian variance (masked pixels only)
    lap = cv.Laplacian(gray, cv.CV_64F)
    lap_var = float(lap[mask_px].var())
    if lap_var < 50:
        scores['smoothness_penalty'] = -25
    elif lap_var < 150:
        scores['smoothness_penalty'] = -10
    else:
        scores['smoothness_penalty'] = 0

    # 5. Edge density
    edges = cv.Canny(gray, 50, 150)
    edge_density = float(edges[mask_px].mean())
    if edge_density > 30:
        scores['edge_density_penalty'] = -30
    elif edge_density > 15:
        scores['edge_density_penalty'] = -10
    else:
        scores['edge_density_penalty'] = 0

    # 6. Skin colour (YCrCb)
    ycrcb = cv.cvtColor(cropped_bgr, cv.COLOR_BGR2YCrCb)
    cr_ch = ycrcb[:, :, 1][mask_px]
    cb_ch = ycrcb[:, :, 2][mask_px]
    skin_px = ((cr_ch >= 133) & (cr_ch <= 173) &
               (cb_ch >= 77)  & (cb_ch <= 127))
    skin_ratio = float(skin_px.sum()) / n_px
    if skin_ratio > 0.35:
        scores['skin_penalty'] = -60
    elif skin_ratio > 0.20:
        scores['skin_penalty'] = -30
    else:
        scores['skin_penalty'] = 0

    # 7. Near-white blank surface
    if mean_val > 210 and mean_sat < 20:
        scores['white_surface_penalty'] = -50
    elif mean_val > 190 and mean_sat < 30:
        scores['white_surface_penalty'] = -30
    elif mean_val > 170 and mean_sat < 25:
        scores['white_surface_penalty'] = -15
    else:
        scores['white_surface_penalty'] = 0

    return max(0, 100 + sum(scores.values())), scores


# ─────────────────────────────────────────────────────────────────────────────
# COMBINED QUALITY SCORE
# ─────────────────────────────────────────────────────────────────────────────

def compute_mask_quality_score(mask, bbox_w, bbox_h, mask_area, bbox_area, w, h):
    """
    Returns (total_score 0-200, score_breakdown dict).
    Part A: general mask quality (0-100).
    Part B: feather shape score  (0-100).
    """
    scores = {}

    mask_to_bbox = mask_area / bbox_area if bbox_area > 0 else 0
    if mask_to_bbox >= 0.40:
        scores['compactness'] = 25
    elif mask_to_bbox >= 0.30:
        scores['compactness'] = 20
    elif mask_to_bbox >= 0.20:
        scores['compactness'] = 10
    else:
        scores['compactness'] = 0

    contours, _ = cv.findContours(
        mask.astype(np.uint8), cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
    n = len(contours)
    scores['contour'] = 20 if n == 1 else (15 if n <= 3 else (8 if n <= 5 else 0))

    if contours:
        hull = cv.convexHull(max(contours, key=cv.contourArea))
        hull_area = cv.contourArea(hull)
        solidity = mask_area / hull_area if hull_area > 0 else 0
        scores['solidity'] = (20 if solidity >= 0.70 else
                              15 if solidity >= 0.50 else
                              8  if solidity >= 0.35 else 0)
    else:
        scores['solidity'] = 0

    mask_to_image = mask_area / (w * h)
    scores['size'] = (30 if mask_to_image >= 0.10 else
                      25 if mask_to_image >= 0.05 else
                      15 if mask_to_image >= 0.03 else
                      5  if mask_to_image >= 0.015 else 0)

    scores['size_range'] = (15 if 0.03 <= mask_to_image <= 0.75 else
                            10 if 0.015 <= mask_to_image <= 0.85 else
                            0  if mask_to_image > 0.90 else 5)

    general_quality = sum(scores.values())

    feather_likelihood, feather_features = analyze_feather_shape(mask, bbox_w, bbox_h)
    scores.update(feather_features)

    total_score = general_quality + feather_likelihood
    scores['general_quality']    = general_quality
    scores['feather_likelihood'] = feather_likelihood

    return total_score, scores


# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

def _crop_mask(image, mask, x1, y1, x2, y2):
    """Apply binary mask and crop to bounding box."""
    mask_3ch = np.stack([mask] * 3, axis=-1)
    return (image * mask_3ch)[y1:y2 + 1, x1:x2 + 1]


_CSV_FIELDNAMES = [
    "image_path", "mask_index", "mask_area", "bbox_area",
    "mask_to_bbox", "mask_to_image", "black_ratio", "bbox_aspect",
    "total_score", "general_quality", "feather_likelihood", "texture_score",
    "elongation", "tapering", "smoothness", "symmetry",
    "texture_shape", "solidity_penalty",
    "tex_sat", "tex_hue", "tex_brightness", "tex_smoothness",
    "tex_edges", "tex_skin", "tex_white_surface",
    "accepted", "reject_reason", "rank", "size_check_passed",
]


def _already_processed(output_dir):
    """
    Scan output_dir for files matching '*_mask*_crop.png' and return the set
    of source base-names that have already been processed.

    Example: 'abc123_600_mask0_crop.png' -> base-name 'abc123_600'

    This works because accepted crop filenames are always:
        {source_base_name}_mask{N}_crop.png
    so splitting on '_mask' and taking everything before the first occurrence
    recovers the original image stem reliably.
    """
    done = set()
    if not os.path.isdir(output_dir):
        return done
    for f in os.scandir(output_dir):
        if f.name.endswith("_crop.png") and "_mask" in f.name:
            # Split on the LAST occurrence of '_mask' that is followed by digits
            # to be robust against base-names that themselves contain '_mask'.
            stem = f.name[:-len("_crop.png")]  # strip suffix
            # Walk backwards to find '_mask<digits>' pattern
            idx = stem.rfind("_mask")
            if idx != -1:
                candidate_base = stem[:idx]
                done.add(candidate_base)
    return done


# ─────────────────────────────────────────────────────────────────────────────
# SEGMENTATION  (with resume support)
# ─────────────────────────────────────────────────────────────────────────────

def segmentation(input_dir="img",
                 output_dir=None,
                 sam_weights_path="sam3.pt",
                 save_all_masks=False,
                 close_kernel=5,
                 min_component_area=500,
                 stats_csv_path=None,
                 # Shape gates
                 min_quality_score=120,
                 min_feather_likelihood=70,
                 # Texture / colour gate
                 min_texture_score=40,
                 # Size gates
                 min_size_ratio=0.020,
                 max_size_ratio=0.80,
                 max_masks_per_image=4,
                 verbose=True):
    """
    Feather segmentation pipeline with resume-from-checkpoint support.

    If the pipeline is interrupted and restarted, it compares the source
    images in input_dir against the crops already written to output_dir.
    Any source image whose base-name already appears in an output crop
    filename is skipped — only the remaining images are segmented.

    The CSV is opened in APPEND mode when resuming so previous results
    are preserved and new rows are added after them.

    Gates (applied in order):
      1. SIZE        : 2% – 80% of image area
      2. SHAPE       : geometry quality + feather-shape score
      3. TEXTURE/COL : pixel-level content (skin, white surface, rulers …)
    """
    if output_dir is None:
        output_dir = _subdir("segmentation")

    if stats_csv_path is None:
        base_dir = os.path.dirname(_subdir("segmentation"))
        stats_csv_path = os.path.join(base_dir, "segmentation_stats.csv")

    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(os.path.dirname(stats_csv_path), exist_ok=True)

    # ── Resume: find which source images are already done ────────────────────
    already_done = _already_processed(output_dir)

    # CSV: write header only when starting fresh; append when resuming
    csv_is_new = not os.path.isfile(stats_csv_path) or os.path.getsize(stats_csv_path) == 0
    csv_file   = open(stats_csv_path, "a", newline="")
    csv_writer = csv.DictWriter(csv_file, fieldnames=_CSV_FIELDNAMES)
    if csv_is_new:
        csv_writer.writeheader()

    if verbose and already_done:
        print(f"[resume] {len(already_done)} image(s) already processed — skipping them.")

    # ── Load model ────────────────────────────────────────────────────────────
    model = SAM(sam_weights_path)
    try:
        model.to("cuda")
    except Exception:
        print("GPU not available, using CPU")

    saved     = []
    img_index = 0

    try:
        for entry in sorted(os.scandir(input_dir), key=lambda e: e.name):
            if not entry.is_file():
                continue

            image_path = entry.path
            base_name  = os.path.splitext(os.path.basename(image_path))[0]

            # ── RESUME CHECK ─────────────────────────────────────────────────
            if base_name in already_done:
                if verbose:
                    print(f"[{img_index}] {base_name}: already processed, skipping")
                img_index += 1
                continue

            image = cv.imread(image_path)
            if image is None:
                if verbose:
                    print(f"Could not read {image_path}")
                continue

            h, w = image.shape[:2]

            # imgsz=1036 avoids the SAM stride-14 warning
            results = model(image_path, save=False, imgsz=1036)

            if results[0].masks is None:
                if verbose:
                    print(f"[{img_index}] {base_name}: no detections, skipping")
                # Mark as processed so a restart won't attempt it again.
                # We do this by writing a sentinel row to the CSV.
                csv_writer.writerow({f: "" for f in _CSV_FIELDNAMES} | {
                    "image_path":  image_path,
                    "accepted":    False,
                    "reject_reason": "no_detections",
                    "rank":        "skipped",
                })
                csv_file.flush()
                img_index += 1
                continue

            # ── Build mask list ───────────────────────────────────────────────
            image_masks = []
            for mask_i, mask_t in enumerate(results[0].masks.data):
                mask = mask_t.cpu().numpy().astype(np.uint8)
                mask = cv.resize(mask, (w, h), interpolation=cv.INTER_NEAREST)
                mask = clean_mask(mask, close_kernel=close_kernel,
                                  min_component_area=min_component_area)

                ys, xs = np.where(mask == 1)
                if len(xs) == 0 or len(ys) == 0:
                    continue

                x1, x2    = int(xs.min()), int(xs.max())
                y1, y2    = int(ys.min()), int(ys.max())
                bbox_w    = x2 - x1 + 1
                bbox_h    = y2 - y1 + 1
                bbox_area = float(bbox_w * bbox_h)
                mask_area = float(mask.sum())

                quality_score, score_breakdown = compute_mask_quality_score(
                    mask, bbox_w, bbox_h, mask_area, bbox_area, w, h)

                image_masks.append({
                    'mask_i':          mask_i,
                    'mask':            mask,
                    'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2,
                    'mask_area':       mask_area,
                    'bbox_area':       bbox_area,
                    'quality_score':   quality_score,
                    'score_breakdown': score_breakdown,
                })

            # ── Gate 1: Size ──────────────────────────────────────────────────
            valid_masks   = []
            size_rejected = []
            for md in image_masks:
                ratio = md['mask_area'] / (w * h)
                if ratio < min_size_ratio:
                    size_rejected.append(
                        (md, ratio, f"too_small {ratio:.4f} < {min_size_ratio}"))
                elif ratio > max_size_ratio:
                    size_rejected.append(
                        (md, ratio, f"too_large {ratio:.4f} > {max_size_ratio}"))
                else:
                    valid_masks.append(md)

            valid_masks.sort(
                key=lambda x: (x['quality_score'], x['mask_area']), reverse=True)

            # ── Gates 2 & 3: Shape + texture ──────────────────────────────────
            accepted_count   = 0
            quality_rejected = []

            for md in valid_masks:
                ratio         = md['mask_area'] / (w * h)
                total_score   = md['quality_score']
                feather_score = md['score_breakdown'].get('feather_likelihood', 0)
                fname         = f"{base_name}_mask{md['mask_i']}_crop.png"
                out_path      = os.path.join(output_dir, fname)

                if max_masks_per_image is not None and accepted_count >= max_masks_per_image:
                    quality_rejected.append(
                        (md, ratio, total_score, feather_score, 0, {},
                         f"max_limit_reached (already have {max_masks_per_image})"))
                    continue

                reject_reasons = []
                if total_score < min_quality_score:
                    reject_reasons.append(f"quality {total_score:.0f} < {min_quality_score}")
                if feather_score < min_feather_likelihood:
                    reject_reasons.append(
                        f"feather_shape {feather_score:.0f} < {min_feather_likelihood}")

                if reject_reasons:
                    quality_rejected.append(
                        (md, ratio, total_score, feather_score, 0, {},
                         " AND ".join(reject_reasons)))
                    continue

                cropped = _crop_mask(image, md['mask'],
                                     md['x1'], md['y1'], md['x2'], md['y2'])
                texture_score, texture_breakdown = analyze_feather_texture(cropped)

                if texture_score < min_texture_score:
                    tex_detail = ", ".join(
                        f"{k}={v}" for k, v in texture_breakdown.items() if v != 0)
                    quality_rejected.append(
                        (md, ratio, total_score, feather_score,
                         texture_score, texture_breakdown,
                         f"texture {texture_score:.0f} < {min_texture_score} ({tex_detail})"))
                    if save_all_masks:
                        cv.imwrite(out_path, cropped)
                    continue

                # APPROVED
                cv.imwrite(out_path, cropped)
                saved.append(out_path)
                accepted_count += 1

                sb  = md['score_breakdown']
                row = {
                    "image_path":         image_path,
                    "mask_index":         md['mask_i'],
                    "mask_area":          int(md['mask_area']),
                    "bbox_area":          int(md['bbox_area']),
                    "mask_to_bbox":       md['mask_area'] / md['bbox_area'],
                    "mask_to_image":      ratio,
                    "black_ratio":        (md['bbox_area'] - md['mask_area']) / md['bbox_area'],
                    "bbox_aspect":        (md['x2'] - md['x1'] + 1) / (md['y2'] - md['y1'] + 1),
                    "total_score":        total_score,
                    "general_quality":    sb.get('general_quality', 0),
                    "feather_likelihood": feather_score,
                    "texture_score":      texture_score,
                    "elongation":         sb.get('elongation_score', 0),
                    "tapering":           sb.get('tapering_score', 0),
                    "smoothness":         sb.get('smoothness_score', 0),
                    "symmetry":           sb.get('symmetry_score', 0),
                    "texture_shape":      sb.get('texture_score', 0),
                    "solidity_penalty":   sb.get('solidity_penalty', 0),
                    "tex_sat":            texture_breakdown.get('sat_penalty', 0),
                    "tex_hue":            texture_breakdown.get('hue_uniformity_penalty', 0),
                    "tex_brightness":     texture_breakdown.get('brightness_penalty', 0),
                    "tex_smoothness":     texture_breakdown.get('smoothness_penalty', 0),
                    "tex_edges":          texture_breakdown.get('edge_density_penalty', 0),
                    "tex_skin":           texture_breakdown.get('skin_penalty', 0),
                    "tex_white_surface":  texture_breakdown.get('white_surface_penalty', 0),
                    "accepted":           True,
                    "reject_reason":      "",
                    "rank":               accepted_count,
                    "size_check_passed":  True,
                }
                csv_writer.writerow(row)

                if verbose:
                    print(f"[{img_index}] {base_name} mask#{md['mask_i']}: "
                          f"total={total_score:.0f}/200 "
                          f"(quality={sb.get('general_quality', 0):.0f} "
                          f"+ feather={feather_score:.0f} "
                          f"+ texture={texture_score:.0f}) "
                          f"size={ratio:.4f} -> ACCEPT (#{accepted_count})")

            # ── Log quality/texture-rejected ──────────────────────────────────
            for (md, ratio, total_score, feather_score,
                 texture_score, texture_breakdown, reason) in quality_rejected:

                if save_all_masks:
                    fname    = f"{base_name}_mask{md['mask_i']}_crop.png"
                    out_path = os.path.join(output_dir, fname)
                    cropped  = _crop_mask(image, md['mask'],
                                          md['x1'], md['y1'], md['x2'], md['y2'])
                    cv.imwrite(out_path, cropped)

                sb  = md['score_breakdown']
                row = {
                    "image_path":         image_path,
                    "mask_index":         md['mask_i'],
                    "mask_area":          int(md['mask_area']),
                    "bbox_area":          int(md['bbox_area']),
                    "mask_to_bbox":       md['mask_area'] / md['bbox_area'],
                    "mask_to_image":      ratio,
                    "black_ratio":        (md['bbox_area'] - md['mask_area']) / md['bbox_area'],
                    "bbox_aspect":        (md['x2'] - md['x1'] + 1) / (md['y2'] - md['y1'] + 1),
                    "total_score":        total_score,
                    "general_quality":    sb.get('general_quality', 0),
                    "feather_likelihood": feather_score,
                    "texture_score":      texture_score,
                    "elongation":         sb.get('elongation_score', 0),
                    "tapering":           sb.get('tapering_score', 0),
                    "smoothness":         sb.get('smoothness_score', 0),
                    "symmetry":           sb.get('symmetry_score', 0),
                    "texture_shape":      sb.get('texture_score', 0),
                    "solidity_penalty":   sb.get('solidity_penalty', 0),
                    "tex_sat":            texture_breakdown.get('sat_penalty', 0),
                    "tex_hue":            texture_breakdown.get('hue_uniformity_penalty', 0),
                    "tex_brightness":     texture_breakdown.get('brightness_penalty', 0),
                    "tex_smoothness":     texture_breakdown.get('smoothness_penalty', 0),
                    "tex_edges":          texture_breakdown.get('edge_density_penalty', 0),
                    "tex_skin":           texture_breakdown.get('skin_penalty', 0),
                    "tex_white_surface":  texture_breakdown.get('white_surface_penalty', 0),
                    "accepted":           False,
                    "reject_reason":      reason,
                    "rank":               "rejected",
                    "size_check_passed":  True,
                }
                csv_writer.writerow(row)

                if verbose:
                    print(f"[{img_index}] {base_name} mask#{md['mask_i']}: "
                          f"total={total_score:.0f}/200 "
                          f"(quality={sb.get('general_quality', 0):.0f} "
                          f"+ feather={feather_score:.0f} "
                          f"+ texture={texture_score:.0f}) "
                          f"size={ratio:.4f} -> REJECT: {reason}")

            # ── Log size-rejected ─────────────────────────────────────────────
            for md, ratio, reason in size_rejected:
                if save_all_masks:
                    fname    = f"{base_name}_mask{md['mask_i']}_crop.png"
                    out_path = os.path.join(output_dir, fname)
                    cropped  = _crop_mask(image, md['mask'],
                                          md['x1'], md['y1'], md['x2'], md['y2'])
                    cv.imwrite(out_path, cropped)

                sb            = md['score_breakdown']
                total_score   = md['quality_score']
                feather_score = sb.get('feather_likelihood', 0)
                row = {
                    "image_path":         image_path,
                    "mask_index":         md['mask_i'],
                    "mask_area":          int(md['mask_area']),
                    "bbox_area":          int(md['bbox_area']),
                    "mask_to_bbox":       md['mask_area'] / md['bbox_area'],
                    "mask_to_image":      ratio,
                    "black_ratio":        (md['bbox_area'] - md['mask_area']) / md['bbox_area'],
                    "bbox_aspect":        (md['x2'] - md['x1'] + 1) / (md['y2'] - md['y1'] + 1),
                    "total_score":        total_score,
                    "general_quality":    sb.get('general_quality', 0),
                    "feather_likelihood": feather_score,
                    "texture_score":      0,
                    "elongation":         sb.get('elongation_score', 0),
                    "tapering":           sb.get('tapering_score', 0),
                    "smoothness":         sb.get('smoothness_score', 0),
                    "symmetry":           sb.get('symmetry_score', 0),
                    "texture_shape":      sb.get('texture_score', 0),
                    "solidity_penalty":   sb.get('solidity_penalty', 0),
                    "tex_sat": 0, "tex_hue": 0, "tex_brightness": 0,
                    "tex_smoothness": 0, "tex_edges": 0,
                    "tex_skin": 0, "tex_white_surface": 0,
                    "accepted":           False,
                    "reject_reason":      reason,
                    "rank":               "rejected",
                    "size_check_passed":  False,
                }
                csv_writer.writerow(row)

                if verbose:
                    print(f"[{img_index}] {base_name} mask#{md['mask_i']}: "
                          f"size={ratio:.4f} -> REJECT (size): {reason}")

            # Flush after every image so a crash doesn't lose the last rows
            csv_file.flush()

            if verbose and accepted_count > 0:
                print(f"  -> Image {img_index}: accepted {accepted_count} feather(s)")

            img_index += 1

    finally:
        # Always close the CSV, even on Ctrl-C or crash
        csv_file.close()

    if verbose:
        total_in_dir = sum(
            1 for f in os.scandir(output_dir)
            if f.name.endswith("_crop.png"))
        print(f"\n{'=' * 60}")
        print(f"This run : {len(saved):>4} new crops saved")
        print(f"Total in output dir : {total_in_dir}")
        print(f"CSV      : {stats_csv_path}")
        print(f"{'=' * 60}")

    return saved, stats_csv_path


# ─────────────────────────────────────────────────────────────────────────────
# REMAINING PREPROCESSING STEPS
# ─────────────────────────────────────────────────────────────────────────────

def denoise():
    for index, image in enumerate(os.scandir(_subdir("segmentation"))):
        img = cv.imread(image.path)
        if img is None:
            continue
        dst = cv.fastNlMeansDenoisingColored(img, None, 10, 10, 7, 21)
        cv.imwrite(os.path.join(_subdir("denoise"), f"denoise_{index}.png"), dst)


def enhance_contrast():
    files = sorted(os.scandir(_subdir("denoise")),
                   key=lambda f: int(f.name.split("_")[1].split(".")[0]))
    for index, image in enumerate(files):
        img = cv.imread(image.path)
        lab = cv.cvtColor(img, cv.COLOR_BGR2LAB)
        l, a, b = cv.split(lab)
        clahe = cv.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        lab_enhanced = cv.merge((clahe.apply(l), a, b))
        enhanced = cv.cvtColor(lab_enhanced, cv.COLOR_LAB2BGR)
        cv.imwrite(
            os.path.join(_subdir("contrast"), f"contrast_{index}.png"), enhanced)


def sharpening(strength: float = 0.7):
    files = sorted(os.scandir("preprocessed/contrast"),
                   key=lambda f: int(f.name.split("_")[1].split(".")[0]))
    kernel = np.array([[0.0, -1.0, 0.0],
                       [-1.0,  5.0, -1.0],
                       [0.0, -1.0, 0.0]], dtype=np.float32)
    for index, image in enumerate(files):
        img = cv.imread(image.path)
        cv.imwrite(
            os.path.join("preprocessed/sharpened", f"sharpening_{index}.png"),
            cv.filter2D(img, -1, kernel))


def image_padding():
    files = sorted(os.scandir(_subdir("contrast")),
                   key=lambda f: int(f.name.split("_")[1].split(".")[0]))
    for index, image in enumerate(files):
        img = Image.open(image.path)
        w, h = img.size
        max_side = max(w, h)
        canvas = Image.new("RGB", (max_side, max_side), (0, 0, 0))
        canvas.paste(img, ((max_side - w) // 2, (max_side - h) // 2))
        canvas.resize((224, 224), Image.LANCZOS).save(
            os.path.join(_subdir("padding"), f"padded_{index}.png"))
    print("Padding and resizing complete!")

# ─────────────────────────────────────────────────────────────────────────────
# PIPELINE ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

def data_preprocess(dir, sam_weights_path="sam3.pt"):
    segmentation(
        input_dir=dir,
        sam_weights_path=sam_weights_path,
        save_all_masks=False,
        min_quality_score=120,
        min_feather_likelihood=85,
        min_texture_score=40,
        min_size_ratio=0.015,
        max_size_ratio=0.80,
        max_masks_per_image=10,
        verbose=True,
    )
    denoise()
    enhance_contrast()
    image_padding()