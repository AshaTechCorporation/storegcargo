import 'package:json_annotation/json_annotation.dart';

part 'orderlists.g.dart';

@JsonSerializable()
class OrderLists {
  int? id;
  String? track_ecommerce_no;
  int? order_id;
  String? product_code;
  String? product_name;
  String? product_url;
  String? product_image;
  String? product_category;
  String? product_store_type;
  String? product_note;
  String? product_price;
  int? product_qty;
  String? status;

  OrderLists(
    this.id,
    this.track_ecommerce_no,
    this.order_id,
    this.product_code,
    this.product_name,
    this.product_url,
    this.product_image,
    this.product_category,
    this.product_store_type,
    this.product_note,
    this.product_price,
    this.product_qty,
    this.status,
  );

  factory OrderLists.fromJson(Map<String, dynamic> json) => _$OrderListsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderListsToJson(this);
}
