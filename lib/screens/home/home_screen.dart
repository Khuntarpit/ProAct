import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';
import 'package:proact/screens/home/tabs/event_calender_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gemini_prompt.dart';
import 'tabs/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key,}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userEmail = '';
  String emailPrefix = '';
  List<Map<String, String>> eventData = [];
  int currentIndex = 0;

  void showGeminiPrompt(int eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height / 2,
          child: GeminiPrompt(
            onSubmit: (data) {
              setState(() {
                eventData.addAll(data);
              });
              saveEventData(); // Save eventData after adding new tasks
            },
            eventId: eventId,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUserEmail();
    loadEventData(); // Load stored eventData when the widget initializes
    resetEventDataIfNeeded(); // Reset eventData if it's a new day
  }

  void getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? '';
      emailPrefix = userEmail.split('@').first;
    });
  }

  void resetEventDataIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime? lastRefreshDate =
    DateTime.tryParse(prefs.getString('lastRefreshDate') ?? '');
    DateTime currentDate = DateTime.now();
    if (lastRefreshDate == null || lastRefreshDate.day != currentDate.day) {
      // Reset eventData if it's a new day
      setState(() {
        eventData.clear();
      });
      await prefs.setString('lastRefreshDate', currentDate.toString());
      saveEventData(); // Save empty eventData to clear storage
    }
  }

  void saveEventData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("saving event data ${eventData}");
    String eventData_json = jsonEncode(eventData);
    await prefs.setString('eventData', eventData_json);
    await Get.find<MethodChannelController>().saveEvents(eventData_json);
  }

  void loadEventData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventDataJson = prefs.getString('eventData') ?? '[]';
    setState(() {
      eventData = List<Map<String, String>>.from(
        (jsonDecode(eventDataJson) as List)
            .map((e) => Map<String, String>.from(e)),
      );
    });
  }

  void deleteEvent(int index) async {
    setState(() {
      eventData.removeAt(index); // Remove event from eventData list
    });
    saveEventData(); // Save updated eventData to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: currentIndex == 0 ?  DashboardScreen(
          showGeminiPrompt: showGeminiPrompt,
          emailPrefix: emailPrefix,
          eventData: eventData,
          deleteEvent: deleteEvent,
          saveEventData: saveEventData, // Pass deleteEvent function
        ) : EventCalenderNew(eventData: eventData),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showGeminiPrompt(-1);
          },
          backgroundColor: Color(0xFF1a1a1a),
          child: Icon(Icons.chat, color: Colors.white),
        ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF1A1A1A),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, size: 24),
          label: '',
        ),
      ],
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
    );
  }
}


