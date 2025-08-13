import 'package:json_annotation/json_annotation.dart';

part 'deliveryorderlist.g.dart';

@JsonSerializable()
class DeliveryOrderlist {
  int? id;
  String? code;
  int? product_draft_id;
  int? delivery_order_id;
  int? delivery_order_tracking_id;
  int? product_type_id;
  String? product_name;
  String? product_image;
  int? standard_size_id;
  String? weight;
  String? width;
  String? height;
  String? long;
  int? qty;
  int? qty_box;
  int? pallet_id;
  int? sack_id;

  DeliveryOrderlist(
    this.code,
    this.delivery_order_id,
    this.delivery_order_tracking_id,
    this.height,
    this.id,
    this.long,
    this.pallet_id,
    this.product_draft_id,
    this.product_image,
    this.product_name,
    this.product_type_id,
    this.qty,
    this.qty_box,
    this.sack_id,
    this.standard_size_id,
    this.weight,
    this.width
  );

  factory DeliveryOrderlist.fromJson(Map<String, dynamic> json) => _$DeliveryOrderlistFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOrderlistToJson(this);
}
