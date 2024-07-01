import 'package:json_annotation/json_annotation.dart';
import 'package:magang_absen/models/absen_response.dart';

part 'list_absen_response.g.dart';

@JsonSerializable()
class InfoAbsen {
  InfoAbsen({
    required this.tanggal,
    required this.note,
    this.ket,
    this.masuk,
    this.pulang,
  });

  final DateTime tanggal;
  final String? ket;
  @JsonKey(name: 'noteId')
  final String note;
  @JsonKey(name: 'absenMasuk')
  final AbsenData? masuk;
  @JsonKey(name: 'absenPulang')
  final AbsenData? pulang;

  factory InfoAbsen.fromJson(Map<String, dynamic> json) =>
      _$InfoAbsenFromJson(json);
  Map<String, dynamic> toJson() => _$InfoAbsenToJson(this);
}

@JsonSerializable()
class ListAbsenResponse {
  ListAbsenResponse({
    required this.message,
    required this.success,
    this.data,
    this.errors,
  });

  final String message;
  final Map<String, dynamic>? errors;
  @JsonKey(defaultValue: false, required: false)
  final bool success;
  final List<InfoAbsen>? data;

  factory ListAbsenResponse.fromJson(Map<String, dynamic> json) =>
      _$ListAbsenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ListAbsenResponseToJson(this);
}
