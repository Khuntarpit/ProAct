import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/blockapps/screens/home.dart';
import 'package:proact/routes/routes.dart';
import 'package:proact/screens/home/controller/home_controller.dart';
import 'package:proact/screens/home/tabs/event_calender_new.dart';
import 'package:proact/notification_service.dart';
import 'package:proact/screens/home/tabs/widgets/task_chart.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/dashbord_controller.dart';
import 'widgets/event_card.dart';
class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final HomeController homeController = Get.put(HomeController());

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
              child: CircleAvatar(
                child: Icon(Icons.person, color: Colors.black),
                backgroundColor: Colors.white,
              ),
            ),
            Text(
              'Hi, ${HiveStoreUtil.getString(HiveStoreUtil.emailKey)}',
              style: GoogleFonts.poppins(
                fontSize: 24,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black,
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
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.work, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Obx(() => Text(
                        '${controller.eventData.length} tasks',
                        style: TextStyle(color: Colors.white),
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
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: controller.eventData.length,
                itemBuilder: (context, index) {
                  return EventCard(
                    event: controller.eventData[index],
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          var event = controller.eventData[index];
                          final TextEditingController taskNameController =
                          TextEditingController();
                          final TextEditingController txtStartTimeController =
                          TextEditingController();
                          final TextEditingController txtEndTimeController =
                          TextEditingController();
                          taskNameController.text = event["name"]!;
                          txtStartTimeController.text = event["startTime"]!;
                          txtEndTimeController.text = event["endTime"]!;

                          return AlertDialog(
                            title: Text("Edit Task"),
                            titleTextStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF1A1A1A)),
                            buttonPadding: EdgeInsets.all(25),
                            actions: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  controller.saveEvent(index, {
                                    'name': taskNameController.text,
                                    'startTime': txtStartTimeController.text,
                                    'endTime': txtEndTimeController.text,
                                    'currenttimeinmillis':
                                    '${DateTime.now().millisecondsSinceEpoch}',
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Save Task",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Task Name",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  controller: taskNameController,
                                  decoration: InputDecoration(hintText: "Task Name"),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Start Time",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    List startTime = event["startTime"]!.split(":");
                                    int startHour = int.parse(startTime[0]);
                                    int startMin = int.parse(startTime[1]);
                                    TimeOfDay? timePicked = await showTimePicker(
                                      context: context,
                                      initialEntryMode: TimePickerEntryMode.dial,
                                      initialTime: TimeOfDay(hour: startHour, minute: startMin),
                                    );
                                    if (timePicked != null) {
                                      String pickedHour =
                                      timePicked.hour > 9 ? "${timePicked.hour}" : "0${timePicked.hour}";
                                      String pickedMin =
                                      timePicked.minute > 9 ? "${timePicked.minute}" : "0${timePicked.minute}";
                                      controller.saveEvent(index, {
                                        'startTime': "$pickedHour:$pickedMin",
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.punch_clock),
                                ),
                                TextField(
                                  controller: txtStartTimeController,
                                  readOnly: true,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "End Time",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    List endTime = event["endTime"]!.split(":");
                                    int endHour = int.parse(endTime[0]);
                                    int endMin = int.parse(endTime[1]);
                                    TimeOfDay? timePicked = await showTimePicker(
                                      context: context,
                                      initialEntryMode: TimePickerEntryMode.dial,
                                      initialTime: TimeOfDay(hour: endHour, minute: endMin),
                                    );
                                    if (timePicked != null) {
                                      String pickedHour =
                                      timePicked.hour > 9 ? "${timePicked.hour}" : "0${timePicked.hour}";
                                      String pickedMin =
                                      timePicked.minute > 9 ? "${timePicked.minute}" : "0${timePicked.minute}";
                                      controller.saveEvent(index, {
                                        'endTime': "$pickedHour:$pickedMin",
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.punch_clock),
                                ),
                                TextField(
                                  controller: txtEndTimeController,
                                  readOnly: true,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
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
