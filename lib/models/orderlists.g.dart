// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orderlists.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderLists _$OrderListsFromJson(Map<String, dynamic> json) => OrderLists(
      (json['id'] as num?)?.toInt(),
      json['track_ecommerce_no'] as String?,
      (json['order_id'] as num?)?.toInt(),
      json['product_code'] as String?,
      json['product_name'] as String?,
      json['product_url'] as String?,
      json['product_image'] as String?,
      json['product_category'] as String?,
      json['product_store_type'] as String?,
      json['product_note'] as String?,
      json['product_price'] as String?,
      (json['product_qty'] as num?)?.toInt(),
      json['status'] as String?,
    );

Map<String, dynamic> _$OrderListsToJson(OrderLists instance) =>
    <String, dynamic>{
      'id': instance.id,
      'track_ecommerce_no': instance.track_ecommerce_no,
      'order_id': instance.order_id,
      'product_code': instance.product_code,
      'product_name': instance.product_name,
      'product_url': instance.product_url,
      'product_image': instance.product_image,
      'product_category': instance.product_category,
      'product_store_type': instance.product_store_type,
      'product_note': instance.product_note,
      'product_price': instance.product_price,
      'product_qty': instance.product_qty,
      'status': instance.status,
    };
