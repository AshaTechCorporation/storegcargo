// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberaddress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberAddress _$MemberAddressFromJson(Map<String, dynamic> json) =>
    MemberAddress(
      json['address'] as String?,
      json['code'] as String?,
      json['contact_name'] as String?,
      json['contact_phone'] as String?,
      json['contact_phone2'] as String?,
      json['district'] as String?,
      (json['id'] as num?)?.toInt(),
      json['latitude'] as String?,
      json['longitude'] as String?,
      (json['member_id'] as num?)?.toInt(),
      json['postal_code'] as String?,
      json['province'] as String?,
      json['status'] as String?,
      json['sub_district'] as String?,
    );

Map<String, dynamic> _$MemberAddressToJson(MemberAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'address': instance.address,
      'province': instance.province,
      'district': instance.district,
      'sub_district': instance.sub_district,
      'postal_code': instance.postal_code,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'contact_name': instance.contact_name,
      'contact_phone': instance.contact_phone,
      'contact_phone2': instance.contact_phone2,
      'status': instance.status,
    };
