import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:proact/screens/home/tabs/dashboard_screen.dart';
import 'package:proact/screens/home/tabs/event_calender_new.dart';

import 'controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: controller.currentIndex.value == 0
          ? DashboardScreen()
          : EventCalenderNew(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showGeminiPrompt(context, -1),
        backgroundColor: const Color(0xFF1a1a1a),
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) => controller.currentIndex.value = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
        ],
      ),
    ));
  }
}
