import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:storegcargo/diver/customerProduct.dart';
import 'package:storegcargo/home/lsitOrdersMap.dart';
import 'package:storegcargo/home/mapPage.dart';
import 'package:storegcargo/models/deliveryorders.dart';
import 'package:storegcargo/models/images.dart';
import 'package:storegcargo/constants.dart';

class ListOrdersPage extends StatefulWidget {
  const ListOrdersPage({super.key, required this.deliveryOrders});
  final List<DeliveryOrders> deliveryOrders;

  @override
  State<ListOrdersPage> createState() => _ListOrdersPageState();
}

class _ListOrdersPageState extends State<ListOrdersPage> {
  List<DeliveryOrders> deliveryOrders = [];
  @override
  void initState() {
    super.initState();
    deliveryOrders = widget.deliveryOrders;
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
        title: Text("รายการจัดส่งทั้งหมด", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              deliveryOrders.isEmpty
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text('ไม่พบข้อมูล')],
                  )
                  : SizedBox(
                    height: size.height * 0.83,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: deliveryOrders.length,
                      itemBuilder: (context, index) {
                        return _buildDeliveryInfoCard(deliveryOrders[index], MediaQuery.of(context).size);
                      },
                    ),
                  ),
            ],
          ),
        ),
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
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ListOrdersMapPage()), (route) => false);
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
}
