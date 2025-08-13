import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/diver/customerProduct.dart';
import 'package:storegcargo/home/detailPage.dart';
import 'package:storegcargo/home/services/homeApi.dart';
import 'package:storegcargo/login/loginpage.dart';
import 'package:storegcargo/models/deliveryorders.dart';
import 'package:storegcargo/models/orders.dart';
import 'package:storegcargo/profile/profilePage.dart';
import 'package:storegcargo/utils/toast_util.dart';
import 'package:storegcargo/widgets/LoadingDialog.dart';
import 'package:storegcargo/widgets/dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SignatureController _signatureController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  List<Orders> orders = [];
  ImagePicker picker = ImagePicker();
  File? _image;
  final ScrollController _scrollController = ScrollController();
  List<DeliveryOrders> deliveryOrders = [];
  List<DeliveryOrders> deliveryCompleted = [];
  bool? isGPSEnabled;

  // ✅ UI ของรายการส่งพัสดุ
  Widget _buildDeliveryCard(Orders order, int index, Size size) {
    return GestureDetector(
      onTap: () async {
        _signatureController.clear();
        setState(() {
          _image = null;
        });
        //_showChangeStatusDialog(order, index, size);
        final check = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(order: order)));
        if (check == true) {
          await getlistOrder();
        }
        // if (index == 0) {
        //   // _showParcelDialog(
        //   //     delivery); // กดไอเทมตัวแรกให้ขึ้น Dialog "Parcel Info"
        // } else if (index == 1) {
        //   _showChangeStatusDialog(); // กดไอเทมที่สองให้ขึ้น Dialog "Change Status"
        // }
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 10),
              // ✅ รายละเอียดพัสดุ
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.code ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(order.date ?? '', style: TextStyle(color: Colors.black54)),
                    SizedBox(height: 4),
                    Text(order.shipping_type ?? '', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    SizedBox(height: 4),
                    Text(order.total_price ?? '0', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // ✅ แสดงรูปด้านขวา
              Expanded(
                flex: 5,
                child:
                    order.order_lists!.isEmpty
                        ? SizedBox()
                        : order.order_lists![0].product_image == null
                        ? Image.asset('assets/images/noimages.jpg', height: size.height * 0.08, width: size.width * 0.05, fit: BoxFit.fill)
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            height: size.height * 0.08,
                            width: size.width * 0.05,
                            imageUrl: "${order.order_lists![0].product_image!}",
                            fit: BoxFit.contain,
                            placeholder: (context, url) => SizedBox(child: CircularProgressIndicator(strokeWidth: 1)),
                            errorWidget:
                                (context, url, error) =>
                                    Image.asset('assets/images/noimages.jpg', fit: BoxFit.fill, height: size.height * 0.08, width: size.width * 0.05),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //await getlistOrder();
      await permissionHandler();
      await getlistOrderDelivery();
    });
  }

  Future<void> getlistOrder() async {
    try {
      LoadingDialog.open(context);
      final _orders = await HomeApi.getOrders();
      if (!mounted) return;

      setState(() {
        orders = _orders;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(0.0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          }
        });
      });

      LoadingDialog.close(context);
    } on Exception catch (e) {
      if (!mounted) return;
      LoadingDialog.close(context);
      print(e);
    }
  }

  Future<void> getlistOrderDelivery() async {
    try {
      LoadingDialog.open(context);
      final _orders = await HomeApi.getDeliveryOrders(page: 1, length: 10);
      if (!mounted) return;

      // final completed = _orders.where((order) => order.status == 'awaiting_payment').toList();
      // final others = _orders.where((order) => order.status == 'delivered').toList();
      final completed = _orders.where((order) => order.status == 'delivered').toList();
      final others = _orders.where((order) => order.status == 'paid').toList();

      setState(() {
        deliveryCompleted = completed;
        deliveryOrders = others;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(0.0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          }
        });
      });

      LoadingDialog.close(context);
    } on Exception catch (e) {
      if (!mounted) return;
      LoadingDialog.close(context);
      ToastUtil.showToast(e.toString(), fontSize: 12, color: Colors.red, gravity: ToastGravity.BOTTOM);
      print(e);
    }
  }

  // Future<void> getlistOrderDelivery() async {
  //   try {
  //     LoadingDialog.open(context);
  //     final _orders = await HomeApi.getDeliveryOrders();
  //     if (!mounted) return;

  //     setState(() {
  //       deliveryOrders = _orders;
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (_scrollController.hasClients) {
  //           _scrollController.animateTo(
  //             0.0,
  //             duration: Duration(milliseconds: 500),
  //             curve: Curves.easeInOut,
  //           );
  //         }
  //       });
  //     });

  //     LoadingDialog.close(context);
  //   } on Exception catch (e) {
  //     if (!mounted) return;
  //     LoadingDialog.close(context);
  //     print(e);
  //   }
  // }

  Future openDialogImage() async {
    final img = await picker.pickImage(source: ImageSource.camera);
    return img;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kTextRedWanningColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("รายการจัดส่ง", style: TextStyle(color: Colors.white, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "รายชื่อการจัดส่ง"),
            Tab(text: "จัดส่งสำเร็จ"),
            // Tab(text: "สินค้าตีกลับ"),
            // Tab(text: "ส่งแล้ว"),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: kTextRedWanningColor),
              child: Row(
                children: [
                  Image.asset('assets/images/Logo_White.png', scale: 2),
                  SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: []),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ProfilePage()), (route) => false);
              },
            ),
            ListTile(
              leading: Icon(Icons.output_outlined),
              title: Text('Logout'),
              onTap: () async {
                final ok = await showDialog(
                  context: context,
                  builder:
                      (context) => Dialogyesno(
                        title: 'แจ้งเตือน',
                        description: 'คุณต้องการออกจากระบบหรือไม่',
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
                  await clearToken();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Loginpage()), (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      // body: Diverpage(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Center(
          //     child: Diverpage(
          //   deliveryOrders: deliveryOrders,
          // )),
          deliveryOrders.isEmpty
              ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text('ไม่พบข้อมูล')])
              : ListView.builder(
                itemCount: deliveryOrders.length,
                itemBuilder: (context, index) {
                  return _buildDeliveryInfoCard(deliveryOrders[index], MediaQuery.of(context).size);
                },
              ),

          deliveryCompleted.isEmpty
              ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text('ไม่พบข้อมูล')])
              : ListView.builder(
                itemCount: deliveryCompleted.length,
                itemBuilder: (context, index) {
                  return _buildDeliveryInfoCard(deliveryCompleted[index], MediaQuery.of(context).size);
                },
              ),

          // Center(
          //     child: Diverpage(
          //   deliveryOrders: deliveryCompleted,
          // )),
          // orders.isEmpty
          //     ? SizedBox()
          //     : SingleChildScrollView(
          //         controller: _scrollController,
          //         child: ListView.builder(
          //           itemCount: orders.length,
          //           shrinkWrap: true,
          //           physics: ClampingScrollPhysics(),
          //           itemBuilder: (context, index) => _buildDeliveryCard(orders[index], index, size),
          //         ),
          //       ),
          // Center(child: Text("Return Orders")),
          // Center(child: Text("Delivered Orders")),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(DeliveryOrders order, Size size) {
    final packing = order.packing_list;

    return GestureDetector(
      onTap: () async {
        final success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CustomerProduct(
                  namecustomer: packing!.code!,
                  addess: packing.container_no!,
                  phone: packing.container_no!,
                  email: packing.packinglist_no!,
                  code: packing.shipping_china!,
                  deliveryId: order.id!,
                  order: order,
                ),
          ),
        );
        if (success == true) {
          await getlistOrderDelivery();
        }
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.code ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('วันที่: ${order.date ?? '-'}'),
              if (packing != null) ...[
                SizedBox(height: 8),
                Text('เลขที่ PL: ${packing.code}'),
                Text('ตู้คอนเทนเนอร์: ${packing.container_no}'),
                Text('ขนส่งโดย: ${packing.transport_by == 'Ship' ? 'เรือ' : 'รถยนต์'}'),
                Text('ปลายทาง: ${packing.destination}'),
                if ((packing.remark?.isNotEmpty ?? false)) Text('หมายเหตุ: ${packing.remark}'),
              ],
              Text('ที่อยู่จัดส่ง: ${order.date ?? '-'}'),
            ],
          ),
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
