// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:magang_absen/models/absen.dart';
import 'package:magang_absen/models/foto.dart';
import 'package:magang_absen/models/location.dart';
import 'package:magang_absen/models/request.dart';
import 'package:magang_absen/pages/absen_page.dart';
import 'package:magang_absen/services/api_services.dart';
import 'package:magang_absen/services/utils.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ProcessAbsenView extends StatefulWidget {
  const ProcessAbsenView({
    super.key,
    required this.imageBytes,
    required this.location,
    required this.method,
  });

  final Uint8List imageBytes;
  final Location location;
  final Method method;

  @override
  State<StatefulWidget> createState() {
    return _ProcessAbsenViewState();
  }
}

class _ProcessAbsenViewState extends State<ProcessAbsenView> {
  final ApiServices _apiServices = ApiServices.to();
  FotoData? _foto;
  bool? _success;
  final DateTime tanggal = DateTime.now();
  String _infoMsg = "Processing";

  @override
  void initState() {
    super.initState();

    _upload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            _apiServices.userInfo!.fullname ?? _apiServices.userInfo!.username),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Align(
            alignment: Alignment.center,
            child: Text("${formatTanggal(tanggal)} ${formatJam(tanggal)}"),
          ),
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.memory(widget.imageBytes),
            Visibility(
              visible: _success == null,
              child: SpinKitCubeGrid(color: Colors.blue),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(10).copyWith(bottom: 20),
                child: FilledButton(
                  onPressed: () {},
                  child: Text(_infoMsg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _upload() {
    setState(() {
      _infoMsg = "Uploading File...";
    });

    uploadPict(widget.imageBytes, _apiServices.user!).then((value) {
      setState(() {
        _foto = value;
      });
      _absen();
    }).onError((e, t) {
      debugPrintStack(stackTrace: t);
      warnAlert(
        context: context,
        title: 'Error',
        text: 'Gagal Upload File: $e',
        onConfirm: () => Get.until((route) => route.isFirst),
      );
    });
  }

  void _absen() {
    setState(() {
      _infoMsg = "Update Absen...";
    });

    if (_foto == null) {
      warnAlert(
        context: context,
        title: 'Absen',
        text: 'Gambar Tidak Terupload',
        onConfirm: () => Get.until((route) => route.isFirst),
      );
      return;
    }

    var absen = _apiServices.absen(
      Absen(
        anggota: _apiServices.user!,
        location: widget.location,
        pict: _foto,
      ),
      widget.method,
    );
    var typeAbsen = widget.method == Method.masuk ? "Masuk" : "Pulang";

    absen.then((value) {
      _success = value.success;
      setState(() {
        _infoMsg = _success == false ? "Gagal" : "Sukses";
      });
      if (_success == true) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Absen $typeAbsen',
          text:
              'Sukses Absen $typeAbsen ${formatTanggal(tanggal)} - ${formatJam(tanggal)}',
          onConfirmBtnTap: () => Get.until((route) => route.isFirst),
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Absen $typeAbsen',
          text: 'Gagal Absen: ${value.message}',
          showCancelBtn: true,
          confirmBtnText: "Absen Kembali",
          onConfirmBtnTap: () {
            Get.offUntil(
              GetPageRoute(
                page: () => AbsenPage(
                  type: widget.method,
                ),
              ),
              (route) => route.isFirst,
            );
          },
          cancelBtnText: "Batal",
          onCancelBtnTap: () {
            Get.until((route) => route.isFirst);
          },
        );
      }
    });

    absen.onError((e, t) {
      debugPrintStack(stackTrace: t);
      warnAlert(
        context: context,
        title: 'Error',
        text: 'Gagal Absen: $e',
        onConfirm: () => Get.until((route) => route.isFirst),
      );
      return Future.error(e.toString());
    });
  }
}
