import 'package:json_annotation/json_annotation.dart';
import 'package:magang_absen/models/anggota.dart';
import 'package:magang_absen/models/foto.dart';

part 'anggota_update_request.g.dart';

@JsonSerializable()
class AnggotaUpdateData {
  final String? fullname;
  final String? password;
  final FotoData? profilePict;

  AnggotaUpdateData({
    this.fullname,
    this.password,
    this.profilePict,
  });

  factory AnggotaUpdateData.fromJson(Map<String, dynamic> json) =>
      _$AnggotaUpdateDataFromJson(json);
  Map<String, dynamic> toJson() => _$AnggotaUpdateDataToJson(this);
}

@JsonSerializable()
class AnggotaUpdateRequest {
  final Anggota credential;
  final AnggotaUpdateData data;

  AnggotaUpdateRequest({required this.credential, required this.data});

  factory AnggotaUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$AnggotaUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AnggotaUpdateRequestToJson(this);
}
