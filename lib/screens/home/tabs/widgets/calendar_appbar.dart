
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final void Function(DateTime) onDateChange;

  CalendarAppBar({
    this.height = kToolbarHeight,
    required this.onDateChange,
  });

  @override
  Size get preferredSize => Size.fromHeight(height + 100);
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Material(
      elevation: 1,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.fromLTRB(16.0, 40, 16.0, 16.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EasyDateTimeLinePicker.itemBuilder(
              focusedDate: selectedDate,
              firstDate: DateTime(2025, 1, 1),
              lastDate: DateTime(2030, 3, 18),
              itemExtent: 64,
              onDateChange: (date) {
                selectedDate = date;
              },
              itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
                return InkWell(
                  onTap: onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 0.5,color: Colors.grey)
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        CircleAvatar(
                          backgroundColor:
                          isSelected ? theme.scaffoldBackgroundColor : Colors.transparent,
                          radius: 15,
                          child: Text(
                            date.day.toString(),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
