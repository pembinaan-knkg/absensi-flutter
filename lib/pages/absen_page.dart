// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures
import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magang_absen/locator.dart';
import 'package:magang_absen/models/absen.dart';
import 'package:magang_absen/models/foto.dart';
import 'package:magang_absen/models/location.dart';
import 'package:magang_absen/models/request.dart';
import 'package:magang_absen/services/api_services.dart';
import 'package:magang_absen/services/camera_services.dart';
import 'package:magang_absen/services/location_services.dart';
import 'package:magang_absen/services/utils.dart';
import 'package:magang_absen/widgets/face_detector_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:magang_absen/widgets/process_absen_view.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:toastification/toastification.dart';

class AbsenPage extends StatefulWidget {
  const AbsenPage({
    super.key,
    required this.type,
    this.onSuccess,
  });

  final void Function(Location, CameraImage)? onSuccess;
  final Method type;

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  final LocationServices _locationServices = locator();
  final ApiServices _apiServices = locator();
  bool _success = false;
  var _faces = [];
  bool _showTimer = false;
  final bool _checkLocation = !kDebugMode;

  bool _notInRadius() {
    return !_locationServices.inRadius && _checkLocation && _apiServices.userInfo!.satker != "Petugas Pengemudi";
  }

  @override
  void initState() {
    super.initState();
    if (!_locationServices.inRadius) {
      Future.delayed(const Duration(seconds: 3)).then((_) {
        if (_notInRadius()) {
          warnAlert(
            context: context,
            title: "Gagal",
            text: "Anda Tidak Berada Dalam Wilayah Kejaksaan Negeri Kota Gorontalo",
            onConfirm: () {
              Get.until((route) => route.isFirst);
            },
          );
        } else if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _locationServices.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_notInRadius()) {
      debugPrint('not in radius');
      return _createCheckingLocationWidget();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PopScope(
        canPop: !_success || kDebugMode,
        child: Stack(
          children: [
            FaceDetectorView(
              onDetection: (image, faces, takePict) {
                _faces = faces;
                // TODO: face recognition
                // if (faces.isNotEmpty) {
                //   _mlServices.setCurrentPrediction(image, faces.first);
                // }
                if (faces.isNotEmpty && !_success && !_showTimer) {
                  _startChecking(takePict, image);
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _faces.isNotEmpty ? "Detected" : "Not Detected",
                      style: TextStyle(
                        color: _faces.isNotEmpty ? Colors.green : Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _showTimer,
              child: const FaceTimer(),
            ),
          ],
        ),
      ),
    );
  }

  void _startChecking(Future<XFile> Function() takePict, CameraImage image) {
    setState(() {
      _showTimer = true;
    });

    Future.delayed(const Duration(seconds: 3)).then((_) {
      _success = _faces.isNotEmpty && !_notInRadius();
      _showTimer = false;
      setState(() {});
      if (_success) {
        _process2(
          takePict,
          image,
        ).onError((e, t) {
          debugPrintStack(stackTrace: t);
          warnAlert(
            preventBack: false,
            context: context,
            title: 'Error',
            text: 'Gagal Memproses Absen: ${e.toString()}',
            onConfirm: () {
              Get.back();
              setState(() {
                _success = false;
              });
            },
          );
        });
      }
    });
  }

  void onSuccesScanningFace(Location location, Uint8List? imageBytes) async {
    var toast = toastification.show(
      context: context,
      title: Text('Processing...'),
      type: ToastificationType.info,
      showProgressBar: false,
      icon: SpinKitRipple(
        color: Colors.blue,
      ),
      alignment: Alignment.bottomCenter,
    );

    FotoData? file;
    if (imageBytes != null) {
      file = await uploadPict(imageBytes, _apiServices.user!);
      if ((file == null) && mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.warning,
          title: Text('Gagal Upload Foto'),
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }

    var absen = Absen(
      anggota: _apiServices.user!,
      location: location,
      pict: file,
    );

    var res = await _apiServices.absen(absen, widget.type);
    if (file != null) {
      deleteFireFile(file.path);
    }

    toastification.dismiss(toast);
    if (mounted) {
      QuickAlert.show(
        context: context,
        type: res.success ? QuickAlertType.success : QuickAlertType.error,
        title: widget.type == Method.masuk ? 'Absen Masuk' : 'Absen Pulang',
        text: res.message,
        disableBackBtn: true,
        onConfirmBtnTap: () => Navigator.popUntil(context, (route) => route.isFirst),
      );
    }
  }

  Future _process2(Future<XFile> Function() takePict, CameraImage image) async {
    var img = await cameraImageToBytes(image, CameraService.to().rotation);
    if (img == null) {
      if (mounted)
        warnAlert(
          context: context,
          title: 'Foto',
          text: 'Gagal Mendapatkan Foto',
        );
      return;
    }

    var loc = _locationServices.currentLocation;
    if (loc == null) {
      if (mounted)
        warnAlert(
          context: context,
          title: 'Lokasi',
          text: 'Gagal Mendapatkan Lokasi',
        );
      return;
    }

    Get.off(ProcessAbsenView(
      imageBytes: img,
      location: Location(
        latitude: loc.latitude.toString(),
        longitude: loc.longitude.toString(),
      ),
      method: widget.type,
    ));
  }

  // ignore: unused_element
  void _process(CameraImage image) {
    if (mounted) {
      setState(() {
        _showTimer = false;
        _success = _faces.isNotEmpty;
      });
      if (_success) {
        var location = _locationServices.currentLocation;
        if (location == null) {
          warnAlert(
            context: context,
            title: 'Gagal',
            text: "Gagal Mendapatkan Lokasi",
          );
          return;
        }

        var loc = Location(
          latitude: location.latitude.toString(),
          longitude: location.longitude.toString(),
        );

        cameraImageToBytes(image, CameraService.to().rotation).then((value) {
          if (value == null && context.mounted)
            warnAlert(
              context: context,
              title: 'Gagal',
              text: 'Gagal Process Foto',
            );
          onSuccesScanningFace(loc, value);
        });
      }
    }
  }

  Widget _createCheckingLocationWidget() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Cek Lokasi...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Gap(10),
            SpinKitThreeBounce(
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class FaceTimer extends StatefulWidget {
  const FaceTimer({super.key});

  @override
  State<FaceTimer> createState() => _FaceTimerState();
}

class _FaceTimerState extends State<FaceTimer> with TickerProviderStateMixin {
  int _seconds = 1;
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final Animation<double> _textAnimation = Tween(begin: 80.0, end: 40.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    ),
  );
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _controller.reset();
          _controller.forward();
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Text(
            "$_seconds",
            style: TextStyle(
              color: Colors.white,
              fontSize: _textAnimation.value,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }
}
