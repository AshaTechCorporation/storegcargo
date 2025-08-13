import 'package:json_annotation/json_annotation.dart';
import 'package:storegcargo/models/packinglist.dart';
import 'package:storegcargo/models/user.dart';
import 'package:storegcargo/models/orders.dart';
import 'package:storegcargo/models/deliveryorderthai.dart';

part 'deliveryorders.g.dart';

@JsonSerializable()
class DeliveryOrders {
  int? id;
  String? code;
  String? member_id;
  int? order_id;
  String? date;
  String? note;
  int? packing_list_id;
  String? status;
  int? No;
  Packinglist? packing_list;
  List<DeliveryOrderThai>? delivery_order_thai_lists;
  User? member;
  Orders? order;

  DeliveryOrders(
    this.No,
    this.code,
    this.date,
    this.id,
    this.packing_list_id,
    this.status,
    this.delivery_order_thai_lists,
    this.packing_list,
    this.member,
    this.member_id,
    this.note,
    this.order_id,
    this.order,
  );

  factory DeliveryOrders.fromJson(Map<String, dynamic> json) => _$DeliveryOrdersFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOrdersToJson(this);
}
