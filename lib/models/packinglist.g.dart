// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packinglist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Packinglist _$PackinglistFromJson(Map<String, dynamic> json) => Packinglist(
      json['closing_date'] as String?,
      json['code'] as String?,
      json['container_no'] as String?,
      json['destination'] as String?,
      json['estimated_arrival_date'] as String?,
      (json['id'] as num?)?.toInt(),
      json['packinglist_no'] as String?,
      json['remark'] as String?,
      json['shipping_china'] as String?,
      json['shipping_thailand'] as String?,
      json['transport_by'] as String?,
      json['truck_license_plate'] as String?,
    );

Map<String, dynamic> _$PackinglistToJson(Packinglist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'packinglist_no': instance.packinglist_no,
      'container_no': instance.container_no,
      'truck_license_plate': instance.truck_license_plate,
      'closing_date': instance.closing_date,
      'estimated_arrival_date': instance.estimated_arrival_date,
      'shipping_china': instance.shipping_china,
      'shipping_thailand': instance.shipping_thailand,
      'transport_by': instance.transport_by,
      'destination': instance.destination,
      'remark': instance.remark,
    };
