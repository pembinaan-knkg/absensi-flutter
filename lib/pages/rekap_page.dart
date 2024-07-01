// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:magang_absen/models/list_absen_response.dart';
import 'package:magang_absen/services/api_services.dart';
import 'package:magang_absen/services/utils.dart';

class RekapPage extends StatefulWidget {
  const RekapPage({
    super.key,
  });

  @override
  State<RekapPage> createState() => _RekapPageState();
}

class _RekapPageState extends State<RekapPage> {
  final _api = ApiServices.to();
  List<InfoAbsen>? absensi;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future _refresh() async {
    var r = await _api.getAbsensi(_api.user!);
    if (mounted) {
      if (!r.success) {
        warnAlert(
          context: context,
          title: 'Absensi',
          text: r.message,
          onConfirm: () => Get.until((route) => route.isFirst),
        );
        return;
      }
      setState(() {
        absensi = r.data;
      });
    }
  }

  Widget _item(
    String text, {
    double? width,
    double? height,
    TextStyle? textStyle,
  }) {
    return SizedBox(
      width: width ?? 100,
      height: height ?? 50,
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (absensi == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Absen'),
        automaticallyImplyLeading: true,
      ),
      body: HorizontalDataTable(
        leftHandSideColumnWidth: 100,
        rightHandSideColumnWidth: 100 * 4,
        isFixedHeader: true,
        rowSeparatorWidget: const Divider(
          color: Colors.black45,
          height: 1,
          thickness: 0,
        ),
        headerWidgets: _headers,
        leftSideChildren: [
          for (var absen in absensi ?? <InfoAbsen>[])
            _item(formatTanggal(absen.tanggal.toLocal())),
        ],
        rightSideChildren: [
          for (var absen in absensi ?? <InfoAbsen>[])
            Row(
              children: [
                _item(
                  formatJam(absen.masuk?.time.toLocal()),
                  textStyle: TextStyle(
                    color: checkStatusMasukTerlambat(absen) ? Colors.red : null,
                  ),
                ),
                _item(
                  formatJam(absen.pulang?.time.toLocal()),
                  textStyle: TextStyle(
                    color: checkStatusPulangCepat(absen) ? Colors.red : null,
                  ),
                ),
                _item(absen.note),
                _item(absen.ket ?? "-"),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> get _headers {
    return [
      _item(
        'Tanggal',
        textStyle: TextStyle(
          color: Colors.lightBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
      _item(
        'Masuk',
        textStyle: TextStyle(
          color: Colors.lightBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
      _item(
        'Pulang',
        textStyle: TextStyle(
          color: Colors.lightBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
      _item(
        'Note',
        textStyle: TextStyle(
          color: Colors.lightBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
      _item(
        'Ket',
        textStyle: TextStyle(
          color: Colors.lightBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  bool checkStatusMasukTerlambat(InfoAbsen absen) {
    if (absen.masuk == null) return false;
    var day = absen.tanggal.toLocal().copyWith(
          hour: 8,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
          isUtc: false,
        );
    return absen.masuk!.time
        .toLocal()
        .copyWith(
          second: 0,
          millisecond: 0,
          microsecond: 0,
          isUtc: false,
        )
        .isAfter(day);
  }

  bool checkStatusPulangCepat(InfoAbsen absen) {
    if (absen.pulang == null) return false;
    var day = absen.tanggal.toLocal().copyWith(
          hour: 16,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
          isUtc: false,
        );
    return absen.pulang!.time
        .toLocal()
        .copyWith(
          second: 0,
          millisecond: 0,
          microsecond: 0,
          isUtc: false,
        )
        .isBefore(day);
  }
}
