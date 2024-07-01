// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) => Request(
      method: $enumDecode(_$MethodEnumMap, json['method']),
      data: Absen.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'method': _$MethodEnumMap[instance.method]!,
      'data': instance.data,
    };

const _$MethodEnumMap = {
  Method.masuk: 'masuk',
  Method.pulang: 'pulang',
};
