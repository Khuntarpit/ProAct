import 'dart:convert';
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/services/task_service.dart';
import 'package:proact/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../model/user_model.dart';
import '../../../utils/hive_store_util.dart';
import '../gemini_prompt.dart';

class HomeController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  RxString userEmail = ''.obs;
  RxString emailPrefix = ''.obs;
  RxList<Map<String, dynamic>> eventData = <Map<String, dynamic>>[].obs;
  RxInt currentIndex = 0.obs;

  TasksController tasksController = Get.put(TasksController());

  @override
  void onInit() {
    super.onInit();
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
        return  Container(
          padding: const EdgeInsets.all(16.0),
          height: height,
          child: GeminiPrompt(
            onSubmit: (data) async{
              var user = await UserService.getCurrentUserData();
              var data2 = data.map((e) {
                e['created_by'] = user.userId;
                return e;
              }).toList();
              eventData.addAll(data2);
              saveEventData(data2);
              Future.delayed(Duration(seconds: 5), () {
                tasksController.loadUserTasks();
              });
            },
            eventId: eventId,
          ),
        );
      },
    );
  }

  Future<void> saveEventData(eventData) async {

    final supabase = Supabase.instance.client;

    String eventDataJson = jsonEncode(eventData);

    await Get.find<MethodChannelController>().saveEvents(eventDataJson);

    try {
      final response = await supabase.from('Tasks').insert(eventData);

      if (response.error != null) {
        print('❗ Supabase error: ${response.error!.message}');
      } else {
        print('✅ Data saved to Supabase: ${response.data}');
      }
    } catch (e) {
      print('❗ Exception saving to Supabase: $e');
    }
  }

  // Future<void> loadEventData() async {
  //   try {
  //     final supabase = Supabase.instance.client;
  //
  //     final userId = HiveStoreUtil.getString(HiveStoreUtil.userIdKey);
  //
  //     final response = await supabase
  //         .from(TasksController.tasks)
  //         .select()
  //         .eq(TasksController.createdBy, userId);
  //
  //     if (response.isEmpty) {
  //       print('⚠️ No events found for user.');
  //       eventData.value = [];
  //     } else {
  //       eventData.value = List<Map<String, dynamic>>.from(response);
  //       print('✅ Loaded ${eventData.length} events from Supabase');
  //     }
  //   } catch (e) {
  //     print('❗ Error loading event data from Supabase: $e');
  //     eventData.value = [];
  //   }
  // }


  List<DayEvent<String>> get parsedDayEvents {
    List<DayEvent<String>> dayEvents = [];
    DateTime now = DateTime.now();

    for (var event in eventData) {
      try {
        String startTime = event["start_time"] as String;
        var startSplit = startTime.split(":");
        int startHour = int.parse(startSplit[0]);
        int startMinutes = int.parse(startSplit[1].substring(0, 2));

        String endTime = event["end_time"] as String;
        var endSplit = endTime.split(":");
        int endHour = int.parse(endSplit[0]);
        int endMinutes = int.parse(endSplit[1].substring(0, 2));

        String title = event["title"] as String;

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
