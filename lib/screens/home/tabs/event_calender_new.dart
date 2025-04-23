import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:proact/screens/home/tabs/widgets/calendar_appbar.dart';

import '../../../tabs/overflow_day_view_tab.dart';
import '../controller/home_controller.dart';

class EventCalenderNew extends HookWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CalendarAppBar(
          onDateChange: (p0) {

          },
          height: 130,
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
          color: Color.fromARGB(16, 26, 26, 26),
          child: OverflowDayViewTab(),
        ),
      ),
    );
  }
}
