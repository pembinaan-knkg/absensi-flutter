import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsenResult extends StatefulWidget {
  const AbsenResult({
    super.key,
    required this.imagePath,
    required this.time,
    required this.onConfirm,
  });

  final XFile imagePath;
  final DateTime time;
  final void Function() onConfirm;

  @override
  State<AbsenResult> createState() => _AbsenResultState();
}

class _AbsenResultState extends State<AbsenResult> {
  @override
  void initState() {
    debugPrint("${widget.imagePath}");
    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Material(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              shadowColor: Colors.black,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Berhasil Absen Tanggal: ${widget.time}",
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                    fontSize: 20,
                  )),
                ),
              ),
            ),
          ),
          Transform.flip(
            flipX: true,
            child: Center(
              child: Image.file(File(widget.imagePath.path)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              label: const Text("Kembali"),
              icon: const Icon(Icons.home),
            ),
          )
        ],
      ),
    );
  }
}
