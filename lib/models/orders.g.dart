// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Orders _$OrdersFromJson(Map<String, dynamic> json) => Orders(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      (json['member_id'] as num?)?.toInt(),
      (json['member_address_id'] as num?)?.toInt(),
      json['shipping_type'] as String?,
      json['payment_term'] as String?,
      json['date'] as String?,
      json['total_price'] as String?,
      json['note'] as String?,
      json['status'] as String?,
      json['member'] == null
          ? null
          : Member.fromJson(json['member'] as Map<String, dynamic>),
      (json['order_lists'] as List<dynamic>?)
          ?.map((e) => OrderLists.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrdersToJson(Orders instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'member_address_id': instance.member_address_id,
      'shipping_type': instance.shipping_type,
      'payment_term': instance.payment_term,
      'date': instance.date,
      'total_price': instance.total_price,
      'note': instance.note,
      'status': instance.status,
      'member': instance.member,
      'order_lists': instance.order_lists,
    };
