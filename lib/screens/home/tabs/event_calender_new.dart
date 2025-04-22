// import 'dart:math';

import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/tabs/overflow_day_view_tab.dart';
import 'package:intl/intl.dart';

class EventCalenderNew extends HookWidget {
  final List<Map<String, String>> eventData;

  const EventCalenderNew({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    List<DayEvent<String>> dayEventsNew = [];
    if (eventData.isNotEmpty) {
      DateTime now = DateTime.now();
      for (var i = 0; i < eventData.length; i++) {
        String startTime = eventData[i]["startTime"] as String;
        var timings = startTime.split(":");
        int startHour = int.parse(timings[0]);
        int startMinutes = int.parse(timings[1].substring(0, 2));

        String endTime = eventData[i]["endTime"] as String;
        timings = endTime.split(":");
        int endHour = int.parse(timings[0]);
        int endMinutes = int.parse(timings[1].substring(0, 2));

        String title = eventData[i]["name"] as String;

        try{
        DayEvent<String> newEvent = DayEvent<String>(
          start: DateTime(
              now.year, now.month, now.day, startHour, startMinutes),
          end: DateTime(now.year, now.month, now.day, endHour, endMinutes),
          value: title,
          name: title
        );

        dayEventsNew.add(newEvent);
        }catch(e){
          print("error ${e}");
        }
        print("starttime ${startTime} endTIme ${endTime} title ${title}");
      }
    }

    useState(dayEventsNew);

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          height: 120,
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
          color: Color.fromARGB(16, 26, 26, 26),
          child: OverflowDayViewTab(
            events: dayEventsNew,
          ),
        ),
      ),
    );
    // );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  CustomAppBar({this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(height + 80); // added height for extra content

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - DateTime.monday));
    final daysOfWeek = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      child: Container(
        height: preferredSize.height,
        padding: EdgeInsets.fromLTRB(16.0, 40, 16.0, 16.0),
        decoration: BoxDecoration(
          color: theme.iconTheme.color,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('MMMM yyyy').format(today),
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: daysOfWeek.map((day) {
                final isToday = day.day == today.day &&
                    day.month == today.month &&
                    day.year == today.year;
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEE').format(day),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      CircleAvatar(
                        backgroundColor:
                        isToday ? theme.primaryColor : Colors.transparent,
                        radius: 15,
                        child: Text(
                          day.day.toString(),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: isToday
                                  ? Colors.redAccent
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
