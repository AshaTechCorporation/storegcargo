import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class Dialogs {
  static void showDetailsDialog(Marker marker, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Marker Details'),
            content: Text('Details for ${marker.markerId}'),
            actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ),
    );
  }

  static void locationNotFound(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ข้อผิดพลาด', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            content: const Text('ไม่พบรายการรถในวันที่ที่เลิอก'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ตกลง', style: TextStyle(color: Colors.black)))],
          ),
    );
  }

  static void validate(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('กรอกข้อมูลไม่ครบ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            content: const Text('กรุณาเลือกวันที่และรถให้เรียบร้อย'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ตกลง', style: TextStyle(color: Colors.black)))],
          ),
    );
  }

  static void openSetting(BuildContext context, bool location, bool notification) {
    List<String> permissionList = [];
    location ? permissionList.add('Location') : null;
    notification ? permissionList.add('Notification') : null;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 20),
            title: const Text('ดำเนินการไม่สำเร็จ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('กรุณาเปิดใช้งานสิทธิ์ดังต่อไปนี้ให้เรียบร้อย'),
                ...permissionList.map((permission) => Text('- $permission')).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // AppSettings.openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Setting', style: TextStyle(color: Colors.blue, fontSize: 20)),
              ),
            ],
          ),
    );
  }

  static Future<bool> exitApp(BuildContext context) async {
    bool status = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('แจ้งเตือน'),
          content: const Text('คุณต้องการที่จะออกจากแอพ ?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                status = false;
              },
            ),
            TextButton(
              child: const Text('ตกลง', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                status = true;
              },
            ),
          ],
        );
      },
    );
    return status;
  }
}
