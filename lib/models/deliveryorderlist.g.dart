// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryorderlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOrderlist _$DeliveryOrderlistFromJson(Map<String, dynamic> json) =>
    DeliveryOrderlist(
      json['code'] as String?,
      (json['delivery_order_id'] as num?)?.toInt(),
      (json['delivery_order_tracking_id'] as num?)?.toInt(),
      json['height'] as String?,
      (json['id'] as num?)?.toInt(),
      json['long'] as String?,
      (json['pallet_id'] as num?)?.toInt(),
      (json['product_draft_id'] as num?)?.toInt(),
      json['product_image'] as String?,
      json['product_name'] as String?,
      (json['product_type_id'] as num?)?.toInt(),
      (json['qty'] as num?)?.toInt(),
      (json['qty_box'] as num?)?.toInt(),
      (json['sack_id'] as num?)?.toInt(),
      (json['standard_size_id'] as num?)?.toInt(),
      json['weight'] as String?,
      json['width'] as String?,
    );

Map<String, dynamic> _$DeliveryOrderlistToJson(DeliveryOrderlist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'product_draft_id': instance.product_draft_id,
      'delivery_order_id': instance.delivery_order_id,
      'delivery_order_tracking_id': instance.delivery_order_tracking_id,
      'product_type_id': instance.product_type_id,
      'product_name': instance.product_name,
      'product_image': instance.product_image,
      'standard_size_id': instance.standard_size_id,
      'weight': instance.weight,
      'width': instance.width,
      'height': instance.height,
      'long': instance.long,
      'qty': instance.qty,
      'qty_box': instance.qty_box,
      'pallet_id': instance.pallet_id,
      'sack_id': instance.sack_id,
    };
