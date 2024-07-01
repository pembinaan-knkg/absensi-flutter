// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Absen _$AbsenFromJson(Map<String, dynamic> json) => Absen(
      anggota: Anggota.fromJson(json['anggota'] as Map<String, dynamic>),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      pict: json['pict'] == null
          ? null
          : FotoData.fromJson(json['pict'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AbsenToJson(Absen instance) => <String, dynamic>{
      'anggota': instance.anggota,
      'location': instance.location,
      'pict': instance.pict,
    };
