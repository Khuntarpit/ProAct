import 'dart:convert';
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:proact/model/task_model.dart';
import 'package:proact/services/task_service.dart';
import 'package:proact/services/user_service.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home/gemini_prompt.dart';
import 'dashbord_controller.dart';

class HomeController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  RxString userEmail = ''.obs;
  RxString emailPrefix = ''.obs;
  RxInt currentIndex = 0.obs;
  Rx<bool> isLoading = false.obs;
  List<TaskModel> tasksList = <TaskModel>[];

  Future<void> loadUserTasks() async {
    isLoading.value = true;
    try {
      var data = await TasksService.getTasks();
      tasksList = data.map((e) => TaskModel.fromJson(e),).toList();
      print("✅ Fetched tasks: ${tasksList}");
      update();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(HiveStoreUtil.eventData, jsonEncode(tasksList.map((e) => e.toJson(),).toList()));
    } catch (e) {
      print('❗ Error fetching tasks: $e');
      tasksList = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(taskId, newStatus) async {
    await TasksService.updateTaskStatus(taskId, newStatus);
  }

  Future<void> deleteTask(taskId) async {
    await TasksService.deleteTask(taskId);
  }

  Future<void> updateTask(taskId,task) async {
    await TasksService.updateTask(taskId,task);
  }

  @override
  void onInit() {
    loadUserTasks();
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
          height: height,
          child: GeminiPrompt(
            onSubmit: (data) async{
              var user = await UserService.getCurrentUserData();
              var data2 = data.map((e) {
                e['created_by'] = user.userId;
                return e;
              }).toList();
              await saveEventData(data2);
              DashboardController contriller = Get.find();
              contriller.updateProgress();
            },
            eventId: eventId,
          ),
        );
      },
    );
  }

  Future<void> saveEventData(eventData) async {
    try {
      await TasksService.insertTask(eventData);
      loadUserTasks();
    } catch (e) {
      print('❗ Exception saving to Supabase: $e');
    }
  }

  List<DayEvent<String>> get parsedDayEvents {
    List<DayEvent<String>> dayEvents = [];
    DateTime now = DateTime.now();

    for (var event in tasksList) {
      try {
        String startTime = event.startTime;
        var startSplit = startTime.split(":");
        int startHour = int.parse(startSplit[0]);
        int startMinutes = int.parse(startSplit[1].substring(0, 2));

        String endTime = event.endTime;
        var endSplit = endTime.split(":");
        int endHour = int.parse(endSplit[0]);
        int endMinutes = int.parse(endSplit[1].substring(0, 2));

        String title = event.title;

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
