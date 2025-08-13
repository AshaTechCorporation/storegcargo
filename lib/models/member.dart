import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

@JsonSerializable()
class Member {
  int? id;
  String? code;
  String? member_type;
  String? fname;
  String? lname;
  String? phone;
  String? birth_date;
  String? gender;
  String? importer_code;
  String? password;
  String? referrer;
  String? address;
  String? province;
  String? district;
  String? sub_district;
  String? postal_code;
  String? wallet_balance;
  String? point_balance;
  String? image;

  Member(
    this.id,
    this.code,
    this.member_type,
    this.fname,
    this.lname,
    this.phone,
    this.birth_date,
    this.gender,
    this.importer_code,
    this.password,
    this.referrer,
    this.address,
    this.province,
    this.district,
    this.sub_district,
    this.postal_code,
    this.wallet_balance,
    this.point_balance,
    this.image,
  );

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}
