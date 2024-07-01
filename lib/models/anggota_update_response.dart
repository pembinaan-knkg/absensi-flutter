import 'package:json_annotation/json_annotation.dart';
import 'package:magang_absen/models/auth_response.dart';

part 'anggota_update_response.g.dart';

@JsonSerializable()
class AnggotaUpdateResponse {
  final String message;
  final bool success;
  final Object? errors;
  final AuthAnggotaResponse? data;

  AnggotaUpdateResponse({
    required this.message,
    required this.success,
    this.errors,
    this.data,
  });

  factory AnggotaUpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$AnggotaUpdateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AnggotaUpdateResponseToJson(this);
}
