// import 'package:background_location/background_location.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:storegcargo/diver/customerProduct.dart';
import 'package:storegcargo/models/deliveryorders.dart';

class Diverpage extends StatefulWidget {
  Diverpage({super.key, required this.deliveryOrders});
  List<DeliveryOrders> deliveryOrders;

  @override
  State<Diverpage> createState() => _DiverpageState();
}

class _DiverpageState extends State<Diverpage> with WidgetsBindingObserver {
  // Position? _position;

  Future<void> _getCuttentLocation() async {
    final LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100);
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
      print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _getCuttentLocation();
    permissionHandler();
  }

  // Future<void> initialize() async {
  //   await permissionHandler();
  // }

  Future<void> permissionHandler() async {
    await Permission.locationWhenInUse.request();
    await Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: List.generate(widget.deliveryOrders.length, (index) {
                  return GestureDetector(
                    onTap: () async {
                      final out = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (contex) => CustomerProduct(
                                namecustomer: widget.deliveryOrders[index].date ?? '-',
                                addess: widget.deliveryOrders[index].packing_list?.code ?? '-',
                                phone: widget.deliveryOrders[index].packing_list?.destination ?? '-',
                                email: widget.deliveryOrders[index].packing_list?.remark ?? '-',
                                code: widget.deliveryOrders[index].packing_list?.code ?? '-',
                                deliveryId: widget.deliveryOrders[index].id!,
                                order: widget.deliveryOrders[index],
                              ),
                        ),
                      );
                      if (out != null) {
                        print(out);
                      } else {
                        print('ไม่มีค่าส่งมา');
                      }
                      // customername.removeAt(index);
                    },
                    child: Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            // ✅ รายละเอียดพัสดุ
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('${widget.deliveryOrders[index].code}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 10),
                                      Text('${widget.deliveryOrders[index].date}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Text('${widget.deliveryOrders[index].packing_list?.truck_license_plate ?? '-'}', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),

                            Icon(Icons.arrow_forward_ios_sharp),
                            // ✅ แสดงรูปด้านขวา
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
