import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/models/orders.dart';

class ProductDetailPage extends StatefulWidget {
  final Orders order;

  const ProductDetailPage({super.key, required this.order});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late GoogleMapController mapController;
  ImagePicker picker = ImagePicker();
  File? _image;
  final SignatureController _signatureController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);

  // ✅ ฟังก์ชัน Map
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future openDialogImage() async {
    final img = await picker.pickImage(source: ImageSource.camera);
    return img;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orderLists = widget.order.order_lists ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.order.code ?? "รายละเอียดสินค้า"), backgroundColor: Colors.redAccent),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ ภาพสินค้าหลัก
            Container(
              width: double.infinity,
              height: size.height * 0.35,
              decoration: BoxDecoration(
                image: orderLists.isNotEmpty ? DecorationImage(image: NetworkImage(orderLists[0].product_image ?? ""), fit: BoxFit.cover) : null,
              ),
              child: orderLists.isEmpty ? Center(child: Text("ไม่มีรูปภาพ", style: TextStyle(color: Colors.grey))) : null,
            ),

            // ✅ ภาพสินค้าเล็กๆ ด้านล่าง
            if (orderLists.length > 1)
              Container(
                height: size.height * 0.12,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: orderLists.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: GestureDetector(
                        onTap: () {
                          // เปลี่ยนรูปใหญ่เมื่อกดที่รูปเล็ก
                          setState(() {});
                        },
                        child: CachedNetworkImage(
                          imageUrl: orderLists[index].product_image ?? "",
                          width: size.width * 0.2,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ ชื่อสินค้า
                  Text(
                    orderLists.isNotEmpty ? orderLists[0].product_name ?? "ไม่ระบุชื่อสินค้า" : "ไม่ระบุชื่อสินค้า",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // ✅ ราคา + จำนวนสินค้า
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${widget.order.total_price ?? "0.00"}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        "จำนวน: ${orderLists.isNotEmpty ? orderLists[0].product_qty ?? 0 : 0} ชิ้น",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // ✅ รายละเอียดสินค้า
                  Text(
                    "หมวดหมู่: ${orderLists.isNotEmpty ? orderLists[0].product_category ?? "ไม่ระบุหมวดหมู่" : "ไม่ระบุหมวดหมู่"}",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 16),

                  // ✅ แผนที่แสดงตำแหน่งสินค้า
                  Text("สถานที่ตั้งของสินค้า", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(13.7563, 100.5018), // พิกัดกรุงเทพฯ (สามารถรับค่าจาก API ได้)
                          zoom: 14.0,
                        ),
                        markers: {Marker(markerId: MarkerId("productLocation"), position: LatLng(13.7563, 100.5018))},
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // ✅ ปุ่มกด "ซื้อเลย"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text("ซื้อ ${orderLists.isNotEmpty ? orderLists[0].product_name ?? "สินค้า" : "สินค้า"} สำเร็จ!")),
                        // );
                        _signatureController.clear();
                        setState(() {
                          _image = null;
                        });

                        final bool? _check = await _showChangeStatusDialog(widget.order, size);

                        if (_check == true) {
                          Navigator.pop(context, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("รับสินค้า", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showChangeStatusDialog(Orders order, Size size) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSectionTitle("TEG"),
                      _buildInfoRow("ชื่อ:", '${order.member?.fname ?? ''}'),
                      _buildInfoRow("เบอร์โทร:", '${order.member?.phone ?? ''}'),
                      _buildInfoRow("ที่อยู่:", '${order.member?.address ?? ''}'),
                      SizedBox(height: 10),

                      _buildSectionTitle("รายละเอียด"),
                      _buildInfoRow("หมายเลข:", "${order.code ?? ''}"),
                      _buildInfoRow("รูปแบบขนส่ง:", order.shipping_type == null ? "Ship" : "${order.shipping_type ?? ''}"),
                      _buildInfoRow("วันที่:", "${order.date ?? ''}"),
                      _buildInfoRow("ยอดรวม:", "${order.total_price ?? ''}"),

                      SizedBox(height: 10),
                      _buildTextField("หมายเหตุ*", ""),
                      SizedBox(height: 10),
                      _buildSignatureField(),
                      SizedBox(height: 10),

                      if (_image != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Image.file(_image!, height: size.height * 0.3, width: size.width * 0.6, fit: BoxFit.cover),
                        ),

                      SizedBox(height: size.height * 0.02),

                      ElevatedButton.icon(
                        onPressed: () async {
                          final img = await openDialogImage();
                          if (img != null) {
                            setStateDialog(() {
                              _image = File(img.path);
                            });
                          }
                        },
                        icon: Icon(Icons.camera_alt, color: kTextRedWanningColor),
                        label: Text("Photo", style: TextStyle(color: kTextRedWanningColor)),
                        style: ElevatedButton.styleFrom(backgroundColor: kHintTextColor),
                      ),

                      SizedBox(height: 15),

                      // ✅ ปุ่มยืนยัน & ยกเลิก
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDialogButton("ยกเลิก", Colors.black, Colors.white, () {
                            Navigator.pop(context, false); // ✅ ส่งค่า false กลับไป
                          }),
                          SizedBox(width: size.width * 0.01),
                          _buildDialogButton("ตกลง", kTextRedWanningColor, Colors.white, () {
                            Navigator.pop(context, true); // ✅ ส่งค่า true กลับไป
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Dropdown สำหรับเลือกสถานะ
  Widget _buildDropdownField(String label, List<String> items, String selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(border: OutlineInputBorder()),
          items:
              items.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
          onChanged: (String? newValue) {},
        ),
      ],
    );
  }

  // ✅ ช่องสำหรับลายเซ็น (เขียนได้ & ลบได้)
  Widget _buildSignatureField() {
    return Column(
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
    );
  }

  // ✅ ช่องบันทึกข้อความ
  Widget _buildTextField(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText: initialValue)),
      ],
    );
  }

  // ✅ ปุ่มอัปโหลดรูป
  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        final img = await openDialogImage();
        if (img != null) {
          setState(() {
            _image = File(img.path);
          });
        }
      },
      icon: Icon(Icons.camera_alt),
      label: Text("Photo"),
      style: ElevatedButton.styleFrom(backgroundColor: kHintTextColor),
    );
  }

  // ✅ ปุ่ม Dialog
  Widget _buildDialogButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: bgColor),
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(color: isLink ? Colors.blue : Colors.black87, fontWeight: isLink ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
