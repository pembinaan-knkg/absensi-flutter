import 'package:json_annotation/json_annotation.dart';
import 'package:magang_absen/models/absen_response.dart';
import 'package:magang_absen/models/foto.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthAnggotaResponse {
  AuthAnggotaResponse({
    required this.username,
    required this.satker,
    this.fullname,
    this.foto,
  });

  final String username;
  final String? fullname;
  @JsonKey(name: 'profilePict')
  final Foto? foto;
  @JsonKey(name: 'satkerId')
  final String satker;

  factory AuthAnggotaResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthAnggotaResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthAnggotaResponseToJson(this);
}

@JsonSerializable()
class AuthResponse {
  AuthResponse({
    required this.message,
    this.anggota,
    this.masuk,
    this.pulang,
  });

  final String message;
  final AuthAnggotaResponse? anggota;
  final AbsenData? masuk;
  final AbsenData? pulang;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
