import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class MLServices {
  Interpreter? _interpreter;
  double treshold = .5;

  final List _predictedData = [];
  List get predictedData => _predictedData;

  bool isReady() => _interpreter != null;

  Future<MLServices> init() async {
    return this;
  }

  Future initialize() async {
    try {
      // late Delegate delegate;
      //   if (Platform.isAndroid) {
      //     delegate = GpuDelegateV2(
      //       options: GpuDelegateOptionsV2(
      //         isPrecisionLossAllowed: false,
      //         inferencePreference: TFLITE_GPU_INFERENCE_PREFERENCE_FAST_SINGLE_ANSWER,
      //         inferencePriority1: TfLiteGpuInferencePriority.minLatency,
      //         inferencePriority2: TfLiteGpuInferencePriority.auto,
      //         inferencePriority3: TfLiteGpuInferencePriority.auto,
      //       ),
      //     );
      //   } else if (Platform.isIOS) {
      //     delegate = GpuDelegate(
      //       options: GpuDelegateOptions(allowPrecisionLoss: true, waitType: TFLGpuDelegateWaitType.active),
      //     );
      //   }
      var interpreterOptions = InterpreterOptions();
      // interpreterOptions.addDelegate(delegate)

      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite',
          options: interpreterOptions);
    } catch (e) {
      debugPrint('Failed to load model.');
      debugPrint(e.toString());
    }
  }

  void setCurrentPrediction(CameraImage image, Face face) {
    assert(isReady(), "Interpreter is not ready");
    List input = _preProccess(image, face);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));
    print("$input, $output");
  }

  List _preProccess(CameraImage image, Face face) {
    imglib.Image cropped = _cropFace(image, face);
    imglib.Image img = imglib.copyResizeCropSquare(cropped, size: 112);
    Float32List imgAsList = imageToByteList(img);
    return imgAsList;
  }

  Float32List imageToByteList(imglib.Image image) {
    return Float32List.fromList(
        image.toUint8List().map((e) => e / 255.0).toList());
  }

  imglib.Image _cropFace(CameraImage image, Face face) {
    imglib.Image convertedImg = _convertCameraImage(image);
    return imglib.copyCrop(
      convertedImg,
      x: face.boundingBox.left.toInt(),
      y: face.boundingBox.top.toInt(),
      width: face.boundingBox.width.toInt(),
      height: face.boundingBox.height.toInt(),
    );
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    return imglib.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes.first.bytes.buffer,
    );
  }
}
