import 'package:json_annotation/json_annotation.dart';

part 'packinglist.g.dart';

@JsonSerializable()
class Packinglist {
  int? id;
  String? code;
  String? packinglist_no;
  String? container_no;
  String? truck_license_plate;
  String? closing_date;
  String? estimated_arrival_date;
  String? shipping_china;
  String? shipping_thailand;
  String? transport_by;
  String? destination;
  String? remark;

  Packinglist(
    this.closing_date,
    this.code,
    this.container_no,
    this.destination,
    this.estimated_arrival_date,
    this.id,
    this.packinglist_no,
    this.remark,
    this.shipping_china,
    this.shipping_thailand,
    this.transport_by,
    this.truck_license_plate
  );

  factory Packinglist.fromJson(Map<String, dynamic> json) => _$PackinglistFromJson(json);

  Map<String, dynamic> toJson() => _$PackinglistToJson(this);
}
