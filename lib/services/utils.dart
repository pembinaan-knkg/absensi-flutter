// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'dart:io';

import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:magang_absen/locator.dart';
import 'package:get/get.dart';
import 'package:magang_absen/models/absen.dart';
import 'package:magang_absen/models/anggota.dart';
import 'package:magang_absen/models/auth_response.dart';
import 'package:magang_absen/models/foto.dart';
import 'package:magang_absen/models/location.dart';
import 'package:magang_absen/models/request.dart';
import 'package:magang_absen/services/api_services.dart';
import 'package:magang_absen/services/camera_services.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

void toast(String title, String text) {
  Get.snackbar(
    title,
    text,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.white,
    margin: const EdgeInsets.all(10),
    boxShadows: [
      const BoxShadow(color: Colors.black38, blurRadius: 3),
    ],
  );
}

Future<Uint8List?> cameraImageToBytes(
    CameraImage image, int cameraRotation) async {
  var converter = ConvertNativeImgStream();
  var bytes = await converter.convertImgToBytes(
    image.planes.last.bytes,
    image.width,
    image.height,
    rotationFix: cameraRotation,
  );
  return bytes;
}

Future<File?> cameraImageToFile(
    String path, CameraImage image, int cameraRotation) async {
  var converter = ConvertNativeImgStream();
  var file = await converter.convertImg(
    image.planes.last.bytes,
    image.width,
    image.height,
    path,
    rotationFix: cameraRotation,
  );
  return file;
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

Future<imglib.Image?> fileToImage(XFile f) async {
  var bytes = await f.readAsBytes();
  return imglib.decodeImage(bytes);
}

Future<imglib.Image> convertToImage(CameraImage image) async {
  var converter = ConvertNativeImgStream();
  switch (image.format.group) {
    case ImageFormatGroup.nv21:
      var bytes = await converter.convertImgToBytes(
        image.planes.first.bytes,
        image.width,
        image.height,
      );
      return imglib.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: bytes!.buffer,
        format: imglib.Format.uint8,
        numChannels: 2,
      );
    case ImageFormatGroup.yuv420:
      return _convertYUV420(image);
    case ImageFormatGroup.bgra8888:
      return _convertBGRA8888(image);
    default:
      throw Exception('Image format not supported');
  }
}

imglib.Image cropFace(imglib.Image image, Face face) {
  return imglib.copyCrop(
    image,
    x: face.boundingBox.left.toInt(),
    y: face.boundingBox.top.toInt(),
    width: face.boundingBox.width.toInt(),
    height: face.boundingBox.height.toInt(),
  );
}

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: image.planes.first.bytes.buffer,
  );
}

imglib.Image _convertYUV420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  var img = imglib.Image(width: width, height: height);
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      // img.data![index] = hexFF | (b << 16) | (g << 8) | r;
      if (img.isBoundsSafe(height - y, x)) {
        img.setPixelRgba(height - y, x, r, g, b, hexFF);
      }
    }
  }

  return img;
}

Uint8List flipImageVertically(Uint8List imageData, int width, int height) {
  Uint8List flippedImageData = Uint8List.fromList(imageData);

  for (int i = 0; i < height ~/ 2; i++) {
    int topRowIndex = i * width;
    int bottomRowIndex = (height - i - 1) * width;

    // Swap rows
    flippedImageData.setRange(topRowIndex, topRowIndex + width,
        imageData.skip(bottomRowIndex).take(width));

    flippedImageData.setRange(bottomRowIndex, bottomRowIndex + width,
        imageData.skip(topRowIndex).take(width));
  }

  return flippedImageData;
}

