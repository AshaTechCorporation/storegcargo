import 'package:flutter/material.dart';
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/diver/signaturePage.dart';
import 'package:storegcargo/home/services/homeApi.dart';
import 'package:storegcargo/models/deliveryorders.dart';
import 'package:storegcargo/widgets/LoadingDialog.dart';
import 'package:storegcargo/widgets/dialog.dart';

class CustomerProduct extends StatefulWidget {
  CustomerProduct({
    super.key,
    required this.namecustomer,
    required this.addess,
    required this.phone,
    required this.email,
    required this.code,
    required this.deliveryId,
    required this.order,
  });

  @override
  State<CustomerProduct> createState() => _CustomerProductState();
  String namecustomer;
  String addess;
  String phone;
  String email;
  String code;
  int deliveryId;
  DeliveryOrders order;
}

class _CustomerProductState extends State<CustomerProduct> {
  String? qrscrean;
  bool allSucceeded = true;
  DeliveryOrders? deliveryOrder;
  String memberName = "";
  String memberPhone = "";
  String address = "";
  // ✅ เพิ่มตรงนี้
  List<int> selectedDeliveryIds = []; // เก็บ id ที่คลิก
  List<Map<String, dynamic>> selectedImages = []; // เก็บภาพที่เกี่ยวข้อง

  Future checksucceed() async {
    allSucceeded = product.every((item) => item['status'] == 'succeed');
  }

