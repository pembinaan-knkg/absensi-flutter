// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anggota_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnggotaUpdateData _$AnggotaUpdateDataFromJson(Map<String, dynamic> json) =>
    AnggotaUpdateData(
      fullname: json['fullname'] as String?,
      password: json['password'] as String?,
      profilePict: json['profilePict'] == null
          ? null
          : FotoData.fromJson(json['profilePict'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnggotaUpdateDataToJson(AnggotaUpdateData instance) =>
    <String, dynamic>{
      'fullname': instance.fullname,
      'password': instance.password,
      'profilePict': instance.profilePict,
    };

AnggotaUpdateRequest _$AnggotaUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    AnggotaUpdateRequest(
      credential: Anggota.fromJson(json['credential'] as Map<String, dynamic>),
      data: AnggotaUpdateData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnggotaUpdateRequestToJson(
        AnggotaUpdateRequest instance) =>
    <String, dynamic>{
      'credential': instance.credential,
      'data': instance.data,
    };
