// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryorders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOrders _$DeliveryOrdersFromJson(Map<String, dynamic> json) =>
    DeliveryOrders(
      (json['No'] as num?)?.toInt(),
      json['code'] as String?,
      json['date'] as String?,
      (json['id'] as num?)?.toInt(),
      (json['packing_list_id'] as num?)?.toInt(),
      json['status'] as String?,
      (json['delivery_order_thai_lists'] as List<dynamic>?)
          ?.map((e) => DeliveryOrderThai.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['packing_list'] == null
          ? null
          : Packinglist.fromJson(json['packing_list'] as Map<String, dynamic>),
      json['member'] == null
          ? null
          : User.fromJson(json['member'] as Map<String, dynamic>),
      json['member_id'] as String?,
      json['note'] as String?,
      (json['order_id'] as num?)?.toInt(),
      json['order'] == null
          ? null
          : Orders.fromJson(json['order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeliveryOrdersToJson(DeliveryOrders instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'order_id': instance.order_id,
      'date': instance.date,
      'note': instance.note,
      'packing_list_id': instance.packing_list_id,
      'status': instance.status,
      'No': instance.No,
      'packing_list': instance.packing_list,
      'delivery_order_thai_lists': instance.delivery_order_thai_lists,
      'member': instance.member,
      'order': instance.order,
    };
