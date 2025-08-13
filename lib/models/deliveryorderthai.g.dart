// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryorderthai.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOrderThai _$DeliveryOrderThaiFromJson(Map<String, dynamic> json) =>
    DeliveryOrderThai(
      (json['delivery_order_id'] as num?)?.toInt(),
      (json['delivery_order_list_id'] as num?)?.toInt(),
      (json['delivery_order_thai_id'] as num?)?.toInt(),
      (json['id'] as num?)?.toInt(),
      (json['member_address_id'] as num?)?.toInt(),
      (json['member_id'] as num?)?.toInt(),
      (json['order_id'] as num?)?.toInt(),
      json['delivery_order'] == null
          ? null
          : DeliveryOrders.fromJson(
              json['delivery_order'] as Map<String, dynamic>),
      json['delivery_order_list'] == null
          ? null
          : DeliveryOrderlist.fromJson(
              json['delivery_order_list'] as Map<String, dynamic>),
      (json['images'] as List<dynamic>?)
          ?.map((e) => Imagess.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeliveryOrderThaiToJson(DeliveryOrderThai instance) =>
    <String, dynamic>{
      'id': instance.id,
      'delivery_order_thai_id': instance.delivery_order_thai_id,
      'delivery_order_id': instance.delivery_order_id,
      'delivery_order_list_id': instance.delivery_order_list_id,
      'order_id': instance.order_id,
      'member_id': instance.member_id,
      'member_address_id': instance.member_address_id,
      'delivery_order': instance.delivery_order,
      'delivery_order_list': instance.delivery_order_list,
      'images': instance.images,
    };
