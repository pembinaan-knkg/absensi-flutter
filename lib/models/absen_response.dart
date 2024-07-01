import 'package:json_annotation/json_annotation.dart';
import 'package:magang_absen/models/foto.dart';

part 'absen_response.g.dart';

@JsonSerializable()
class AbsenData {
  AbsenData({
    required this.time,
    required this.latitude,
    required this.longitude,
    this.foto,
  });

  final DateTime time;
  final String? latitude;
  final String? longitude;
  final Foto? foto;

  factory AbsenData.fromJson(Map<String, dynamic> json) =>
      _$AbsenDataFromJson(json);
  Map<String, dynamic> toJson() => _$AbsenDataToJson(this);
}

@JsonSerializable()
class AbsenResponse {
  AbsenResponse({
    required this.sudahAbsen,
    required this.message,
    this.data,
  });

  @JsonKey(defaultValue: false, required: false)
  final bool sudahAbsen;
  final String message;
  final AbsenData? data;

  bool get success => !sudahAbsen && data != null;

  factory AbsenResponse.fromJson(Map<String, dynamic> json) =>
      _$AbsenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AbsenResponseToJson(this);
}
