import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/diver/customerProduct.dart';
import 'package:storegcargo/home/lsitOrders.dart';
import 'package:storegcargo/home/mapPage.dart';
import 'package:storegcargo/home/services/homeApi.dart';
import 'package:storegcargo/login/loginpage.dart';
import 'package:storegcargo/models/deliveryorders.dart';
import 'package:storegcargo/models/images.dart';
import 'package:storegcargo/models/orders.dart';
import 'package:storegcargo/models/packinglist.dart';
import 'package:storegcargo/models/memberaddress.dart';
import 'package:storegcargo/profile/profilePage.dart';
import 'package:storegcargo/utils/toast_util.dart';
import 'package:storegcargo/widgets/LoadingDialog.dart';
import 'package:storegcargo/widgets/dialog.dart';

class ListOrdersMapPage extends StatefulWidget {
  const ListOrdersMapPage({super.key});

  @override
  State<ListOrdersMapPage> createState() => _ListOrdersMapPageState();
}

class _ListOrdersMapPageState extends State<ListOrdersMapPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Orders> orders = [];
  final ScrollController _scrollController = ScrollController();
  List<DeliveryOrders> deliveryOrders = [];
  List<DeliveryOrders> deliveryCompleted = [];
  bool? isGPSEnabled;
  LatLng? selectedPosition;
  double? lat;
  double? long;
  late GoogleMapController mapController;
  BitmapDescriptor? customIcon;
  BitmapDescriptor? customIconPerson;

  Future<void> permissionHandler() async {
    await Permission.locationWhenInUse.request();
    await Permission.notification.request();
    PermissionStatus permission = await Permission.locationWhenInUse.status;
    if (permission.isGranted) {
      // ตรวจสอบว่า GPS เปิดหรือปิด
      isGPSEnabled = await Geolocator.isLocationServiceEnabled();
      if (isGPSEnabled!) {
        print("GPS เปิดอยู่");
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            selectedPosition = LatLng(position.latitude, position.longitude);
            lat = position.latitude;
            long = position.longitude;
            // load = true;
          });
        }
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
    loadCustomIcon();
    loadCustomIconPerson();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await permissionHandler();
      await getlistOrderDelivery();
    });
  }

  Future<void> getlistOrderDelivery() async {
    try {
      LoadingDialog.open(context);
      final _orders = await HomeApi.getDeliveryOrders(page: 1, length: 10);
      if (!mounted) return;

      // final completed = _orders.where((order) => order.status == 'awaiting_payment').toList();
      // final others = _orders.where((order) => order.status == 'delivered').toList();
      final completed = _orders.where((order) => order.status == 'delivered').toList();
      final others = _orders.where((order) => order.status != 'delivered').toList();

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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    mapController.dispose();
    super.dispose();
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

  Future<void> loadCustomIconPerson() async {
    customIconPerson = await BitmapDescriptor.asset(ImageConfiguration(), width: 40, height: 50, 'assets/icons/delivery-man.png');
  }

  void loadCustomIcon() async {
    customIcon = await BitmapDescriptor.asset(
      // const ImageConfiguration(size: Size(48, 48)),
      ImageConfiguration(),
      width: 40,
      height: 50,
      'assets/icons/tracking.png',
    );
    setState(() {});
  }

  Map<String, Offset> _markerScreenPositions = {};

  Set<Marker> getMarkersFromData(List<DeliveryOrders> driver) {
    if (driver.isNotEmpty) {
      final Set<Marker> allMarkers =
          driver.map((item) {
            final packing = item.packing_list;
            final thaiList = item.delivery_order_thai_lists?.isNotEmpty == true ? item.delivery_order_thai_lists!.first : null;
            final receiver = thaiList?.delivery_order?.member?.member_address;

            if (item.delivery_order_thai_lists?.isNotEmpty ?? false) {
              if (receiver?.latitude != null && receiver?.longitude != null) {
                return Marker(
                  markerId: MarkerId(item.id.toString()),
                  position: LatLng(double.parse(receiver!.latitude!), double.parse(receiver.longitude!)),
                  icon: customIconPerson ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(
                    title: thaiList?.delivery_order?.member?.importer_code ?? ' - ',
                    onTap: () async {
                      if (packing != null &&
                          packing.code != null &&
                          packing.container_no != null &&
                          packing.packinglist_no != null &&
                          item.id != null) {
                        final success = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CustomerProduct(
                                  namecustomer: packing.code ?? '-',
                                  addess: packing.container_no ?? '-',
                                  phone: packing.container_no ?? '-',
                                  email: packing.packinglist_no ?? '-',
                                  code: packing.shipping_china ?? '-',
                                  deliveryId: item.id!,
                                  order: item,
                                ),
                          ),
                        );
                        if (success == true) {
                          await getlistOrderDelivery();
                        }
                      }
                    },
                  ),
                  onTap: () async {
                    getPolyPoints(double.parse(receiver.latitude!), double.parse(receiver.longitude!));
                  },
                );
              } else {
                return Marker(markerId: MarkerId(''));
              }
            } else {
              return Marker(markerId: MarkerId(''));
            }
          }).toSet();

      // เพิ่มตำแหน่งตัวเอง (ถ้ามีข้อมูล)
      if (selectedPosition != null) {
        allMarkers.add(
          Marker(
            markerId: MarkerId('my_location'),
            position: selectedPosition!,
            icon: customIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'ตำแหน่งของฉัน'),
          ),
        );
      }

      return allMarkers;
    } else {
      return {};
    }
  }

  // Helper methods for better organization
  String _buildInfoWindowTitle(Packinglist? packing, MemberAddress receiver) {
    return '${packing?.code?.trim() ?? 'N/A'}';
  }

  Future<void> _handleInfoWindowTap(BuildContext context, Packinglist? packing, DeliveryOrders item) async {
    if (!_isValidPacking(packing) || item.id == null) return;

    try {
      final success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CustomerProduct(
                namecustomer: packing!.code ?? 'N/A',
                addess: packing.container_no ?? 'N/A',
                phone: packing.container_no ?? 'N/A', // Note: Same as address? Intentional?
                email: packing.packinglist_no ?? 'N/A',
                code: packing.shipping_china ?? 'N/A',
                deliveryId: item.id!,
                order: item,
              ),
        ),
      );

      if (success == true) {
        await getlistOrderDelivery();
      }
    } catch (e) {
      debugPrint('Error navigating to CustomerProduct: $e');
      // Consider showing an error snackbar to user
    }
  }

  bool _isValidPacking(Packinglist? packing) {
    return packing != null && packing.code != null && packing.container_no != null && packing.packinglist_no != null;
  }

  Future<void> _fetchRouteToDestination(MemberAddress receiver) async {
    try {
      getPolyPoints(double.tryParse(receiver.latitude!) ?? 0.0, double.tryParse(receiver.longitude!) ?? 0.0);
    } catch (e) {
      debugPrint('Error fetching route: $e');
      // Consider showing an error to the user
    }
  }

  Future<void> _updateAllMarkerPositions() async {
    if (mapController == null || !mounted) return;

    // เตรียม Map ใหม่ ไม่เปลี่ยนของเดิมทันที
    Map<String, Offset> newMarkerPositions = {};

    List<Future<void>> tasks = [];

    for (var item in deliveryOrders) {
      tasks.add(_processDeliveryOrder(item, newMarkerPositions));
    }

    // ทำงาน async ทั้งหมดพร้อมกัน
    await Future.wait(tasks);

    if (!mounted) return;

    // เซตค่าทีเดียว
    setState(() {
      _markerScreenPositions = newMarkerPositions;
    });
  }

  Future<void> _processDeliveryOrder(DeliveryOrders item, Map<String, Offset> positions) async {
    final thaiList = item.delivery_order_thai_lists?.isNotEmpty == true ? item.delivery_order_thai_lists!.first : null;

    final receiver = thaiList?.delivery_order?.member?.member_address;

    final latStr = receiver?.latitude;
    final lngStr = receiver?.longitude;

    if (latStr == null || lngStr == null) return;

    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);

    if (lat == null || lng == null) return;

    final latLng = LatLng(lat, lng);
    final screenCoordinate = await mapController.getScreenCoordinate(latLng);

    // เรียก polyline ได้ถ้าต้องการ แต่ถ้าช้า แนะนำทำแยก
    getPolyPoints(lat, lng);

    positions[item.id.toString()] = Offset(screenCoordinate.x.toDouble(), screenCoordinate.y.toDouble());
  }

  void _moveToLocation(LatLng latLng) {
    mapController.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints(double latStrat, longStrat) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: 'AIzaSyB6nobedKqsMxY5omMWNE1e449BBo_Q3sw',
      request: PolylineRequest(origin: PointLatLng(lat!, long!), destination: PointLatLng(latStrat, longStrat), mode: TravelMode.driving),
    );

    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {});
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kCardLine3Color,
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
              decoration: BoxDecoration(color: kCardLine3Color),
              child: Row(
                children: [
                  Image.asset('assets/icons/Logo.png', scale: 2),
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
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          // Center(
          //     child: Diverpage(
          //   deliveryOrders: deliveryOrders,
          // )),
          deliveryOrders.isEmpty
              ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text('ไม่พบข้อมูล')])
              : Stack(
                children: [
                  // 🗺 Google Map
                  Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(target: selectedPosition!, zoom: 15),
                        // onTap: (LatLng position) {
                        //   setState(() => selectedPosition = position);
                        // },
                        myLocationButtonEnabled: false,
                        myLocationEnabled: false,
                        // zoomControlsEnabled: false,
                        onMapCreated: (controller) async {
                          mapController = controller;
                          if (Platform.isAndroid) {
                            await Future.delayed(Duration(milliseconds: 500));
                          } else {
                            await Future.delayed(Duration(milliseconds: 100));
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _updateAllMarkerPositions();
                          });
                        },
                        onCameraMove: (_) => _updateAllMarkerPositions(),
                        markers: deliveryOrders.isEmpty ? {} : getMarkersFromData(deliveryOrders),
                        // markers: getMarkersFromData(deliveryOrders),
                        polylines: {Polyline(polylineId: PolylineId('route'), points: polylineCoordinates, color: Colors.green, width: 5)},
                      ),
                    ],
                  ),

                  Positioned(
                    bottom: 270,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: IconButton(
                        icon: Icon(Icons.list, color: Colors.black, size: 25),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ListOrdersPage(deliveryOrders: deliveryOrders);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: size.height * 0.28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))],
                      ),
                      child: Column(
                        children: [
                          // Handle indicator
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 8, bottom: 4),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: deliveryOrders.length,
                              itemBuilder: (context, index) {
                                final order = deliveryOrders[index];
                                return _buildDeliveryItem(order, context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

          deliveryCompleted.isEmpty
              ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text('ไม่พบข้อมูล')])
              : ListView.builder(
                itemCount: deliveryCompleted.length,
                itemBuilder: (context, index) {
                  return _buildDeliveryInfoCard(deliveryCompleted[index], MediaQuery.of(context).size);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(DeliveryOrders order, Size size) {
    final packing = order.packing_list;
    final thaiList = order.delivery_order_thai_lists?.isNotEmpty == true ? order.delivery_order_thai_lists!.first : null;
    final productName = thaiList?.delivery_order_list?.product_name ?? '-';
    final productImages = thaiList?.images ?? <Imagess>[];
    final receiver = thaiList?.delivery_order?.member?.member_address;

    final receiverAddress =
        (receiver?.address != null &&
                receiver?.sub_district != null &&
                receiver?.district != null &&
                receiver?.province != null &&
                receiver?.postal_code != null)
            ? '${receiver!.address}, ${receiver.sub_district}, ${receiver.district}, ${receiver.province} ${receiver.postal_code}'
            : '-';

    return GestureDetector(
      onTap: () async {
        if (packing != null && packing.code != null && packing.container_no != null && packing.packinglist_no != null && order.id != null) {
          final success = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CustomerProduct(
                    namecustomer: packing.code ?? '-',
                    addess: packing.container_no ?? '-',
                    phone: packing.container_no ?? '-',
                    email: packing.packinglist_no ?? '-',
                    code: packing.shipping_china ?? '-',
                    deliveryId: order.id!,
                    order: order,
                  ),
            ),
          );
          if (success == true) {
            await getlistOrderDelivery();
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.code ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('วันที่: ${order.date ?? '-'}'),
              if (packing != null) ...[
                const SizedBox(height: 8),
                Text('PL No.: ${packing.packinglist_no ?? '-'}'),
                Text('ตู้: ${packing.container_no ?? '-'}'),
                Text('ขนส่งโดย: ${packing.transport_by == 'Ship' ? 'เรือ' : 'รถยนต์'}'),
                Text('ปลายทาง: ${packing.destination ?? '-'}'),
              ],
              const Divider(height: 20),
              Text('สินค้า: $productName', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (productImages.isNotEmpty)
                SizedBox(
                  height: size.height * 0.12,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: productImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final img = productImages[i].image_url;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            img != null
                                ? CachedNetworkImage(
                                  imageUrl: img,
                                  width: size.width * 0.25,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 1)),
                                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                                )
                                : const Icon(Icons.broken_image),
                      );
                    },
                  ),
                )
              else
                const Text('ไม่มีรูปสินค้า'),
              const Divider(height: 20),
              if (receiver != null) ...[
                Text('ผู้รับ: ${receiver.contact_name ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'เบอร์โทร: ${receiver.contact_phone ?? ''}  ${receiver.contact_phone2 ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 4),
              const Text('ที่อยู่ผู้รับ:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(receiverAddress),
              const SizedBox(height: 8),
              if (receiver?.latitude != null && receiver?.longitude != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      final lat = double.tryParse(receiver!.latitude!);
                      final lng = double.tryParse(receiver.longitude!);
                      if (lat != null && lng != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MapPage(latitude: lat, longitude: lng)));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kTextRedWanningColor),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place, color: kTextRedWanningColor),
                          const SizedBox(width: 6),
                          Text('ดูแผนที่', style: TextStyle(color: kTextRedWanningColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryMapView(Size size, BuildContext context) {
    return deliveryOrders.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text('ไม่พบรายการจัดส่ง', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        )
        : Stack(
          children: [
            // Map View
            _buildGoogleMap(),

            // List Button
            Positioned(
              bottom: 240,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                elevation: 4,
                child: Icon(Icons.list, color: Colors.black, size: 28),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ListOrdersPage(deliveryOrders: deliveryOrders))),
              ),
            ),

            // Bottom Sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: Column(
                  children: [
                    // Handle indicator
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 8, bottom: 4),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: deliveryOrders.length,
                        itemBuilder: (context, index) {
                          final order = deliveryOrders[index];
                          return _buildDeliveryItem(order, context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
  }

  Widget _buildGoogleMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: selectedPosition!, zoom: 15),
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) async {
            mapController = controller;
            await Future.delayed(Platform.isAndroid ? Duration(milliseconds: 500) : Duration(milliseconds: 100));
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateAllMarkerPositions());
          },
          onCameraMove: (_) => _updateAllMarkerPositions(),
          markers: deliveryOrders.isEmpty ? {} : getMarkersFromData(deliveryOrders),
          polylines: {Polyline(polylineId: PolylineId('route'), points: polylineCoordinates, color: Colors.green, width: 5)},
        ),
      ],
    );
  }

  Widget _buildDeliveryItem(DeliveryOrders order, BuildContext context) {
    final packing = order.packing_list;
    final thaiList = order.delivery_order_thai_lists?.isNotEmpty == true ? order.delivery_order_thai_lists!.first : null;
    final receiver = thaiList?.delivery_order?.member?.member_address;
    final receiverAddress =
        (receiver?.address != null &&
                receiver?.sub_district != null &&
                receiver?.district != null &&
                receiver?.province != null &&
                receiver?.postal_code != null)
            ? '${receiver!.address}, ${receiver.sub_district}, ${receiver.district}, ${receiver.province} ${receiver.postal_code}'
            : '-';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (receiver?.latitude != null && receiver?.longitude != null) {
            setState(() {
              _moveToLocation(LatLng(double.parse(receiver!.latitude!), double.parse(receiver.longitude!)));
            });
          } else {
            ToastUtil.showToast('ไม่มีจุดหมาย', fontSize: 12, color: Colors.red, gravity: ToastGravity.BOTTOM);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Order Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.code ?? '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(receiver?.contact_phone ?? '-', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('รหัส: ${thaiList?.delivery_order?.member?.importer_code ?? '-'}', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text('ผู้รับ: ${receiver?.contact_name ?? '-'}', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text(
                      'ที่อยู่: $receiverAddress',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Edit Button
              IconButton(
                icon: Icon(Icons.edit, color: kButtonColor),
                onPressed: () async {
                  if (packing != null && packing.code != null && packing.container_no != null && packing.packinglist_no != null && order.id != null) {
                    final success = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CustomerProduct(
                              namecustomer: packing.code ?? '-',
                              addess: packing.container_no ?? '-',
                              phone: packing.container_no ?? '-',
                              email: packing.packinglist_no ?? '-',
                              code: packing.shipping_china ?? '-',
                              deliveryId: order.id!,
                              order: order,
                            ),
                      ),
                    );
                    if (success == true) {
                      await getlistOrderDelivery();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
