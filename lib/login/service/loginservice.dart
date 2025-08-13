import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/exceptione/apiexception.dart';

class LoginApi {
  const LoginApi();

  static Future login(String username, String password) async {
    final url = Uri.https(publicUrl, '/public/api/login');
    final response = await http.post(url, body: {'username': username, 'password': password});
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);

      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }
}
