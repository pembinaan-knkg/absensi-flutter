// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anggota_update_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnggotaUpdateResponse _$AnggotaUpdateResponseFromJson(
        Map<String, dynamic> json) =>
    AnggotaUpdateResponse(
      message: json['message'] as String,
      success: json['success'] as bool,
      errors: json['errors'],
      data: json['data'] == null
          ? null
          : AuthAnggotaResponse.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnggotaUpdateResponseToJson(
        AnggotaUpdateResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'errors': instance.errors,
      'data': instance.data,
    };
