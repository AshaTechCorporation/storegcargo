import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storegcargo/home/lsitOrdersMap.dart';
import 'package:storegcargo/login/loginpage.dart';

String? token;
bool? remember;
late SharedPreferences prefs;
void main() async {
  // var result = await BarcodeScanner.scan();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPreferences.getInstance();
  prefs = await SharedPreferences.getInstance();
  token = prefs.getString('token');
  remember = prefs.getBool('remember');
  runApp(const MyApp());

  // BackgroundLocation.startLocationService(distanceFilter: 10);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontFamily: 'SukhumvitSet', fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        fontFamily: 'SukhumvitSet',
      ),
      home: token == null ? Loginpage() : ListOrdersMapPage(),
      // HomePage(),
    );
  }
}
