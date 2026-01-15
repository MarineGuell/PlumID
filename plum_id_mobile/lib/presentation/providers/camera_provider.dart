import 'package:camera/camera.dart' as camera_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<camera_pkg.CameraDescription>> getAvailableCameras(Ref ref) async {
  return await camera_pkg.availableCameras();
}

@riverpod
Future<camera_pkg.CameraDescription> backCamera(Ref ref) async {
  final cameras = await ref.watch(getAvailableCamerasProvider.future);

  // On retourne la caméria arriére du téléphone
  return cameras.firstWhere(
    (camera) => camera.lensDirection == camera_pkg.CameraLensDirection.back,
    orElse: () => cameras.first,
  );
}
