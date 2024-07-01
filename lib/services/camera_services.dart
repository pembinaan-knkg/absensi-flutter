import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:magang_absen/locator.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => _cameraRotation;

  int _rotation = 0;
  int get rotation => _rotation;

  CameraDescription? _cameraDescription;
  CameraDescription? get cameraDescription => _cameraDescription;

  CameraLensDirection? _cameraLensDirection;
  CameraLensDirection? get cameraLensDirection => _cameraLensDirection;

  bool _cameraInitialized = false;
  bool get cameraInitialized =>
      _cameraInitialized &&
      cameraController != null &&
      cameraController!.value.isInitialized;

  String? _imagePath;
  String? get imagePath => _imagePath;

  static CameraService to()=> locator();

  void init() async {}

  Future<void> initialize({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  }) async {
    _cameraInitialized = false;
    _cameraLensDirection = lensDirection;
    CameraDescription description = await getCameraDescription(
      lensDirection: lensDirection,
    );
    await _setupCameraController(description: description);
    _rotation = description.sensorOrientation;
    _cameraRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
    _cameraInitialized = true;
  }

  Future<CameraDescription> getCameraDescription({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  }) async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere(
      (CameraDescription camera) {
        bool found = true;
        found = camera.lensDirection == lensDirection;
        return found;
      },
    );
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    _cameraController = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _cameraController?.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<XFile?> takePicture() async {
    assert(_cameraInitialized, 'Camera controller not initialized');
    XFile? file = await _cameraController?.takePicture();
    _imagePath = file?.path;
    return file;
  }

  Size getImageSize() {
    assert(_cameraInitialized, 'Camera controller not initialized');
    assert(
        _cameraController!.value.previewSize != null, 'Preview size is null');
    return Size(
      _cameraController!.value.previewSize!.width,
      _cameraController!.value.previewSize!.height,
    );
  }

  Future<void> changeCameraDirection(CameraLensDirection direction) async {
    assert(
      cameraInitialized,
      "{changeCameraDirection} camera not initialized",
    );
    _cameraInitialized = false;
    _cameraLensDirection = direction;
    _cameraController!.stopImageStream();
    var cm = await getCameraDescription(lensDirection: direction);
    await _cameraController!.setDescription(cm);
    _cameraInitialized = true;
  }

  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}