  @override
  void initState() {
    super.initState();
    //checksucceed();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //await getlistOrder();
      await getOrderDelivery();
    });
  }

  Future<void> getOrderDelivery() async {
    try {
      LoadingDialog.open(context);
      final _orders = await HomeApi.getDeliveryOrdersId(id: widget.deliveryId);
      if (!mounted) return;
      setState(() {
        // deliveryOrder = _orders;
        deliveryOrder = widget.order;
        //final member = deliveryOrder?.delivery_order_thai_lists?.first.delivery_order?.member?.member_address;
        final member =
            (deliveryOrder?.delivery_order_thai_lists?.isNotEmpty ?? false)
                ? deliveryOrder!.delivery_order_thai_lists!.first.delivery_order?.member?.member_address
                : null;

        memberName = "${member?.contact_name ?? ''}";
        memberPhone = member?.contact_phone ?? '-';
        address =
            '${member?.address ?? ''} '
            '${member?.sub_district ?? ''} '
            '${member?.district ?? ''} '
            '${member?.province ?? ''} '
            '${member?.postal_code ?? ''}';
      });

      LoadingDialog.close(context);
    } on Exception catch (e) {
      if (!mounted) return;
      LoadingDialog.close(context);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: size.height * 0.1,
        automaticallyImplyLeading: false,
        backgroundColor: kCardLine3Color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text('ข้อมุลสินค้า', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white, border: Border.all(color: kCardLine1Color)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Color(0xffE3F2FD), shape: BoxShape.circle),
                          child: Icon(Icons.person, color: Colors.grey[700], size: 30),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('ชื่อ: ', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      (deliveryOrder?.delivery_order_thai_lists?.isNotEmpty ?? false)
                                          ? (deliveryOrder!.delivery_order_thai_lists!.first.delivery_order?.member?.member_address?.contact_name
                                                      ?.trim()
                                                      .isNotEmpty ==
                                                  true
                                              ? deliveryOrder!.delivery_order_thai_lists!.first.delivery_order!.member!.member_address!.contact_name!
                                              : '-')
                                          : '-',
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('เบอร์โทร: ', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      (deliveryOrder?.delivery_order_thai_lists?.isNotEmpty ?? false)
                                          ? (deliveryOrder!.delivery_order_thai_lists!.first.delivery_order?.member?.member_address?.contact_phone ??
                                              '-')
                                          : '-',
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: Text('ที่อยู่: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                    Expanded(
                                      flex: 2,
                                      child: Text('${address == '' ? '-' : address}', style: TextStyle(fontSize: 14), softWrap: true),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              deliveryOrder != null
                  ? deliveryOrder!.packing_list != null
                      ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: kCardLine1Color),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📦 รายละเอียดพาเลท / แพ็คกิ้ง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kButtonColor)),
                              SizedBox(height: 10),
                              _buildRowInfo('Packing No:', deliveryOrder!.packing_list?.packinglist_no ?? '-'),
                              _buildRowInfo('Container No:', deliveryOrder!.packing_list?.container_no ?? '-'),
                              _buildRowInfo('ทะเบียนรถขนส่ง:', deliveryOrder!.packing_list?.truck_license_plate ?? '-'),
                              _buildRowInfo('ขนส่งจีน:', deliveryOrder!.packing_list?.shipping_china ?? '-'),
                              _buildRowInfo('ขนส่งไทย:', deliveryOrder!.packing_list?.shipping_thailand ?? '-'),
                              _buildRowInfo('ขนส่งโดย:', deliveryOrder!.packing_list?.transport_by ?? '-'),
                              _buildRowInfo('ปลายทาง:', deliveryOrder!.packing_list?.destination ?? '-'),
                              _buildRowInfo('วันปิดตู้:', deliveryOrder!.packing_list?.closing_date ?? '-'),
                              _buildRowInfo('วันประมาณถึง:', deliveryOrder!.packing_list?.estimated_arrival_date ?? '-'),
                              _buildRowInfo('หมายเหตุ:', deliveryOrder!.packing_list?.remark ?? '-'),
                            ],
                          ),
                        ),
                      )
                      : SizedBox()
                  : SizedBox(),
              if (deliveryOrder?.delivery_order_thai_lists != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: deliveryOrder!.delivery_order_thai_lists!.length,
                  itemBuilder: (context, index) {
                    final item = deliveryOrder!.delivery_order_thai_lists![index];
                    final order = item.delivery_order;
                    final status = item.delivery_order?.status;
                    final orderList = item.delivery_order_list;
                    final images = item.images ?? [];

                    return GestureDetector(
                      onTap: () {
                        print(status);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: kCardLine1Color),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("รหัสคำสั่งซื้อ: ${order?.code ?? '-'}", style: TextStyle(fontWeight: FontWeight.bold)),
                                Row(children: [
                                    
                                  ],
                                ),
                              ],
                            ),
                            Text("วันที่: ${order?.date ?? '-'}"),
                            Text("ชื่อสินค้า: ${orderList?.product_name ?? '-'}"),
                            Text("จำนวน: ${orderList?.qty ?? 0} ชิ้น"),
                            Text("น้ำหนัก: ${orderList?.weight ?? '-'} กก."),
                            Text("ขนาด: ${orderList?.width}x${orderList?.long}x${orderList?.height} ซม."),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  images.map((img) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        img.image_url ?? '',
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Image.asset('assets/images/noimages.jpg', height: 100, width: 100, fit: BoxFit.cover),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Center(child: Text('ไม่พบข้อมูลสินค้า'))],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          deliveryOrder != null
              ? deliveryOrder!.status != 'delivered'
                  ? SafeArea(
                    child: GestureDetector(
                      onTap: () async {
                        final out = await showDialog(
                          context: context,
                          builder:
                              (context) => Dialogyesno(
                                title: 'แจ้งเตือน',
                                description: 'ต้องการอัพเดชสถานะหรือไม่',
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
                        if (out == true) {
                          for (var i = 0; i < deliveryOrder!.delivery_order_thai_lists!.length; i++) {
                            final id = deliveryOrder!.delivery_order_thai_lists![i].delivery_order_thai_id;
                            final imgs =
                                deliveryOrder!.delivery_order_thai_lists![i].images!.map((e) {
                                  return {'image': e.image, 'image_url': e.image_url};
                                }).toList();
                            setState(() {
                              selectedDeliveryIds = [id!]; // แทนที่ตัวเก่า
                              selectedImages = [
                                {'id': id, 'images': imgs},
                              ];
                            });
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (contex) => RefuelingPage(selectedDeliveryIds: selectedDeliveryIds, selectedImages: selectedImages),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          width: double.infinity,
                          height: size.height * 0.08,
                          decoration: BoxDecoration(color: kButtonColor, borderRadius: BorderRadius.circular(15)),
                          child: Center(child: Text('ตกลง', style: TextStyle(color: Colors.white, fontSize: 20))),
                        ),
                      ),
                    ),
                  )
                  : SizedBox.shrink()
              : SizedBox.shrink(),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SizedBox(width: 140, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600))), Expanded(child: Text(value))],
      ),
    );
  }
}
