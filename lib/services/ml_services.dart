import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:magang_absen/services/utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class MLServices {
  Interpreter? _interpreter;
  double treshold = .5;
  bool _processing = false;
  bool get processing => _processing;

  List _predictedData = [];
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
      interpreterOptions.useNnApiForAndroid = true;
      interpreterOptions.addDelegate(
        GpuDelegateV2(
          options: GpuDelegateOptionsV2(
            isPrecisionLossAllowed: false,
          ),
        ),
      );

      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite',
          options: interpreterOptions);
    } catch (e) {
      debugPrint('Failed to load model.');
      debugPrint(e.toString());
    }
  }

  Future<List?> setCurrentPrediction(imglib.Image image, Face face) async {
    if (_interpreter == null) return null;
    _processing = true;
    try {
      List input = await preProccess(image, face);
      input = input.reshape([1, 112, 112, 3]);
      List output = List.generate(1, (index) => List.filled(192, 0));
      _interpreter!.run(input, output);
      output = output.reshape([192]);
      _predictedData = List.from(output);
      _processing = false;
      return _predictedData;
    } catch (e) {
      debugPrint(e.toString());
      _processing = false;
      return null;
    }
  }

  Future<List?> predictWithoutCrop(imglib.Image image) async {
    if (_interpreter == null) return null;
    _processing = true;
    try {
      image = imglib.copyResizeCropSquare(image, size: 112);
      var bytes = imageToByteList(image);
      List input = bytes.reshape([1, 112, 112, 3]);
      List output = List.generate(1, (index) => List.filled(192, 0));
      _interpreter!.run(input, output);
      _processing = false;
      return List.from(output.reshape([192]));
    } catch (e) {
      debugPrint(e.toString());
      _processing = false;
      return null;
    }
  }

  Future<List> preProccess(imglib.Image image, Face face) async {
    imglib.Image cropped = cropFace(image, face);
    image = imglib.copyResizeCropSquare(cropped, size: 112);
    Float32List imgAsList = imageToByteList(image);
    return imgAsList;
  }

  Float32List imageToByteList(imglib.Image image) {
    return Float32List.fromList(
        image.toUint8List().map((e) => e / 255.0).toList());
  }

  double euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }
}
