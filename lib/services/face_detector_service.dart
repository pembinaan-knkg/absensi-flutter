import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:magang_absen/locator.dart';
import 'package:magang_absen/services/camera_services.dart';
import 'package:camera/camera.dart';

class FaceDetectorService extends Listenable {
  final CameraService _cameraService = locator<CameraService>();

  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];
  List<Face> get faces => _faces;

  CameraImage? _cameraImage;
  CameraImage? get cameraImage => _cameraImage;

  bool get faceDetected => _faces.isNotEmpty;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  void init() async {}

  void initialize() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<void> detecFacesFromImage(
      CameraImage image, CameraController cameraController) async {
    try {
      _isProcessing = true;
      _cameraImage = image;
      InputImage? inputImage =
          await _inputImageFromCameraImage(image, cameraController);
      if (inputImage == null) {
        debugPrint("inputImage null");
        _faces = [];
        _isProcessing = false;
        return;
      }

      _faces = await _faceDetector.processImage(inputImage);
      _faces = _faces.isNotEmpty ? [_faces.first] : [];
      for (var listener in _listener) {
        listener();
      }
      _isProcessing = false;
    } catch (e) {
      debugPrint(e.toString());
      _isProcessing = false;
    }
  }

  Future<InputImage?> _inputImageFromCameraImage(
      CameraImage image, CameraController cameraController) async {
    if (!cameraController.value.isInitialized) {
      debugPrint("camera not initialized");
      return null;
    }

    InputImageRotation rotation = _cameraService.rotationIntToImageRotation(
        cameraController.value.description.sensorOrientation);

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    // if (format == null ||
    //     (Platform.isAndroid && format != InputImageFormat.nv21) ||
    //     (Platform.isIOS && format != InputImageFormat.bgra8888)) {
    //   debugPrint("InputImageFormat not in valid format");
    //   return null;
    // }

    // since format is constraint to nv21 or bgra8888, both only have one plane
    // if (image.planes.length != 1) return null;
    // final plane = image.planes.first;
    final allBytes = WriteBuffer();
    for(final Plane plane in image.planes){
      allBytes.putUint8List(plane.bytes);
    }

    return InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format!, // used only in iOS
        bytesPerRow: image.planes.first.bytesPerRow, // used only in iOS
      ),
    );
  }

  void dispose() {
    _faceDetector.close();
    _listener = [];
    _isProcessing = false;
  }

  List<VoidCallback> _listener = [];

  @override
  void addListener(VoidCallback listener) {
    _listener.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listener.remove(listener);
  }
}
