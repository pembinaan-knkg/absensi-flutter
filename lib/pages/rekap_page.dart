// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum RekapType {
  masuk,
  pulang;
}

class RekapPage extends StatelessWidget {
  const RekapPage({
    super.key,
    required this.rekapType,
  });

  final RekapType rekapType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rekap Absen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black54, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.black54, width: 1),
              ),
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                  ),
                  children: [
                    _tableCell(Text(
                      "No",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                    _tableCell(Text(
                      "Tanggal",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                    _tableCell(Text(
                      "Masuk",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                    _tableCell(Text(
                      "Pulang",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                  ],
                ),
                for (int i = 0; i < 40; i++)
                  if (_dateNotInFridayandSunday(
                      DateTime.now().subtract(Duration(days: i))))
                    TableRow(
                      children: [
                        _tableCell(Text("${i + 1}")),
                        _tableCell(Text(_dateToString(
                            DateTime.now().subtract(Duration(days: i))))),
                        _tableCellTimeMasuk(generateRandomTime(7, 8)),
                        _tableCellTimePulang(generateRandomTime(16, 17)),
                      ],
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _dateNotInFridayandSunday(DateTime date) {
    return date.weekday != DateTime.friday && date.weekday != DateTime.sunday;
  }

  Widget _tableCell(Widget child) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: child,
      ),
    );
  }

  Widget _tableCellTimeMasuk(DateTime time) {
    bool late = time.hour == 8 ? time.minute >= 0 : time.hour > 8;
    return TableCell(
      child: Container(
        color: late ? Colors.red : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(DateFormat.Hm().format(time)),
        ),
      ),
    );
  }

  Widget _tableCellTimePulang(DateTime time) {
    return TableCell(
      child: Container(
        color: time.hour < 16 ? Colors.red : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(DateFormat.Hm().format(time)),
        ),
      ),
    );
  }

  String _dateToString(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String _randomTimeMasuk() {
    return DateFormat.Hm().format(generateRandomTime(7, 8));
  }

  String _randomTimePulang() {
    return DateFormat.Hm().format(generateRandomTime(16, 17));
  }

  DateTime generateRandomTime(int startHour, int endHour) {
    Random random = Random();
    int hour = random.nextInt(endHour - startHour) + startHour;
    int minute = random.nextInt(60); // Random minute between 0 and 59
    return DateTime(0, 1, 1, hour,
        minute); // Date doesn't matter, just using 0 for year, 1 for month, and 1 for day
  }

  DateTime generateRandomTimeWithProbability(
      int lowHour, int highHour, double highProbability) {
    Random random = Random();
    int hour;
    int minute;

    // Check if the generated hour should be in the higher probability range
    if (random.nextDouble() < highProbability) {
      // Higher probability range
      hour = random.nextInt((highHour - lowHour) ~/ 2) + lowHour;
    } else {
      // Lower probability range
      hour = random.nextInt(1) + highHour;
    }

    minute = random.nextInt(60); // Random minute between 0 and 59

    return DateTime(0, 1, 1, hour, minute);
  }
}
