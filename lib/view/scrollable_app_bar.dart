import 'package:flutter/material.dart';
import 'package:qr_reader_and_generator/view/qr_generator_view.dart';
import 'package:qr_reader_and_generator/view/qr_reader_view.dart';

class ScrollableAppBar extends StatelessWidget {
  List<Tab> tabs = [
    const Tab(
        child: Text(
      "Read QR code",
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    )),
    const Tab(
        child: Text(
      "Generate QR code",
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    )),
  ];

  List<Widget> tabsContent = [
    QRViewExample(),
    QrGenerator(),
  ];

  ScrollableAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: TabBar(
              indicatorColor: Colors.yellow,
              tabs: tabs,
            ),
          ),
        ),
        body: TabBarView(
          children: tabsContent,
        ),
      ),
    );
  }
}
