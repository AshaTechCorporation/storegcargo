import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';
import 'package:storegcargo/constants.dart';

class SignatureBigPage extends StatefulWidget {
  const SignatureBigPage({super.key});

  @override
  State<SignatureBigPage> createState() => _SignatureBigPageState();
}

class _SignatureBigPageState extends State<SignatureBigPage> {
  final SignatureController _signatureController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  Uint8List? signature;
  Image? imageSignature;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ลายเซ็น", style: TextStyle(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => _signatureController.clear(),
                      child: Text("Clear", style: TextStyle(color: kTextRedWanningColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: size.height * 0.65,
                  decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Signature(controller: _signatureController, backgroundColor: Colors.white),
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                    signature = await _signatureController.toPngBytes();
                    if (signature != null) {
                      imageSignature = Image.memory(signature!, width: 10);

                      Navigator.pop(context, {'signature': imageSignature, 'bytes': signature});
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: size.width * 0.4,
                    height: size.height * 0.14,
                    decoration: BoxDecoration(color: kTextRedWanningColor, borderRadius: BorderRadius.circular(15)),
                    child: Center(child: Text('ตกลง', style: TextStyle(color: Colors.white, fontSize: 20))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildSignatureField() {
  //   final size = MediaQuery.of(context).size;
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text("ลายเซ็น", style: TextStyle(fontWeight: FontWeight.bold)),
  //             GestureDetector(
  //               onTap: () => _signatureController.clear(),
  //               child: Text("Clear", style: TextStyle(color: red1, fontWeight: FontWeight.bold)),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 5),
  //         Container(
  //           height: size.height * 0.6,
  //           decoration: BoxDecoration(border: Border.all(color: Colors.black)),
  //           child: Signature(
  //             controller: _signatureController,
  //             backgroundColor: Colors.white,
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: () async {
  //             SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //             signature = await _signatureController.toPngBytes();
  //             if (signature != null) {
  //               imageSignature = Image.memory(signature!, width: 10);

  //               Navigator.pop(context, {'signature': imageSignature});
  //             }
  //           },
  //           child: Container(
  //             padding: EdgeInsets.all(8),
  //             width: double.infinity,
  //             height: size.height * 0.08,
  //             decoration: BoxDecoration(
  //               color: red1,
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 'ตกลง',
  //                 style: TextStyle(color: Colors.white, fontSize: 20),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