Future<FotoData?> uploadPict(Uint8List bytes, Anggota anggota) async {
  try {
    var id = DateTime.now().microsecondsSinceEpoch;
    var storage = FirebaseStorage.instance;
    var path = 'temp/${anggota.username}/$id';
    var ref = storage.ref(path);
    var task = ref
        .putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        )
        .timeout(const Duration(seconds: 15));
    await task;
    return FotoData(
      path: path,
      name: "${anggota.username} $id",
      downloadURL: await ref.getDownloadURL(),
    );
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future deleteCred() async {
  var shared = await SharedPreferences.getInstance();
  shared.remove('username');
  shared.remove('password');
}

Future<Anggota?> loadCred() async {
  var shared = await SharedPreferences.getInstance();
  var username = shared.getString('username');
  var password = shared.getString('password');
  if (username != null && password != null)
    return Anggota(username: username, password: password);
  return null;
}

void saveCred(Anggota anggota) async {
  var shared = await SharedPreferences.getInstance();
  shared.setString('username', anggota.username);
  shared.setString('password', anggota.password);
}

Future<AuthResponse> authenticate(Anggota anggota) async {
  try {
    var api = locator<ApiServices>();
    var res = await api.auth(anggota);
    return res;
  } catch (e, trace) {
    debugPrint(e.toString());
    debugPrintStack(stackTrace: trace);
    return AuthResponse(message: e.toString());
  }
}

UploadTask uploadBytes(Uint8List bytes, Anggota user) {
  var storage = FirebaseStorage.instance;
  var name = DateTime.now().millisecondsSinceEpoch;
  var path = '/temp/${user.username}/$name';
  var ref = storage.ref(path);
  return ref.putData(bytes)..timeout(const Duration(seconds: 15));
}

Future absenHelper(
    Location loc, CameraImage img, BuildContext ctx, Method type) async {
  var api = ApiServices.to();

  var bytes = await cameraImageToBytes(img, 0);
  if (bytes == null) {
    toastification.show(context: ctx, title: const Text("Gagal"));
  }
  var toast = toastification.show(
    context: ctx,
    title: const Text('Absen Masuk'),
    description: const Text('Cek Database...'),
  );

  var res = await api.absen(
    Absen(
      anggota: api.user!,
      location: loc,
    ),
    Method.pulang,
  );
  toastification.dismiss(toast);
  toastification.show(
    context: ctx,
    autoCloseDuration: const Duration(seconds: 3),
    title: Text(res.message),
  );
  return res;
}

void errorAlert({
  required BuildContext context,
  required String title,
  required String text,
}) {
  QuickAlert.show(
    disableBackBtn: true,
    context: context,
    type: QuickAlertType.error,
    title: title,
    text: text,
    confirmBtnText: "Kembali",
    onConfirmBtnTap: () {
      Navigator.popUntil(context, (route) => route.isFirst);
    },
  );
}

void warnAlert({
  required BuildContext context,
  required String title,
  required String text,
  bool preventBack = true,
  void Function()? onConfirm,
}) {
  QuickAlert.show(
    disableBackBtn: preventBack,
    context: context,
    type: QuickAlertType.warning,
    title: title,
    text: text,
    confirmBtnText: "Kembali",
    onConfirmBtnTap: onConfirm ?? () => Get.back(),
  );
}

void toastHelper({
  required BuildContext context,
  required String title,
  required String text,
}) {
  toastification.show(
    autoCloseDuration: const Duration(seconds: 3),
    context: context,
    title: Text(title),
    description: Text(text),
  );
}

void deleteFireFile(String path) {
  try {
    var storage = FirebaseStorage.instance;
    storage.ref(path).delete();
  } catch (e) {
    debugPrint(e.toString());
  }
}

String formatTanggal(DateTime? date) {
  if (date == null) return "-";
  return DateFormat.yMMMd('id').format(date);
}

String formatJam(DateTime? date) {
  if (date == null) return "-";
  return DateFormat.Hm('id').format(date);
}

void previewImage(ImageProvider image, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Center(
        child: Image(
          image: image,
        ),
      ),
    ),
  );
}

Future<InputImage?> inputImageFromCameraImage(CameraImage image) async {
  InputImageRotation rotation =
      rotationIntToImageRotation(CameraService.to().rotation);

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  // validate format depending on platform
  // only supported formats:
  // * nv21 for Android
  // * bgra8888 for iOS
  if (format == null ||
      (Platform.isAndroid && format != InputImageFormat.nv21) ||
      (Platform.isIOS && format != InputImageFormat.bgra8888)) {
    debugPrint("InputImageFormat not in valid format");
    return null;
  }

  // since format is constraint to nv21 or bgra8888, both only have one plane
  if (image.planes.length != 1) return null;
  final plane = image.planes.first;

  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // used only in Android
      format: format, // used only in iOS
      bytesPerRow: plane.bytesPerRow, // used only in iOS
    ),
  );
}

imglib.Image convertNV21(CameraImage image) {
  final width = image.width.toInt();
  final height = image.height.toInt();
  Uint8List yuv420sp = image.planes[0].bytes;

  // Initial conversion from NV21 to RGB
  final outImg =
      imglib.Image(height: height, width: width); // Note the swapped dimensions
  final int frameSize = width * height;

  for (int j = 0, yp = 0; j < height; j++) {
    int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
    for (int i = 0; i < width; i++, yp++) {
      int y = (0xff & yuv420sp[yp]) - 16;
      if (y < 0) y = 0;
      if ((i & 1) == 0) {
        v = (0xff & yuv420sp[uvp++]) - 128;
        u = (0xff & yuv420sp[uvp++]) - 128;
      }
      int y1192 = 1192 * y;
      int r = (y1192 + 1634 * v);
      int g = (y1192 - 833 * v - 400 * u);
      int b = (y1192 + 2066 * u);

      if (r < 0) {
        r = 0;
      } else if (r > 262143) r = 262143;
      if (g < 0) {
        g = 0;
      } else if (g > 262143) g = 262143;
      if (b < 0) {
        b = 0;
      } else if (b > 262143) b = 262143;

      outImg.setPixelRgba(j, width - i - 1, ((r << 6) & 0xff0000) >> 16,
          ((g >> 2) & 0xff00) >> 8, (b >> 10) & 0xff, 255);
    }
  }
  return outImg;
  // Rotate the image by 90 degrees (or 270 degrees if needed)
  // return imglib.copyRotate(outImg, -90); // Use -90 for a 270 degrees rotation
}
