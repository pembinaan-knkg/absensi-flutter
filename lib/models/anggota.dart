import 'package:json_annotation/json_annotation.dart';

part 'anggota.g.dart';

@JsonSerializable()
class Anggota {
  Anggota({
    required this.username,
    required this.password,
  });

  final String username, password;

  factory Anggota.fromJson(Map<String, dynamic> json) =>
      _$AnggotaFromJson(json);
  Map<String, dynamic> toJson() => _$AnggotaToJson(this);
}
