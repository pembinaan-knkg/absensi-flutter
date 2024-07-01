// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthAnggotaResponse _$AuthAnggotaResponseFromJson(Map<String, dynamic> json) =>
    AuthAnggotaResponse(
      username: json['username'] as String,
      satker: json['satkerId'] as String,
      fullname: json['fullname'] as String?,
      foto: json['profilePict'] == null
          ? null
          : Foto.fromJson(json['profilePict'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthAnggotaResponseToJson(
        AuthAnggotaResponse instance) =>
    <String, dynamic>{
      'username': instance.username,
      'fullname': instance.fullname,
      'profilePict': instance.foto,
      'satkerId': instance.satker,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      message: json['message'] as String,
      anggota: json['anggota'] == null
          ? null
          : AuthAnggotaResponse.fromJson(
              json['anggota'] as Map<String, dynamic>),
      masuk: json['masuk'] == null
          ? null
          : AbsenData.fromJson(json['masuk'] as Map<String, dynamic>),
      pulang: json['pulang'] == null
          ? null
          : AbsenData.fromJson(json['pulang'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'anggota': instance.anggota,
      'masuk': instance.masuk,
      'pulang': instance.pulang,
    };
