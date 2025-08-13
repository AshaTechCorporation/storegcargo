import 'package:json_annotation/json_annotation.dart';
import 'package:storegcargo/models/member.dart';
import 'package:storegcargo/models/orderlists.dart';

part 'orders.g.dart';

@JsonSerializable()
class Orders {
  int? id;
  String? code;
  int? member_id;
  int? member_address_id;
  String? shipping_type;
  String? payment_term;
  String? date;
  String? total_price;
  String? note;
  String? status;
  Member? member;
  List<OrderLists>? order_lists;

  Orders(
    this.id,
    this.code,
    this.member_id,
    this.member_address_id,
    this.shipping_type,
    this.payment_term,
    this.date,
    this.total_price,
    this.note,
    this.status,
    this.member,
    this.order_lists,
  );

  factory Orders.fromJson(Map<String, dynamic> json) => _$OrdersFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersToJson(this);
}
