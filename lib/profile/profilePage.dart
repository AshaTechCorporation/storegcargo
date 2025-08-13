import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/widgets/dialog.dart';
import 'package:storegcargo/login/loginpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? email;
  String? phone;

  Future preferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    email = prefs.getString('email');
    phone = prefs.getString('phone');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await preferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[300]),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/Avatar3.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/Avatar3.png', fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            SizedBox(height: size.height * 0.04),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(""), SizedBox(width: 10), Text("")],
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('ชื่อ - นามสกุล', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400)),
              trailing: Text(
                name ?? "", // "${profile?.firstname ?? '-'} ${profile?.lastname ?? '-'}",
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ListTile(
              title: Text('เบอร์ติดต่อ', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400)),
              trailing: Text(formatPhoneNumber(phone ?? "-"), style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            ListTile(
              title: Text('อีเมล', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400)),
              trailing: Text('${email ?? 'xxx@gmail.com'} ', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Padding(padding: const EdgeInsets.only(left: 15, right: 15), child: Divider()),
            SizedBox(height: size.height * 0.02),
            InkWell(
              onTap: () async {
                final out = await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder:
                      (context) => Dialogyesno(
                        title: 'แจ้งเตือน',
                        description: 'ออกจากระบบ',
                        pressYes: () {
                          Navigator.pop(context, true);
                        },
                        bottomNameYes: 'ยืนยัน',
                        pressNo: () {
                          Navigator.pop(context, false);
                        },
                        bottomNameNo: 'ยกเลิก',
                      ),
                );
                if (out == true) {
                  await clearToken();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Loginpage()), (route) => false);
                }
              },
              child: Container(
                // margin: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                width: size.width * 0.9,
                height: size.height * 0.055,
                decoration: BoxDecoration(
                  // color: kMainColor,
                  border: Border.all(color: kTextRedWanningColor),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Center(child: Text('ออกจากระบบ', style: TextStyle(color: kTextRedWanningColor, fontSize: 20, fontWeight: FontWeight.w500))),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> clearToken() async {
    final _prefs = await SharedPreferences.getInstance();
    SharedPreferences prefs = _prefs;
    prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('remember');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('phone');
  }
}

// ProfilePage
