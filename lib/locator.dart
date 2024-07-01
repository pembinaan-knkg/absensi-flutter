import 'package:get_it/get_it.dart';
import 'package:magang_absen/services/api_services.dart';
import 'package:magang_absen/services/camera_services.dart';
import 'package:magang_absen/services/face_detector_service.dart';
import 'package:magang_absen/services/location_services.dart';
import 'package:magang_absen/services/ml_services.dart';

final locator = GetIt.instance;

void setupServices() {
  locator.registerSingleton(CameraService()..initialize());
  locator.registerSingleton(FaceDetectorService());
  locator.registerSingleton(MLServices()..initialize());
  locator.registerSingleton(LocationServices()..init());
  locator.registerSingleton(ApiServices());
  // locator.registerLazySingleton(() => CameraService());
  // locator.registerLazySingleton(() => FaceDetectorService());
  // locator.registerLazySingleton(() => MLServices());
  // locator.registerLazySingleton(() => LocationServices());

  locator.allReadySync();
}
