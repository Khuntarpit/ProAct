import 'dart:convert';
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';

import '../gemini_prompt.dart';

class HomeController extends GetxController {
  RxString userEmail = ''.obs;
  RxString emailPrefix = ''.obs;
  RxList<Map<String, String>> eventData = <Map<String, String>>[].obs;
  RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadEventData();
  }

  void showGeminiPrompt(BuildContext context, int eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
        final height = keyboardOpen
            ? MediaQuery.of(context).size.height * 0.9
            : MediaQuery.of(context).size.height * 0.5;

        return Container(
          padding: const EdgeInsets.all(16.0),
          height: height,
          child: GeminiPrompt(
            onSubmit: (data) {
              eventData.addAll(data);
              saveEventData();
            },
            eventId: eventId,
          ),
        );
      },
    );
  }

  Future<void> saveEventData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventDataJson = jsonEncode(eventData);
    await prefs.setString('eventData', eventDataJson);
    await Get.find<MethodChannelController>().saveEvents(eventDataJson);
  }

  Future<void> loadEventData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventDataJson = prefs.getString('eventData') ?? '[]';
    eventData.value = List<Map<String, String>>.from(
      (jsonDecode(eventDataJson) as List).map((e) => Map<String, String>.from(e)),
    );
  }



  List<DayEvent<String>> get parsedDayEvents {
    List<DayEvent<String>> dayEvents = [];
    DateTime now = DateTime.now();

    for (var event in eventData) {
      try {
        String startTime = event["startTime"] as String;
        var startSplit = startTime.split(":");
        int startHour = int.parse(startSplit[0]);
        int startMinutes = int.parse(startSplit[1].substring(0, 2));

        String endTime = event["endTime"] as String;
        var endSplit = endTime.split(":");
        int endHour = int.parse(endSplit[0]);
        int endMinutes = int.parse(endSplit[1].substring(0, 2));

        String title = event["name"] as String;

        dayEvents.add(DayEvent<String>(
          start: DateTime(now.year, now.month, now.day, startHour, startMinutes),
          end: DateTime(now.year, now.month, now.day, endHour, endMinutes),
          value: title,
          name: title,
        ));
      } catch (e) {
        print("Error parsing event: $e");
      }
    }

    return dayEvents;
  }
}
