// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_absen_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoAbsen _$InfoAbsenFromJson(Map<String, dynamic> json) => InfoAbsen(
      tanggal: DateTime.parse(json['tanggal'] as String),
      note: json['noteId'] as String,
      ket: json['ket'] as String?,
      masuk: json['absenMasuk'] == null
          ? null
          : AbsenData.fromJson(json['absenMasuk'] as Map<String, dynamic>),
      pulang: json['absenPulang'] == null
          ? null
          : AbsenData.fromJson(json['absenPulang'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InfoAbsenToJson(InfoAbsen instance) => <String, dynamic>{
      'tanggal': instance.tanggal.toIso8601String(),
      'ket': instance.ket,
      'noteId': instance.note,
      'absenMasuk': instance.masuk,
      'absenPulang': instance.pulang,
    };

ListAbsenResponse _$ListAbsenResponseFromJson(Map<String, dynamic> json) =>
    ListAbsenResponse(
      message: json['message'] as String,
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => InfoAbsen.fromJson(e as Map<String, dynamic>))
          .toList(),
      errors: json['errors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ListAbsenResponseToJson(ListAbsenResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'errors': instance.errors,
      'success': instance.success,
      'data': instance.data,
    };
