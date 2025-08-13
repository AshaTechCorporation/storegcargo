import 'package:flutter/material.dart';

LinearGradient backgroundColor = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFFFFFFF), // สีขาว (#FFFFFF)
    Color(0xFFF5F5F5), // สีเทาอ่อน (#F5F5F5)
  ],
  stops: [0.6, 1.0],
);
double width(BuildContext context) => MediaQuery.of(context).size.width;
double height(BuildContext context) => MediaQuery.of(context).size.height;
const String publicUrl = 'g-cargo.dev-asha9.com';
const String baseUrl = 'https://g-cargo.dev-asha9.com';
const String socketUrl = 'http://185.78.166.46:50000';

const kButtonColor = Color(0xFF012849);
const kSubButtonColor = Color(0xFF3C5A9A);
const kButtondiableColor = Color(0xFFE9EEFF);
const kTextButtonColor = Color(0xFFFFFFFF);
const kdefaultTextColor = Color(0xFF000000);
const kHintTextColor = Color(0xFF5F657B);
const kTextRedWanningColor = Color(0xFFD70F1C);
const kCardLine1Color = Color(0xFF003C8D);
const kCardLine2Color = Color(0xFF2C78C6);
const kCardLine3Color = Color(0xFF58B3FF);
const kTitleTextGridColor = Color(0xFF004AAD);
const kSubTitleTextGridColor = Color(0xFF012849);
const kButtonLogoutColor = Color(0xFFFFBA00);
const kBackTextFiledColor = Color(0xFFF6F6F6);
const kBackgroundTextColor = Color(0xFF004AAD);
const kTextgreyColor = Color(0xFF333333);
const kCicleColor = Color(0xFF23547D);
const kCicleSelectedColor = Color(0xFFE5EBFC);
const kTextTitleHeadColor = Color(0xFF202020);

List<Map<String, String>> customername = [
  {
    'name': 'สมหมาย ใจฟู',
    'addess': '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพมหานคร 10110',
    'phone': '090000000',
    'email': 'a@hotmail',
    'code': '#C0001',
    'id': '1',
    'status': 'await',
  },
  {
    'name': 'สมดี มีชัย',
    'addess': '45 หมู่ 2 ตำบลสุเทพ อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ 50200',
    'phone': '090000000',
    'email': 'a@hotmail',
    'code': '#C0002',
    'id': '2',
    'status': 'await',
  },
  {
    'name': 'สมหมาย ปากหม้อ',
    'addess': '88 ถนนรัษฎา ตำบลตลาดใหญ่ อำเภอเมืองภูเก็ต จังหวัดภูเก็ต 83000',
    'phone': '090000000',
    'email': 'a@hotmail',
    'code': '#C0003',
    'id': '3',
    'status': 'await',
  },
  {
    'name': 'สมเจ็ต ลิปบิ้น',
    'addess': '567 ซอยมิตรภาพ 10 ตำบลในเมือง อำเภอเมืองขอนแก่น จังหวัดขอนแก่น 40000',
    'phone': '090000000',
    'email': 'a@hotmail',
    'code': '#C0004',
    'id': '4',
    'status': 'await',
  },
  {
    'name': 'สมคิด ดีจริง',
    'addess': '999 หมู่ 5 ตำบลจอหอ อำเภอเมืองนครราชสีมา จังหวัดนครราชสีมา 30000',
    'phone': '090000000',
    'email': 'a@hotmail',
    'code': '#C0005',
    'id': '5',
    'status': 'await',
  },
];
List<Map<String, String>> product = [
  {'product': 'เสื้อ', 'ordercode': '#QR-00001', 'date': '2025-01-14', 'total': '120.00', 'status': 'await'},
  {'product': 'แก้วน้ำ', 'ordercode': '#QR-00002', 'date': '2025-01-14', 'total': '160.00', 'status': 'await'},
];
String formatPhoneNumber(String phone) {
  if (phone.length == 10) {
    return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6, 10)}';
  }
  return phone; // กรณีความยาวไม่ถูกต้อง ส่งคืนเหมือนเดิม
}
