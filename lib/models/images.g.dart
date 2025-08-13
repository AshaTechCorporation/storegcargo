// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Imagess _$ImagessFromJson(Map<String, dynamic> json) => Imagess(
      (json['delivery_order_th_ls_id'] as num?)?.toInt(),
      (json['id'] as num?)?.toInt(),
      json['image'] as String?,
      json['image_url'] as String?,
    );

Map<String, dynamic> _$ImagessToJson(Imagess instance) => <String, dynamic>{
      'id': instance.id,
      'delivery_order_th_ls_id': instance.delivery_order_th_ls_id,
      'image_url': instance.image_url,
      'image': instance.image,
    };
