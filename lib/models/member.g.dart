// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      json['member_type'] as String?,
      json['fname'] as String?,
      json['lname'] as String?,
      json['phone'] as String?,
      json['birth_date'] as String?,
      json['gender'] as String?,
      json['importer_code'] as String?,
      json['password'] as String?,
      json['referrer'] as String?,
      json['address'] as String?,
      json['province'] as String?,
      json['district'] as String?,
      json['sub_district'] as String?,
      json['postal_code'] as String?,
      json['wallet_balance'] as String?,
      json['point_balance'] as String?,
      json['image'] as String?,
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_type': instance.member_type,
      'fname': instance.fname,
      'lname': instance.lname,
      'phone': instance.phone,
      'birth_date': instance.birth_date,
      'gender': instance.gender,
      'importer_code': instance.importer_code,
      'password': instance.password,
      'referrer': instance.referrer,
      'address': instance.address,
      'province': instance.province,
      'district': instance.district,
      'sub_district': instance.sub_district,
      'postal_code': instance.postal_code,
      'wallet_balance': instance.wallet_balance,
      'point_balance': instance.point_balance,
      'image': instance.image,
    };
