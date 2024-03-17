// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magang_absen/locator.dart';
import 'package:magang_absen/services/location_services.dart';
import 'package:magang_absen/services/ml_services.dart';
import 'package:magang_absen/widgets/face_detector_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AbsenPage extends StatefulWidget {
  const AbsenPage({
    super.key,
    required this.onSuccess,
  });

  final void Function(XFile) onSuccess;

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  final LocationServices _locationServices = locator();
  final MLServices _mlServices = locator();
  bool? _isInRadius;
  bool _success = false;
  var _faces = [];
  bool _showTimer = false;

  @override
  void initState() {
    super.initState();
    _locationServices.refreshLocation().then((value) {
      if (mounted) {
        _isInRadius = _locationServices.isInRadius();
        if (_isInRadius == false) {
          QuickAlert.show(
            disableBackBtn: !kDebugMode,
            type: QuickAlertType.warning,
            context: context,
            title: "Gagal",
            text:
                "Anda Tidak Berada Dalam Wilayah Kejaksaan Negeri Kota Gorontalo",
            onConfirmBtnTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            confirmBtnText: "Kembali",
          );
        } else {
          setState(() {});
        }
      }
    }).onError((error, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      debugPrint(error.toString());
      setState(() {
        _isInRadius = true;
      });
      QuickAlert.show(
        disableBackBtn: true,
        context: context,
        type: QuickAlertType.error,
        title: "Gagal Mendapatkan Lokasi",
        text: error.toString(),
        confirmBtnText: "Kembali",
        onConfirmBtnTap: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      );
    });

    // Future.delayed(const Duration(seconds: 2)).then((value) {
    //   setState(() {
    //     _isInRadius = true;
    //   });
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _locationServices.reset();
  }

  void _startChecking(Future<XFile> Function() takePict) {
    setState(() {
      _showTimer = true;
    });
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (mounted) {
        setState(() {
          _showTimer = false;
          if (_faces.isNotEmpty) {
            _success = true;
            takePict().then((value) {
              widget.onSuccess(value);
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (_isInRadius != true) {
    //   return _createCheckingLocationWidget();
    // }

    return Stack(
      children: [
        FaceDetectorView(
          onDetection: (image, faces, takePict) {
            if (faces.isNotEmpty) {
              _mlServices.setCurrentPrediction(image, faces.first);
            }
            _faces = faces;
            if (faces.isNotEmpty && !_success && !_showTimer) {
              _startChecking(takePict);
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
    );
  }

  Center _createNotInLocationWidget() {
    return const Center(
      child: Text(
        "Anda Tidak Berada Dalam Wilayah Kejaksaan Negeri Kota Gorontalo",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  Center _createCheckingLocationWidget() {
    return Center(
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
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final Animation<double> _textAnimation =
      Tween(begin: 80.0, end: 40.0).animate(
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
