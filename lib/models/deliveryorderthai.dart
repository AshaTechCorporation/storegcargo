import 'package:json_annotation/json_annotation.dart';
import 'package:storegcargo/models/deliveryorderlist.dart';
import 'package:storegcargo/models/deliveryorders.dart';
import 'package:storegcargo/models/images.dart';

part 'deliveryorderthai.g.dart';

@JsonSerializable()
class DeliveryOrderThai {
  int? id;
  int? delivery_order_thai_id;
  int? delivery_order_id;
  int? delivery_order_list_id;
  int? order_id;
  int? member_id;
  int? member_address_id;
  DeliveryOrders? delivery_order;
  DeliveryOrderlist? delivery_order_list;
  List<Imagess>? images;

  DeliveryOrderThai(
    this.delivery_order_id,
    this.delivery_order_list_id,
    this.delivery_order_thai_id,
    this.id,
    this.member_address_id,
    this.member_id,
    this.order_id,
    this.delivery_order,
    this.delivery_order_list,
    this.images,
  );

  factory DeliveryOrderThai.fromJson(Map<String, dynamic> json) => _$DeliveryOrderThaiFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOrderThaiToJson(this);
}
