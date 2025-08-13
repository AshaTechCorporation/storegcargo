import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/exceptione/apiexception.dart';
import 'package:storegcargo/home/lsitOrdersMap.dart';
import 'package:storegcargo/login/service/loginservice.dart';
import 'package:storegcargo/widgets/InputTextFormField.dart';
import 'package:storegcargo/widgets/LoadingDialog.dart';
import 'package:storegcargo/widgets/dialog.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscureText = true;
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kButtondiableColor,
      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: height(context) / 5.5)),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                height: size.height * 0.7,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    SizedBox(height: 150, width: 150, child: Image.asset('assets/icons/Logo.png', scale: 1, fit: BoxFit.fill)),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text('Sign in', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Text('Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ],
                        ),
                        InputTextFormField(width: size.width * 0.8, fillcolor: Colors.white, controller: username),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ],
                        ),
                        InputTextFormField(
                          width: size.width * 0.8,
                          controller: password,
                          obscureText: _obscureText,
                          fillcolor: Colors.white,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Checkbox(
                    //           value: isChecked,
                    //           onChanged: (bool? value) {
                    //             setState(() {
                    //               isChecked = value ?? false;
                    //             });
                    //           },
                    //         ),
                    //         SizedBox(width: 2), // ระยะห่างระหว่าง Text กับ Checkbox
                    //         Text("Remember Me"),
                    //       ],
                    //     ),
                    //     SizedBox(
                    //       width: size.width * 0.18,
                    //     ),
                    //     Text(
                    //       'forget password?',
                    //       style: TextStyle(
                    //         color: red1,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    SizedBox(height: size.height * 0.03),

                    Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: InkWell(
                          onTap: () async {
                            if (password.text == '' || username.text == '') {
                              await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder:
                                    (context) => Dialogyes(
                                      description: 'กรุณากรอกข้อมูลให้ครบ',
                                      pressYes: () {
                                        Navigator.pop(context);
                                      },
                                      title: 'แจ้งเตือน',
                                      bottomNameYes: 'ตกลง',
                                    ),
                              );
                            } else {
                              try {
                                LoadingDialog.open(context);
                                final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                                final login = await LoginApi.login(username.text, password.text);
                                final SharedPreferences prefs = await _prefs;
                                await prefs.setString('token', login['token']);
                                await prefs.setString('name', login['data']['name']);
                                await prefs.setString('email', login['data']['email']);
                                await prefs.setString('phone', login['data']['phone']);
                                // await prefs.setString('image', login['data']['image']);
                                await prefs.setBool('remember', isChecked);

                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ListOrdersMapPage()), (route) => false);
                              } on ApiException catch (e) {
                                LoadingDialog.close(context);
                                await showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder:
                                      (context) => Dialogyes(
                                        description: '${e}',
                                        pressYes: () {
                                          Navigator.pop(context);
                                        },
                                        title: 'แจ้งเตือน',
                                        bottomNameYes: 'ตกลง',
                                      ),
                                );
                              }
                            }
                          },
                          child: BottomNavigator(size: size, title: 'Sign in'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigator extends StatelessWidget {
  const BottomNavigator({super.key, required this.size, required this.title});

  final Size size;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.06,
      decoration: BoxDecoration(color: kButtonColor, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
    );
  }
}
