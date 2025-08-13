import 'package:flutter/material.dart';
import 'package:storegcargo/constants.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, String>> parcels = [
    {
      "trackingId": "WE671360446C119",
      "name": "Abdullah 19",
      "phone": "01478523655",
      "location": "Mirpur-10",
      "total": "\$500.00",
      "status": "Received Warehouse",
    },
    {
      "trackingId": "WE671360446C118",
      "name": "Abdullah 18",
      "phone": "01478523655",
      "location": "Mirpur-10",
      "total": "\$500.00",
      "status": "Delivered",
    },
    {
      "trackingId": "WE671360446C117",
      "name": "Abdullah 17",
      "phone": "01478523655",
      "location": "Mirpur-10",
      "total": "\$500.00",
      "status": "Pending",
    },
    {
      "trackingId": "WE671360446C116",
      "name": "Abdullah 16",
      "phone": "01478523655",
      "location": "Mirpur-10",
      "total": "\$500.00",
      "status": "Pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.purple,
      //   title: Text("Parcel List"),
      //   actions: [
      //     TextButton.icon(
      //       onPressed: () {},
      //       icon: Icon(Icons.add, color: Colors.white),
      //       label: Text("Add", style: TextStyle(color: Colors.white)),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          _buildCustomAppBar(), // ✅ AppBar สไตล์โค้ง
          // Expanded(
          //   child: ListView.builder(
          //     padding: EdgeInsets.all(10),
          //     itemCount: parcels.length,
          //     itemBuilder: (context, index) {
          //       final parcel = parcels[index];
          //       return Card(
          //         margin: EdgeInsets.symmetric(vertical: 8),
          //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //         child: Padding(
          //           padding: EdgeInsets.all(12),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               // ✅ Tracking ID + Status
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Text(
          //                     "TrackingID#${parcel["trackingId"]}",
          //                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          //                   ),
          //                   _buildStatusBadge(parcel["status"]!),
          //                 ],
          //               ),
          //               SizedBox(height: 6),
          //               // ✅ Customer Info
          //               Text(parcel["name"]!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          //               Text(parcel["phone"]!, style: TextStyle(color: Colors.black54)),
          //               Text(parcel["location"]!, style: TextStyle(color: Colors.black54)),
          //               SizedBox(height: 6),
          //               Text("Total ${parcel["total"]!}", style: TextStyle(fontWeight: FontWeight.bold)),
          //               SizedBox(height: 6),
          //               // ✅ See Parcel Details
          //               Align(
          //                 alignment: Alignment.centerRight,
          //                 child: TextButton(
          //                   onPressed: () {},
          //                   child: Text(
          //                     "See Parcel Details",
          //                     style: TextStyle(color: Colors.purple),
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: kTextRedWanningColor,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
        Positioned(top: 50, left: 20, child: Text("ตะกร้าสินค้า", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
        Positioned(
          top: 45,
          right: 20,
          child: TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ✅ สร้าง Badge สำหรับสถานะ
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status) {
      case "Received Warehouse":
        badgeColor = Colors.blue;
        break;
      case "Delivered":
        badgeColor = Colors.green;
        break;
      case "Pending":
      default:
        badgeColor = Colors.orange;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
