// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absen_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsenData _$AbsenDataFromJson(Map<String, dynamic> json) => AbsenData(
      time: DateTime.parse(json['time'] as String),
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      foto: json['foto'] == null
          ? null
          : Foto.fromJson(json['foto'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AbsenDataToJson(AbsenData instance) => <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'foto': instance.foto,
    };

AbsenResponse _$AbsenResponseFromJson(Map<String, dynamic> json) =>
    AbsenResponse(
      sudahAbsen: json['sudahAbsen'] as bool? ?? false,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : AbsenData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AbsenResponseToJson(AbsenResponse instance) =>
    <String, dynamic>{
      'sudahAbsen': instance.sudahAbsen,
      'message': instance.message,
      'data': instance.data,
    };
