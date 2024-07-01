// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FotoData _$FotoDataFromJson(Map<String, dynamic> json) => FotoData(
      downloadURL: json['downloadURL'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$FotoDataToJson(FotoData instance) => <String, dynamic>{
      'downloadURL': instance.downloadURL,
      'path': instance.path,
      'name': instance.name,
    };

Foto _$FotoFromJson(Map<String, dynamic> json) => Foto(
      pict: FotoData.fromJson(json['pict'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FotoToJson(Foto instance) => <String, dynamic>{
      'pict': instance.pict,
    };
