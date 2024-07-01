import 'package:json_annotation/json_annotation.dart';

part 'foto.g.dart';

@JsonSerializable()
class FotoData {
  FotoData({
    required this.downloadURL,
    required this.path,
    required this.name,
  });

  final String downloadURL, path, name;

  factory FotoData.fromJson(Map<String, dynamic> json) =>
      _$FotoDataFromJson(json);
  Map<String, dynamic> toJson() => _$FotoDataToJson(this);
}

@JsonSerializable()
class Foto {
  Foto({required this.pict});

  final FotoData pict;

  factory Foto.fromJson(Map<String, dynamic> json) => _$FotoFromJson(json);
  Map<String, dynamic> toJson() => _$FotoToJson(this);
}
