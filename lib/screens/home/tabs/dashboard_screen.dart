import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/blockapps/screens/home.dart';
import 'package:proact/routes/routes.dart';
import 'package:proact/screens/home/controller/home_controller.dart';
import 'package:proact/notification_service.dart';
import 'package:proact/screens/home/tabs/widgets/task_chart.dart';
import 'package:proact/services/task_service.dart';
import 'package:proact/utils/hive_store_util.dart';

import '../../../core/value/app_colors.dart';
import '../controller/dashbord_controller.dart';
import 'widgets/event_card.dart';
class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final HomeController homeController = Get.put(HomeController());
  final TasksController taskController = Get.put(TasksController());


  @override
  Widget build(BuildContext context) {
    controller.setEvents(homeController.eventData);

    return Scaffold(
      appBar: AppBar(
        leading: null,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            InkWell(
              onTap: () => Get.toNamed(Routes.profileScreen),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                 backgroundImage: NetworkImage("https://c1.35photo.pro/profile/photos/192/963119_140.jpg"),
                ),
              ),
            ),
            Text(
              'Hi, ${HiveStoreUtil.getString(HiveStoreUtil.emailKey)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () {
              if (Platform.isAndroid) {
                showBlockAppDialog(context);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Icon(
                Icons.lock,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color:Theme.of(context).iconTheme.color == AppColors.kblack
                          ?Colors.grey.withOpacity(0.4)
                          :Colors.black.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                  color: Theme.of(context).iconTheme.color == AppColors.kblack ? Colors.white :Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      String weekStatus = controller.eventData.length < 4
                          ? 'You Have a Pretty Light Day'
                          : 'You Have a Pretty Busy Day';
                      return Text(
                        weekStatus,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.work, size: 16),
                        SizedBox(width: 4),
                        Obx(() => Text(
                          '${controller.eventData.length} tasks',
                          style: TextStyle(fontSize: 17),
                        )),
                        SizedBox(width: 20),
        
                      ],
                    ),
                    TaskChartRow(
                      totalTask: 10,
                      completedTask: 1,
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'List Of Tasks',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Obx(() {
              return Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: taskController.isLoading.value
                    ? Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(child: CircularProgressIndicator(color: Colors.grey,)),
                    )
                    : taskController.tasksList.length < 1
                    ? Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(child: Text("No Task",style: TextStyle(color: Colors.grey,fontSize: 16),)),
                    )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: taskController.tasksList.length,
                  itemBuilder: (context, index) {
                    return EventCard(
                      id: taskController.tasksList[index]["id"],
                      status: taskController.tasksList[index]["status"],
                      index: index,
                      listLength: taskController.tasksList.length,
                      event: taskController.tasksList[index],
                      showGeminiPrompt: () {
                        homeController.showGeminiPrompt(context,index);
                      },
                      onDelete: () {
                        controller.deleteEvent(index);
                        notifyService.cancelEventNotification(index);
                      },
                      markAsDone: (value) {
                        controller.markEventAsDone(index, value);
                      },
                      onEdit: () {
                        showEditTaskDialog(
                          context: context,
                          task: taskController.tasksList[index],
                          index: index,
                          onSave: (updatedTask) {
                            controller.saveEvent(index, updatedTask);
                          },
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void showEditTaskDialog({
    required BuildContext context,
    required Map<String, dynamic> task,
    required int index,
    required Function(Map<String, dynamic>) onSave,
  }) {
    final taskNameController = TextEditingController(text: task["title"] ?? '');
    final txtStartTimeController = TextEditingController(text: task["start_time"] ?? '');
    final txtEndTimeController = TextEditingController(text: task["end_time"] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF1A1A1A),
        ),
        buttonPadding: const EdgeInsets.all(25),
        actions: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 15, color: Colors.grey)),
          ),
          InkWell(
            onTap: () {
              onSave({
                'title': taskNameController.text,
                'start_time': txtStartTimeController.text,
                'end_time': txtEndTimeController.text,
                'currenttimeinmillis': '${DateTime.now().millisecondsSinceEpoch}',
              });
              Navigator.pop(context);
            },
            child: const Text("Save Task", style: TextStyle(fontSize: 15, color: Colors.blue)),
          ),
        ],
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLabel("Task Name"),
              TextField(
                controller: taskNameController,
                decoration: const InputDecoration(hintText: "Task Name"),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildLabel("Start Time"),
              TextField(
                controller: txtStartTimeController,
                readOnly: true,
                onTap: () async {
                  final time = await _pickTime(context, task["start_time"]);
                  if (time != null) txtStartTimeController.text = time;
                },
                decoration: const InputDecoration(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildLabel("End Time"),
              TextField(
                controller: txtEndTimeController,
                readOnly: true,
                onTap: () async {
                  final time = await _pickTime(context, task["end_time"]);
                  if (time != null) txtEndTimeController.text = time;
                },
                decoration: const InputDecoration(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Future<String?> _pickTime(BuildContext context, String? initial) async {
    if (initial == null || !initial.contains(":")) return null;
    final parts = initial.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final min = int.tryParse(parts[1]) ?? 0;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: min),
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (time != null) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return "$h:$m";
    }
    return null;
  }


  Future showBlockAppDialog(BuildContext context) {
     return showDialog(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          margin: EdgeInsets.fromLTRB(25, 30, 25, 30),
          child: BlockedHomePage(),
        );
      },
    );
  }

}
