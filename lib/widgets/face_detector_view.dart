import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:magang_absen/locator.dart';
import 'package:magang_absen/painter/face_detector_painter.dart';
import 'package:magang_absen/services/face_detector_service.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({
    super.key,
    this.onDetection,
  });

  final void Function(CameraImage, List<Face>, Future<XFile> Function())?
      onDetection;

  @override
  State<FaceDetectorView> createState() => _FaceDetectorState();
}

class _FaceDetectorState extends State<FaceDetectorView> {
  final FaceDetectorService _detectorService = locator();
  CameraController? _cameraController;
  bool _cameraReady = false;
  List<CameraDescription> _cameras = [];
  CameraDescription? _camera;
  bool _showSettings = false;

  @override
  void initState() {
    debugPrint("FaceDetectorView initState");
    availableCameras().then((cameras) {
      if (mounted) {
        _cameras = cameras;
        _startLiveFeed(CameraLensDirection.front);
      }
    });
    _detectorService.initialize();
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("FaceDetectorView dispose");
    _detectorService.dispose();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  void _onStream(CameraImage image) {
    // print("_onStream");
    if (_detectorService.isProcessing) {
      // debugPrint("_detectorService is processingImage");
      return;
    }
    _detectorService.detecFacesFromImage(image, _cameraController!);
  }

  void _startDetecting() {
    setState(() {});
    if (widget.onDetection != null) {
      _detectorService.addListener(() {
        widget.onDetection!(
          _detectorService.cameraImage!,
          _detectorService.faces,
          _cameraController!.takePicture,
        );
      });
    }
  }

  Future _startLiveFeed(CameraLensDirection lensDirection) async {
    _camera = _cameras
        .firstWhere((element) => element.lensDirection == lensDirection);
    _cameraController = CameraController(
      _camera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {
        _cameraReady = true;
      });
    }
    _cameraController!.startImageStream(_onStream);
    _startDetecting();
  }

  Future<void> _stopLiveFeed() async {
    if (mounted) {
      setState(() {
        _cameraReady = false;
      });
    }
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
  }

  void _toggleCameras() async {
    await _stopLiveFeed();
    await _startLiveFeed(_camera!.lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front);
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Center(
          child: CameraPreview(
            _cameraController!,
            child: AnimatedBuilder(
              animation: _detectorService,
              builder: (context, _) {
                return CustomPaint(
                  painter: FaceDetectorPainter(
                    _detectorService.faces,
                    _cameraController!.value.previewSize!,
                    rotationIntToImageRotation(_camera!.sensorOrientation),
                    _camera!.lensDirection,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 10,
          child: SizedBox.square(
            dimension: 55,
            child: FloatingActionButton(
              heroTag: Object(),
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back_ios_outlined),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 10 * 2 + 55,
          child: SizedBox.square(
            dimension: 55,
            child: FloatingActionButton(
              heroTag: Object(),
              onPressed: () {
                setState(() {
                  _showSettings = !_showSettings;
                });
              },
              child: const Icon(Icons.settings),
            ),
          ),
        ),
        ..._createSettings(),
      ],
    );
  }

  List<Widget> _createSettings() {
    if (!_showSettings) return [];
    return [
      Positioned(
        bottom: 10,
        right: 10,
        child: FloatingActionButton(
          onPressed: _toggleCameras,
          child: const Icon(
            Icons.rotate_left,
            color: Colors.blueAccent,
          ),
        ),
      )
    ];
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
}
