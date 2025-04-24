import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proact/constants/constants.dart';
import 'package:proact/notification_service.dart';
import 'package:proact/screens/home/controller/home_controller.dart';
import 'package:proact/services/http_service.dart';
import 'package:proact/utils/app_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tabs/dashboard_screen.dart';

class GeminiPrompt extends StatefulWidget {
  final Function(List<Map<String, String>>) onSubmit;
  final int eventId;

  GeminiPrompt({required this.onSubmit, required this.eventId});

  @override
  _GeminiPromptState createState() => _GeminiPromptState();
}

class _GeminiPromptState extends State<GeminiPrompt> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  HttpService httpService = HttpService();

  Future<void> _submitEventPromptToGemini(String prompt) async {
    try {
      // Define events variable and add event details to the prompt
      List<Map<String, String>> events =
      []; // Replace with your actual events list

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String eventDataJson = prefs.getString('eventData') ?? '[]';
      events = List<Map<String, String>>.from(
        (jsonDecode(eventDataJson) as List)
            .map((e) => Map<String, String>.from(e)),
      );

      String? startTime =
      events[widget.eventId]['startTime']; // nullable String
      String? endTime = events[widget.eventId]['endTime']; // nullable String

      String promptWithMessage =
          'Imagine you have been given the following task: "' +
              events[widget.eventId]["name"]! +
              ' from ' +
              startTime! +
              ' to ' +
              endTime! +
              '". To better understand and approach this task effectively, consider asking questions that clarify: ' +
              prompt;

      print("prompt message ${promptWithMessage}");

      var response = await httpService.postRequest(AppUrls.gemini_url,showLoading: true,closeLoading: true,rowData: {
        "contents": [
          {
            "parts": [{"text" : promptWithMessage}]
          }
        ]
      });
      if(checkResponse(response.statusCode)){
        List parts = response.data["candidates"][0]["content"]["parts"] ?? []; // Display AI response
        print("response from ai ${response}");
        _controller.clear(); // Clear the text field after submission
        // });
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.black26,
                title: Text(
                  '${prompt} for \n"${events[widget.eventId]["name"]}"',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
                content: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      parts.isEmpty ? "No response" : parts.first['text'],
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              );
            });
      }

    } catch (e) {
      print('Error sending prompt to AI: $e');
      // Handle error scenario, such as showing a snackbar
    }
  }

  Future<void> _submitCreateEventPromptToGemini(String prompt) async {
    // final gemini = Gemini.instance; // Initialize Gemini instance

    try {
      // Get current time formatted in 24-hour format
      String currentTime = DateFormat.Hm().format(DateTime.now());

      // Construct the prompt message with the current time included
      String promptWithMessage = prompt;

      // Define events variable and add event details to the prompt
      List<Map<String, String>> events =
      []; // Replace with your actual events list

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String eventDataJson = prefs.getString('eventData') ?? '[]';
      events = List<Map<String, String>>.from(
        (jsonDecode(eventDataJson) as List)
            .map((e) => Map<String, String>.from(e)),
      );

      // Create a set to track used timings
      // Set<String> usedTimingsSet = {};
      String usedTimingsSet = "";

      for (int i = 0; i < events.length; i++) {
        String? startTime = events[i]['startTime']; // nullable String
        String? endTime = events[i]['endTime']; // nullable String

        // Ensure startTime and endTime are not null before using them
        if (startTime != null && endTime != null) {
          String formattedTiming = '$startTime - $endTime';

          usedTimingsSet += formattedTiming;
          if (i < (events.length - 1)) {
            usedTimingsSet += ", ";
          }
          // Ensure the timings are unique before adding to the set
          // if (!usedTimingsSet.contains(formattedTiming)) {
          //   promptWithMessage +=
          //       'TASK ${i + 1} == ${events[i]['name']} == $startTime - $endTime\n\n';

          //   usedTimingsSet.add(formattedTiming); // Add to used timings set
          // }
        }
      }

      promptWithMessage += usedTimingsSet.length > 0
          ? "\n*AVOID THE TIME SLOTS " + usedTimingsSet + "*\n"
          : "";
      // Add all used timings from event cards to ensure they are not repeated
      // List<String> usedTimings = usedTimingsSet.toList();

      // promptWithMessage += 'Busy Timings: ${usedTimings.join(', ')}';

      promptWithMessage += ' \nUse This Format:'
          'Task 1) # (NAME OF TASK) # START TIME - END TIME'+
          'Task 2) # (NAME OF TASK) # START TIME - END TIME'+
          'Do not use any bullet points or anything extra as this response will be decoded by a program that only accepts responses in the provided format.\n' +
          'Use 24-hour format for the time.\n' +
          '*MAKE SURE TO INCLUDE THE # OR ELSE THE RESPONSE WONT BE DECODED*\n' +
          '*MAKE SURE YOU GIVE THE START TIME FROM THE **NEXT PERFECT HOUR AFTER ($currentTime)*.\n' +
          '*DONT WRITE ANYTHING EXTRA THATS NOT IN THE FORMAT AND RESPOND IN 24HR FORMAT .**\n';

      print("prompt message ${promptWithMessage}");
      var response = await httpService.postRequest(AppUrls.gemini_url,showLoading: true,closeLoading: true,rowData: {
        "contents": [
          {
            "parts": [{"text" : promptWithMessage}]
          }
        ]
      });
      if(checkResponse(response.statusCode)) {
        List parts = response.data["candidates"][0]["content"]["parts"] ?? []; // Display AI response
        String responseText = parts.isEmpty ? "No response received" : parts.first['text'];
        setState(() {
          _response = responseText; // Display AI response
          _controller.clear(); // Clear the text field after submission
        });

        // Parse response into a list of event data
        List<Map<String, String>> parsedEventData = _parseEventData(responseText, events.length);
        widget.onSubmit(
            parsedEventData); // Pass parsed data back to parent widget
      }
    } catch (e) {
      print('Error sending prompt to AI: $e');
      // Handle error scenario, such as showing a snackbar
    }
  }

  List<Map<String, String>> _parseEventData(
      String? response, int prevEventCount) {
    List<Map<String, String>> eventData = [];

    if (response != null && response.isNotEmpty) {
      List<String> lines = response.split('\n');
      String? noOfTasks;

      for (String line in lines) {
        if (line.startsWith('No Of Tasks = ')) {
          noOfTasks = line.substring('No Of Tasks = '.length).trim();
        } else if (line.startsWith('Task')) {
          // Assuming line format: Task 1) # NAME OF THE TASK # START TIME - END TIME
          List<String> parts = line.split('#');

          if (parts.length >= 3) {
            String name = parts[1].trim();
            String timeFrame = parts[2].trim();

            // Extract start and end time from timeFrame
            // Example timeFrame: "NAME OF THE TASK # START TIME - END TIME"
            int startIndex = timeFrame.indexOf('#') + 1;
            int endIndex = timeFrame.lastIndexOf('-');

            if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
              String startTime =
              timeFrame.substring(startIndex, endIndex).trim();
              String endTime = timeFrame.substring(endIndex + 1).trim();

              DateTime now = DateTime.now();
              var timings = startTime.split(":");
              int startHour = int.parse(timings[0]);
              int startMinutes = int.parse(timings[1].substring(0, 2));
              var startDateTime = DateTime(
                  now.year, now.month, now.day, startHour, startMinutes);
              startDateTime = startDateTime.subtract(Duration(minutes: 5));

              print("new event number ${prevEventCount + eventData.length}");
              int eventNotifyId = prevEventCount + eventData.length;
              notifyService.scheduleNotification(
                  "Remainder",
                  "${name} ${startTime} - ${endTime}",
                  eventNotifyId,
                  startDateTime.day,
                  startDateTime.hour,
                  startDateTime.minute);
              eventData.add({
                'name': name,
                'startTime': startTime,
                'endTime': endTime,
                'currenttimeinmillis': '${now.millisecondsSinceEpoch}',
                'donesStatus': 'false'
              });
            }
          }
        }
      }
    }

    return eventData;
  }

  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       // Set background color to white
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              reverse: true, // Start scrolling from the bottom
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Display prompt sent to Gemini
                  if (_response.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('You: ${_controller.text}'),
                    ),

                  // Display response received from Gemini
                  if (_response.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('AI response: $_response'),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              // color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10)
              // BorderRadius.only(
              //   topLeft: Radius.circular(10.0),
              //   topRight: Radius.circular(10.0),
              // ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 18),
                    controller: _controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black,width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black,width: 1),
                      ),
                      hintText: 'Enter Your Tasks',
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.black),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        if (widget.eventId >= 0) {
                          _submitEventPromptToGemini(_controller.text);
                          homeController.loadEventData();
                        } else {
                          _submitCreateEventPromptToGemini(_controller.text);
                          homeController.loadEventData();

                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
