import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/blockapps/screens/home.dart';
import 'package:proact/screens/home/tabs/event_calender_new.dart';
import 'package:proact/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/event_card.dart';

class DashboardScreen extends StatefulWidget {
  String emailPrefix;
  final List<Map<String, String>> eventData;
  final Function(int) deleteEvent;
  final Function() saveEventData;
  final Function(int) showGeminiPrompt;

  DashboardScreen(
      {required this.emailPrefix,
        required this.eventData,
        required this.deleteEvent,
        required this.saveEventData,
        required this.showGeminiPrompt});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  bool editUserName = false;
  final TextEditingController uNameController = TextEditingController();
  late AnimationController progreesController;

  @override
  void initState() {
    progreesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() {});
    });

    super.initState();
  }

  showBlockAppDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: EdgeInsets.fromLTRB(25, 30, 25, 30),
              child: BlockedHomePage());
        });
  }

  getTaskDoneStatus() {
    if (widget.eventData.length > 0) {
      print("object");
      int totalTasks = widget.eventData.length;
      int doneTasks = 0;
      for (var i = 0; i < widget.eventData.length; i++) {
        if (widget.eventData[i]['doneStatus'] == 'true') {
          doneTasks++;
        }
      }
      double value = doneTasks / totalTasks;
      if (totalTasks == 0)
        progreesController.value = 0;
      else
        progreesController.value = doneTasks / totalTasks;
      print(
          'task progress ${widget.eventData} done tasks, ${doneTasks} total tasks ${totalTasks}');

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            height: 22,
            padding: EdgeInsets.all(3),
            width: 200,
            child: LinearProgressIndicator(
              semanticsValue: "Task Progress",
              semanticsLabel: "Task Progress",
              borderRadius: BorderRadius.all(Radius.circular(15)),
              // backgroundColor: Colors.blue,
              color: Color(0xFF1A1A1A),
              backgroundColor: Colors.white,

              value: progreesController.value,
            ),
          ),
          Text(
            "${(progreesController.value * 100).toInt()}%",
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    int pendingTasks = widget.eventData.length; // Number of event cards/tasks
    String weekStatus = pendingTasks < 4
        ? 'You Have a Pretty Light Day'
        : 'You Have a Pretty Busy Day';

    return Scaffold(
      appBar: AppBar(
        leading: null, backgroundColor: Colors.transparent,
        title: editUserName
            ? getEditNameView(widget.emailPrefix)
            : TextButton(
            onPressed: () {
              setState(() {
                editUserName = true;
              });
            },
            child: Text(
              'Hi, ${widget.emailPrefix}',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )),
        actions: [
          InkWell(
            onTap: () {
              if (Platform.isAndroid) {
                showBlockAppDialog();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(20), child: Icon(Icons.lock),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
                  Text(
                    weekStatus,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.work, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('$pendingTasks tasks',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(width: 20),
                      //Progressbar
                      getTaskDoneStatus()
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Text(
              'List Of Tasks',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: widget.eventData.length,
              itemBuilder: (context, index) {
                return EventCard(
                    event: widget.eventData[index],
                    showGeminiPrompt: () {
                      widget.showGeminiPrompt(index);
                    },
                    onDelete: () {
                      widget
                          .deleteEvent(index); // Call deleteEvent with index
                      notifyService.cancelEventNotification(index);
                    },
                    markAsDone: (value) {
                      var event = widget.eventData[index];
                      setState(() {
                        if (value!) {
                          event['doneStatus'] = 'true';
                        } else {
                          event['doneStatus'] = 'false';
                        }
                      });
                      widget.saveEventData();
                    },
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          var event = widget.eventData[index];
                          final TextEditingController taskNameController =
                          TextEditingController();
                          final TextEditingController txtStartTimeController =
                          TextEditingController();
                          final TextEditingController txtEndTimeController =
                          TextEditingController();
                          taskNameController.text = event["name"]!;
                          txtStartTimeController.text = event["startTime"]!;
                          txtEndTimeController.text = event["endTime"]!;

                          print("edit event ${event}");
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
                                  setState(() {
                                    event["name"] = taskNameController.text;
                                    event["startTime"] =
                                        txtStartTimeController.text;
                                    event["endTime"] =
                                        txtEndTimeController.text;
                                    event["currenttimeinmillis"] =
                                    '${DateTime.now().millisecondsSinceEpoch}';
                                  });
                                  widget.saveEventData();
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
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  maxLines: null,
                                  controller: taskNameController,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: Colors.black26,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                      hintText: "Task Name"),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Start Time",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      List startTime =
                                      event["startTime"]!.split(":");
                                      int startHour = int.parse(startTime[0]);
                                      int startMin = int.parse(startTime[1]);
                                      TimeOfDay? timePicked =
                                      await showTimePicker(
                                          context: context,
                                          initialEntryMode:
                                          TimePickerEntryMode.dial,
                                          initialTime: TimeOfDay(
                                              hour: startHour,
                                              minute: startMin),
                                          builder: (BuildContext context,
                                              Widget? child) {
                                            return MediaQuery(
                                              data: MediaQuery.of(context)
                                                  .copyWith(
                                                  alwaysUse24HourFormat:
                                                  true),
                                              child: child!,
                                            );
                                          });
                                      if (timePicked != null) {
                                        String pickedHour =
                                        timePicked.hour > 9
                                            ? "${timePicked.hour}"
                                            : "0${timePicked.hour}";
                                        String pickedMin =
                                        timePicked.minute > 9
                                            ? "${timePicked.minute}"
                                            : "0${timePicked.minute}";
                                        setState(() {
                                          event["startTime"] =
                                          "${pickedHour}:${pickedMin}";
                                          txtStartTimeController.text =
                                          "${pickedHour}:${pickedMin}";
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.punch_clock)),
                                // Text("HI ${txtStartTimeController.text}"),
                                TextField(
                                  readOnly: true,
                                  controller: txtStartTimeController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "End Time",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),

                                IconButton(
                                    onPressed: () async {
                                      List endTime =
                                      event["endTime"]!.split(":");
                                      int endHour = int.parse(endTime[0]);
                                      int endMin = int.parse(endTime[1]);
                                      TimeOfDay? timePicked =
                                      await showTimePicker(
                                          context: context,
                                          initialEntryMode:
                                          TimePickerEntryMode.dial,
                                          initialTime: TimeOfDay(
                                              hour: endHour,
                                              minute: endMin),
                                          builder: (BuildContext context,
                                              Widget? child) {
                                            return MediaQuery(
                                              data: MediaQuery.of(context)
                                                  .copyWith(
                                                  alwaysUse24HourFormat:
                                                  true),
                                              child: child!,
                                            );
                                          });
                                      if (timePicked != null) {
                                        String pickedHour =
                                        timePicked.hour > 9
                                            ? "${timePicked.hour}"
                                            : "0${timePicked.hour}";
                                        String pickedMin =
                                        timePicked.minute > 9
                                            ? "${timePicked.minute}"
                                            : "0${timePicked.minute}";
                                        setState(() {
                                          event["endTime"] =
                                          "${pickedHour}:${pickedMin}";
                                          txtEndTimeController.text =
                                          "${pickedHour}:${pickedMin}";
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.punch_clock)),
                                // Text("HI ${txtStartTimeController.text}"),

                                TextField(
                                  readOnly: true,
                                  controller: txtEndTimeController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  getEditNameView(String username) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Expanded(
          child: TextField(
            controller: uNameController,
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
                hintStyle: TextStyle(
                    color: Colors.black26,
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
                hintText: "Enter Username"),
          )),
      Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: IconButton(
              onPressed: () {
                setState(() {
                  editUserName = false;
                });
              },
              icon: Icon(
                color: Color.fromARGB(255, 26, 26, 26),
                Icons.close,
                size: 30,
              ))),
      IconButton(
          onPressed: () {
            widget.emailPrefix = uNameController.text;
            storeUserEmailLocally(uNameController.text);
            setState(() {
              editUserName = false;
            });
          },
          icon: Icon(
            color: Color.fromARGB(255, 26, 26, 26),
            Icons.check,
            size: 30,
          ))
    ]);
  }

  void storeUserEmailLocally(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }
}
