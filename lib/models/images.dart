
import 'package:json_annotation/json_annotation.dart';

part 'images.g.dart';

@JsonSerializable()
class Imagess {
  int? id;
  int? delivery_order_th_ls_id;
  String? image_url;
  String? image;

  Imagess(
    this.delivery_order_th_ls_id,
    this.id,
    this.image,
    this.image_url
  );

  factory Imagess.fromJson(Map<String, dynamic> json) => _$ImagessFromJson(json);

  Map<String, dynamic> toJson() => _$ImagessToJson(this);
}
