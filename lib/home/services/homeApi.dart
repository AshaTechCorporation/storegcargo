import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/models/deliveryorders.dart';
import 'package:storegcargo/models/orders.dart';

class HomeApi {
  const HomeApi();

  static Future<List<Orders>> getOrders() async {
    final url = Uri.https(publicUrl, '/public/api/get_orders');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => Orders.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  static Future<List<DeliveryOrders>> getDeliveryOrders({required int page, required int length, String? search, String? status}) async {
    final url = Uri.https(publicUrl, '/public/api/delivery_orders_thai_page');
    // final token = prefs.getString('token');
    var headers = {
      // 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "draw": "0",
        "date": "",
        "status": "",
        "order": [
          {"column": 0, "dir": "asc"},
        ],
        "start": 0,
        "length": 10,
        "search": {"value": "", "regex": false},
      }),
    );
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data']['data'] as List;
      return list.map((e) => DeliveryOrders.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
      // throw ApiException(data['message']);
    }
  }

  // static Future<List<DeliveryOrders>> getDeliveryOrders() async {
  //   final url = Uri.https(publicUrl, '/api/get_delivery_orders_thai');
  //   var headers = {'Content-Type': 'application/json'};
  //   final response = await http.get(
  //     headers: headers,
  //     url,
  //   );
  //   if (response.statusCode == 200) {
  //     final data = convert.jsonDecode(response.body);
  //     final list = data['data'] as List;
  //     return list.map((e) => DeliveryOrders.fromJson(e)).toList();
  //   } else {
  //     final data = convert.jsonDecode(response.body);
  //     throw Exception(data['message']);
  //   }
  // }

  static Future<DeliveryOrders> getDeliveryOrdersId({required int id}) async {
    final url = Uri.https(publicUrl, '/public/api/delivery_orders_thai/$id');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return DeliveryOrders.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  static Future deliveryOrdersThaiFinal({
    required int delivery_order_thai_id,
    required String signature,
    required List<Map<String, dynamic>> images,
  }) async {
    final url = Uri.https(publicUrl, '/publicapi/delivery_orders_thai_final');
    var headers = {'Content-Type': 'application/json'};
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final userID = prefs.getInt('userID');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "delivery_order_thai_id": delivery_order_thai_id,
        "date": DateTime.now().toString(),
        "member_id": 9,
        "signature": signature, // base64 image
        "images": images,
      }),
    );

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }
}
