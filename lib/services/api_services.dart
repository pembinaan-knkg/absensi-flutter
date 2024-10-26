import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:magang_absen/locator.dart';
import 'package:magang_absen/models/absen.dart';
import 'package:magang_absen/models/absen_response.dart';
import 'package:magang_absen/models/anggota.dart';
import 'package:magang_absen/models/anggota_update_request.dart';
import 'package:magang_absen/models/anggota_update_response.dart';
import 'package:magang_absen/models/auth_response.dart';
import 'package:magang_absen/models/list_absen_response.dart';
import 'package:magang_absen/models/request.dart';
import 'package:http/http.dart' as http;

const servers = [
  "http://localhost:5173",
  "http://192.168.1.30:5173", //bin-network
  "http://192.168.0.134:5173", //Pidum-network
  "http://10.180.93.125:5173", //L1lyKost
];

class Result {
  Result({
    required this.message,
    required this.success,
  });

  final String message;
  final bool success;
}

class ApiServices {
  final String server = false ? servers.first : "https://outgoing-sloth-healthy.ngrok-free.app";
  Anggota? user;
  AbsenData? absenMasuk;
  AbsenData? absenPulang;
  AuthAnggotaResponse? userInfo;
  bool showHtml = false;

  static ApiServices to() => locator();

  Future<AbsenResponse> absen(Absen absen, Method type) async {
    try {
      var req = Request(method: type, data: absen);
      var json = jsonEncode(req.toJson());
      debugPrint(json);
      var res = await http
          .post(
            Uri.parse("$server/api/absen"),
            body: json,
          )
          .timeout(const Duration(seconds: 5));
      if ((res.headers["content-type"]?.contains("text/html") ?? false) && showHtml) {
        Get.to(HtmlWidget(res.body));
      }
      var resJson = jsonDecode(res.body) as Map<String, dynamic>;
      var r = AbsenResponse.fromJson(resJson);

      if (type == Method.masuk) {
        absenMasuk = r.data;
      } else {
        absenPulang = r.data;
      }

      return r;
    } catch (e) {
      return AbsenResponse(
        message: e.toString(),
        sudahAbsen: false,
      );
    }
  }

  Future<AuthResponse> auth(Anggota anggota) async {
    try {
      var res = await http
          .post(
            Uri.parse("$server/api/auth"),
            body: jsonEncode(anggota.toJson()),
          )
          .timeout(const Duration(seconds: 5));
      if ((res.headers["content-type"]?.contains("text/html") ?? false) && showHtml) {
        Get.to(Scaffold(body: HtmlWidget(res.body)));
      }
      var jsonr = jsonDecode(res.body);
      var authResponse = AuthResponse.fromJson(jsonr);
      user = anggota;
      userInfo = authResponse.anggota;
      absenMasuk = authResponse.masuk;
      absenPulang = authResponse.pulang;
      return authResponse;
    } catch (e, t) {
      debugPrintStack(stackTrace: t);
      return AuthResponse(message: e.toString());
    }
  }

  Future<ListAbsenResponse> getAbsensi(Anggota anggota) async {
    try {
      var res = await http.post(
        Uri.parse("$server/api/absen/list"),
        body: jsonEncode(anggota.toJson()),
        headers: {
          'content-type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      if ((res.headers["content-type"]?.contains("text/html") ?? false) && showHtml) {
        Get.to(Scaffold(body: HtmlWidget(res.body)));
      }
      var jbody = jsonDecode(res.body);
      var data = ListAbsenResponse.fromJson(jbody);
      return data;
    } catch (e, trace) {
      debugPrint(e.toString());
      debugPrint(trace.toString());
      return ListAbsenResponse(
        message: e.toString(),
        success: false,
        data: [],
      );
    }
  }

  Future<AnggotaUpdateResponse> updateAnggota(AnggotaUpdateRequest request) async {
    try {
      var res = await http.post(
        Uri.parse("$server/api/anggota"),
        body: jsonEncode(request.toJson()),
      );
      if ((res.headers["content-type"]?.contains("text/html") ?? false) && showHtml) {
        Get.to(Scaffold(body: HtmlWidget(res.body)));
      }
      var jbody = jsonDecode(res.body);
      var data = AnggotaUpdateResponse.fromJson(jbody);
      return data;
    } catch (e, trace) {
      debugPrintStack(stackTrace: trace);
      return AnggotaUpdateResponse(message: e.toString(), success: false);
    }
  }
}
