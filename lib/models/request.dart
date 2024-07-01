import 'package:json_annotation/json_annotation.dart';
import 'package:magang_absen/models/absen.dart';

part 'request.g.dart';

enum Method {
  masuk,
  pulang;
}

@JsonSerializable()
class Request {
  Request({
    required this.method,
    required this.data,
  });

  final Method method;
  final Absen data;

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
