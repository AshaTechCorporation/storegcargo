import 'package:flutter/material.dart';
import 'package:storegcargo/cart/cartPage.dart';
import 'package:storegcargo/constants.dart';
import 'package:storegcargo/home/homePage.dart';
import 'package:storegcargo/profile/profilePage.dart';
import 'package:storegcargo/send/sendPage.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int selectedIndex = 0;
  int _selectedIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentPage = HomePage();

  void onItemSelect(int index) {
    setState(() {
      selectedIndex = index;
      _selectedIndex = index;
      print(selectedIndex);
      if (selectedIndex == 0) {
        currentPage = HomePage();
      } else if (selectedIndex == 1) {
        currentPage = CartPage();
      } else if (selectedIndex == 2) {
        currentPage = SendPage();
      } else if (selectedIndex == 3) {
        currentPage = ProfilePage();
      }
    });
  }

  final List<IconData> _icons = [Icons.home, Icons.shopping_bag, Icons.send, Icons.person];

  final List<String> _labels = ["Home", "Cart", "Send", "Profile"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(child: PageStorage(bucket: bucket, child: currentPage)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onItemSelect,
        backgroundColor: Colors.white,
        selectedItemColor: kTextRedWanningColor,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: List.generate(_icons.length, (index) {
          return BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
              decoration:
                  _selectedIndex == index
                      ? BoxDecoration(
                        color: Colors.grey.shade300, // ✅ พื้นหลังเทาสำหรับ Home
                        borderRadius: BorderRadius.circular(20),
                      )
                      : null,
              child: Icon(_icons[index], size: 26),
            ),
            label: _labels[index],
          );
        }),
      ),
    );
  }
}
