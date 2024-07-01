import 'package:json_annotation/json_annotation.dart';
import 'package:magang_absen/models/anggota.dart';
import 'package:magang_absen/models/foto.dart';
import 'package:magang_absen/models/location.dart';

part 'absen.g.dart';

@JsonSerializable()
class Absen {
  Absen({
    required this.anggota,
    required this.location,
    this.pict,
  });

  final Anggota anggota;
  final Location location;
  final FotoData? pict;

  factory Absen.fromJson(Map<String, dynamic> json) => _$AbsenFromJson(json);
  Map<String, dynamic> toJson() => _$AbsenToJson(this);
}
