from __future__ import annotations

import json
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path
from functools import lru_cache

import numpy as np
from PIL import Image

from api.settings import settings


class ModelConfigurationError(RuntimeError):
    pass


@dataclass(slots=True)
class ClassLabel:
    class_index: int
    label: str
    species_id: int | None = None


@dataclass(slots=True)
class Prediction:
    class_index: int
    label: str
    confidence: float


class ONNXImageClassifier:
    def __init__(self, model_path: str, labels_path: str, image_size: int) -> None:
        try:
            import onnxruntime as ort
        except ImportError as exc:
            raise ModelConfigurationError("onnxruntime n'est pas installé.") from exc

        model_file = Path(model_path)
        if not model_path or not model_file.exists():
            raise ModelConfigurationError(f"Modèle introuvable: {model_path}")

        self.image_size = image_size
        self.session = ort.InferenceSession(str(model_file), providers=["CPUExecutionProvider"])
        self.input_name = self.session.get_inputs()[0].name
        self.output_name = self.session.get_outputs()[0].name
        self.input_shape = self.session.get_inputs()[0].shape
        self.labels = self._load_labels(labels_path)

    def _load_labels(self, labels_path: str) -> list[ClassLabel]:
        path = Path(labels_path)
        if not labels_path or not path.exists():
            raise ModelConfigurationError(f"Fichier de labels introuvable: {labels_path}")

        payload = json.loads(path.read_text(encoding="utf-8"))
        labels: list[ClassLabel] = []

        if not isinstance(payload, list) or not payload:
            raise ModelConfigurationError("CLASS_NAMES_PATH doit pointer vers un JSON de type liste non vide.")

        for idx, entry in enumerate(payload):
            if isinstance(entry, str):
                labels.append(ClassLabel(class_index=idx, label=entry))
            elif isinstance(entry, dict):
                labels.append(
                    ClassLabel(
                        class_index=int(entry.get("class_index", idx)),
                        label=str(entry["label"]),
                        species_id=int(entry["species_id"]) if entry.get("species_id") is not None else None,
                    )
                )
            else:
                raise ModelConfigurationError("Le JSON des labels doit contenir des chaînes ou des objets.")

        labels.sort(key=lambda x: x.class_index)
        return labels

    def preprocess(self, image_bytes: bytes) -> np.ndarray:
        with Image.open(BytesIO(image_bytes)) as image:
            image = image.convert("RGB")
            image = image.resize((self.image_size, self.image_size))
            array = np.asarray(image, dtype=np.float32) / 255.0

        mean = np.asarray(settings.image_mean_values, dtype=np.float32)
        std = np.asarray(settings.image_std_values, dtype=np.float32)
        array = (array - mean) / std

        second_dim = self.input_shape[1] if len(self.input_shape) > 1 else None
        if second_dim == 3:
            array = np.transpose(array, (2, 0, 1))

        array = np.expand_dims(array, axis=0).astype(np.float32)
        return array

    def predict(self, image_bytes: bytes, top_k: int) -> list[Prediction]:
        input_tensor = self.preprocess(image_bytes)
        raw = self.session.run([self.output_name], {self.input_name: input_tensor})[0]
        logits = np.asarray(raw)

        if logits.ndim == 2:
            logits = logits[0]
        elif logits.ndim > 2:
            logits = logits.reshape(-1)

        probabilities = softmax_if_needed(logits)
        top_indices = np.argsort(probabilities)[::-1][:top_k]

        results: list[Prediction] = []
        for idx in top_indices:
            idx = int(idx)
            meta = self.labels[idx] if idx < len(self.labels) else ClassLabel(class_index=idx, label=str(idx))
            results.append(
                Prediction(
                    class_index=idx,
                    label=meta.label,
                    confidence=float(probabilities[idx]),
                )
            )
        return results

    def get_species_id(self, class_index: int) -> int | None:
        if class_index < 0 or class_index >= len(self.labels):
            return None
        return self.labels[class_index].species_id


@lru_cache(maxsize=1)
def get_classifier() -> ONNXImageClassifier:
    backend = settings.model_backend.strip().lower()
    if backend != "onnx":
        raise ModelConfigurationError(
            f"Backend '{settings.model_backend}' non supporté actuellement. Exporte ton modèle en ONNX."
        )

    return ONNXImageClassifier(
        model_path=settings.model_path,
        labels_path=settings.class_names_path,
        image_size=settings.inference_image_size,
    )


def softmax_if_needed(values: np.ndarray) -> np.ndarray:
    values = values.astype(np.float32)
    if np.all(values >= 0.0):
        total = float(values.sum())
        if 0.99 <= total <= 1.01:
            return values
    shifted = values - np.max(values)
    exps = np.exp(shifted)
    return exps / np.sum(exps)
