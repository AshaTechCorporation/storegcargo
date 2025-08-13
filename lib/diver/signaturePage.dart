import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/diver/signatureBigPage.dart';
import 'package:storegcargo/home/services/homeApi.dart';
import 'package:storegcargo/utils/toast_util.dart';
import 'package:storegcargo/widgets/LoadingDialog.dart';
import 'package:storegcargo/widgets/dialog.dart';
import 'package:storegcargo/upload/uploadService.dart';

class RefuelingPage extends StatefulWidget {
  RefuelingPage({super.key, required this.selectedDeliveryIds, required this.selectedImages});
  List<int> selectedDeliveryIds;
  List<Map<String, dynamic>> selectedImages;

  @override
  State<RefuelingPage> createState() => _RefuelingPageState();
}

class _RefuelingPageState extends State<RefuelingPage> {
  late GoogleMapController mapController;
  TextEditingController billpice = TextEditingController();
  final SignatureController _signatureController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  double? latitude;
  double? longitude;
  bool? isGPSEnabled;
  XFile? _image;
  List<XFile> listimage = [];
  Image? imageSignature;
  Uint8List? signatureBytes;
  String? base64Signature;
  StreamSubscription<Position>? positionStream;

  Future<String?> signatureToBase64(SignatureController? controller) async {
    if (controller!.isNotEmpty) {
      final ui.Image? image = await controller.toImage();
      final ByteData? byteData = await image!.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        return base64Encode(pngBytes);
      }
    }
    return null;
  }

  Future<void> openLocationSettings() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;

    if (permission.isGranted) {
      // ถ้ามีสิทธิ์แล้ว เช็คว่า GPS เปิดอยู่ไหม
      bool isGPSEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isGPSEnabled) {
        // ถ้า GPS ปิด -> เปิดหน้า Settings
        await Geolocator.openLocationSettings();
      } else {
        print("GPS เปิดอยู่แล้ว");
      }
    } else if (permission.isDenied) {
      // ถ้าถูกปฏิเสธ ให้ขอใหม่
      PermissionStatus newPermission = await Permission.locationWhenInUse.request();
      if (newPermission.isGranted) {
        // ถ้าได้รับสิทธิ์แล้ว ตรวจสอบ GPS อีกรอบ
        openLocationSettings();
      } else if (newPermission.isPermanentlyDenied) {
        // ถ้าผู้ใช้กด "Don't Ask Again" ให้ไปที่หน้า App Settings
        await openAppSettings();
      }
    } else if (permission.isPermanentlyDenied) {
      // ถ้าถูกปฏิเสธถาวร ให้ไปที่หน้า Settings
      await openAppSettings();
    }
  }

  Future<void> permissionHandler() async {
    await Permission.locationWhenInUse.request();
    await Permission.notification.request();
    PermissionStatus permission = await Permission.locationWhenInUse.status;
    if (permission.isGranted) {
      // ตรวจสอบว่า GPS เปิดหรือปิด
      isGPSEnabled = await Geolocator.isLocationServiceEnabled();
      if (isGPSEnabled!) {
        print("GPS เปิดอยู่");
      } else {
        print("GPS ปิดอยู่");
      }
    } else {
      isGPSEnabled = false;
      print("ไม่ได้รับอนุญาตให้ใช้ GPS");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
    listimage.add(_image!);
  }

  Future<void> _getCuttentLocation() async {
    LoadingDialog.open(context);
    final LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100);
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) async {
      // print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
      if (position == null) {
        LoadingDialog.close(context);
        await showDialog(
          context: context,
          builder:
              (context) => Dialogyes(
                title: 'แจ้งเตือน',
                description: 'ไม่พบ GPS',
                pressYes: () {
                  Navigator.pop(context, true);
                },
                bottomNameYes: 'ตกลง',
              ),
        );
      } else {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });
      }
    });
    LoadingDialog.close(context);
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  Future<void> saveSignature(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/signature.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    print('Saved at: $filePath');
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await permissionHandler();
      await _getCuttentLocation();
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: size.height * 0.1,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: kCardLine3Color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text('ลายเซ็น', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            isGPSEnabled == false
                ? Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('ตำแหน่ง ณ ปัจจุบัน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Center(child: Image.asset("assets/images/Nolocation.png", scale: 5)), Text("ไม่พบสัญญาณ GPS")],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: size.height * 0.07,
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kTextRedWanningColor,
                          // side: BorderSide(color: textColor),
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        onPressed: () async {
                          openLocationSettings();
                        },
                        child: Text('อนุญาตการเข้าถึงตำแหน่ง', style: TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    ),
                  ],
                )
                : latitude != null
                ? Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('ตำแหน่ง ณ ปัจจุบัน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(latitude!, longitude!), // พิกัดกรุงเทพฯ (สามารถรับค่าจาก API ได้)
                              zoom: 14.0,
                            ),
                            markers: {Marker(markerId: MarkerId("productLocation"), position: LatLng(latitude!, longitude!))},
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('ตำแหน่ง ณ ปัจจุบัน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
                        child: Center(
                          child: SizedBox(
                            width: 50, // ปรับขนาดตามต้องการ
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 4, // ปรับความหนาของเส้น
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(padding: const EdgeInsets.all(8.0), child: Text('ลายเซ็น', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                imageSignature != null
                    ? GestureDetector(
                      onTap: () async {
                        final out = await Navigator.push(context, MaterialPageRoute(builder: (context) => SignatureBigPage()));
                        if (out != null) {
                          // print(out['signature']);
                          imageSignature = out['signature'];
                          signatureBytes = out['bytes'];
                          print(imageSignature!.image);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: size.width * 0.3,
                          height: size.height * 0.05,
                          decoration: BoxDecoration(color: kButtonColor, borderRadius: BorderRadius.circular(6)),
                          child: Center(child: Text('แก้ไขลายเซ็น', style: TextStyle(color: Colors.white, fontSize: 16))),
                        ),
                      ),
                    )
                    : SizedBox.shrink(),
              ],
            ),
            imageSignature != null
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black), color: Colors.white),
                    child: Center(child: Image(image: imageSignature!.image)),
                  ),
                )
                : GestureDetector(
                  onTap: () async {
                    final out = await Navigator.push(context, MaterialPageRoute(builder: (context) => SignatureBigPage()));
                    if (out != null) {
                      // print(out['signature']);
                      imageSignature = out['signature'];
                      signatureBytes = out['bytes'];
                      print(imageSignature!.image);
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black), color: Colors.white),
                      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), Text('ลายเซ็น')])),
                    ),
                  ),
                ),

            SizedBox(height: 20),

            Container(
              height: size.height * 0.07,
              width: size.width * 0.5,
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  // side: BorderSide(color: textColor),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: () async {
                  await showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder:
                        (context) => CupertinoActionSheet(
                          actions: [
                            CupertinoActionSheetAction(
                              onPressed: () async {
                                _pickImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                              child: Text('ถ่ายรูป', style: TextStyle(fontSize: 25, color: Colors.grey)),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickMultiImage();
                                setState(() {
                                  listimage.addAll(pickedFile);
                                });
                                Navigator.pop(context);
                              },
                              child: Text('เลือกรูปจากอัลบั้ม', style: TextStyle(fontSize: 25, color: Colors.grey)),
                            ),
                          ],
                          cancelButton: TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'cancel');
                            },
                            child: Text('ยกเลิก', style: TextStyle(fontSize: 25, color: Colors.grey)),
                          ),
                        ),
                  );
                },
                child: Text('ถ่ายรูปหลักฐาน', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            SizedBox(height: 10),
            listimage.isEmpty
                ? SizedBox.shrink()
                : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      listimage.length,
                      (index) => Stack(
                        children: [
                          SizedBox(
                            height: size.height * 0.2,
                            child: Padding(padding: const EdgeInsets.all(8.0), child: Image.file(File(listimage[index].path))),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  listimage.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: size.height * 0.07,
            width: size.width * 0.4,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  // side: BorderSide(color: textColor),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: () async {
                  if (listimage.isNotEmpty && imageSignature != null) {
                    if (listimage.length >= 3) {
                      final ok = await showDialog(
                        context: context,
                        builder:
                            (context) => Dialogyesno(
                              title: 'แจ้งเตือน',
                              description: 'คุณต้องการ กดจบงาน หรือไม่',
                              pressYes: () {
                                Navigator.pop(context, true);
                              },
                              pressNo: () {
                                Navigator.pop(context, false);
                              },
                              bottomNameYes: 'ตกลง',
                              bottomNameNo: 'ยกเลิก',
                            ),
                      );
                      if (ok == true) {
                        if (signatureBytes != null) {
                          try {
                            LoadingDialog.open(context);
                            List<Map<String, dynamic>> imagesList = [];
                            for (var i = 0; i < listimage.length; i++) {
                              final _imageUpload = await UoloadService.uploadImage(listimage[i]);
                              final filename = _imageUpload.split('/').last;
                              Map<String, dynamic> newImg = {"image_url": "$baseUrl/$_imageUpload", "image": filename};
                              imagesList.add(newImg);
                            }
                            base64Signature = base64Encode(signatureBytes!);
                            final success = await HomeApi.deliveryOrdersThaiFinal(
                              delivery_order_thai_id: widget.selectedDeliveryIds[0],
                              signature: base64Signature!,
                              images: imagesList,
                            );
                            LoadingDialog.close(context);
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                          } on Exception catch (e) {
                            if (!mounted) return;
                            LoadingDialog.close(context);
                            ToastUtil.showToast(e.toString(), fontSize: 12, color: Colors.red, gravity: ToastGravity.BOTTOM);
                            print(e);
                          }
                        }
                      }
                    } else {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => Dialogyes(
                              title: 'แจ้งเตือน',
                              description: 'โปรดใส่รูปให้ครบ 3 รูปขึ้นไป',
                              pressYes: () {
                                Navigator.pop(context, true);
                              },
                              bottomNameYes: 'ตกลง',
                            ),
                      );
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder:
                          (context) => Dialogyes(
                            title: 'แจ้งเตือน',
                            description: 'โปรดใส่ข้อมูลให้ครบ',
                            pressYes: () {
                              Navigator.pop(context, true);
                            },
                            bottomNameYes: 'ตกลง',
                          ),
                    );

                    // Dialogyes
                  }
                },
                child: Text('จบงาน', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ลายเซ็น", style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _signatureController.clear(), // ✅ กดแล้วล้างลายเซ็น
                child: Text("Clear", style: TextStyle(color: kTextRedWanningColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 5),
          Container(
            height: 100,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Signature(controller: _signatureController, backgroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
