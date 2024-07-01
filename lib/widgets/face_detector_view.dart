import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:magang_absen/locator.dart';
import 'package:magang_absen/painter/face_detector_painter.dart';
import 'package:magang_absen/services/face_detector_service.dart';
import 'package:magang_absen/services/utils.dart';

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
    if (_detectorService.isProcessing) {
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
    _camera = _camera ?? _cameras.first;
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
        ..._createSettings(),
      ],
    );
  }

  List<Widget> _createSettings() {
    if (!_showSettings) {
      return [
        Positioned(
          right: 10,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
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
              ],
            ),
          ),
        ),
      ];
    }

    return [
      Positioned(
        right: 10,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
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
              const Gap(10),
              FloatingActionButton(
                onPressed: _toggleCameras,
                child: const Icon(
                  Icons.rotate_left,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

}
