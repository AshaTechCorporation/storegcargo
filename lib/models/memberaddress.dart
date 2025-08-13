import 'package:json_annotation/json_annotation.dart';

part 'memberaddress.g.dart';

@JsonSerializable()
class MemberAddress {
  int? id;
  String? code;
  int? member_id;
  String? address;
  String? province;
  String? district;
  String? sub_district;
  String? postal_code;
  String? latitude;
  String? longitude;
  String? contact_name;
  String? contact_phone;
  String? contact_phone2;
  String? status;

  MemberAddress(this.address, this.code, this.contact_name, this.contact_phone, this.contact_phone2, this.district, this.id, this.latitude,
      this.longitude, this.member_id, this.postal_code, this.province, this.status, this.sub_district);

  factory MemberAddress.fromJson(Map<String, dynamic> json) => _$MemberAddressFromJson(json);

  Map<String, dynamic> toJson() => _$MemberAddressToJson(this);
}
