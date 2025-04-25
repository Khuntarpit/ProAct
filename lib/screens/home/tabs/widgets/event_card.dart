import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/value/app_colors.dart';

class EventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function onDelete;
  final Function onEdit;
  final Function showGeminiPrompt;
  final Function markAsDone;

  const EventCard(
      {super.key,
        required this.event,
        required this.onDelete,
        required this.onEdit,
        required this.showGeminiPrompt,
        required this.markAsDone});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
              value: widget.event['doneStatus'] == 'true',
              checkColor: Colors.blue.shade200,
              activeColor: Color(0xFF1A1A1A),
              onChanged: (value) {
                print("checkbox on changed");
                setState(() {
                  widget.markAsDone(value);
                });
              }),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(15.0),
                decoration: customBoxDecoration(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.event, color: Colors.blueAccent, size: 20),
                            SizedBox(width: 8),
                            Container(
                              width: ((screenWidth - 10) / 2),
                              child: Text(
                                '${widget.event['title']}' ?? '',
                                softWrap: true,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(children: [
                          Icon(Icons.schedule, color: Colors.blueAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Start Time: ${widget.event['start_time'] ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                            ),
                          ),
                        ]),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.blueAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'End Time: ${widget.event['end_time'] ?? ''}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.message_rounded, size: 18),
                          onPressed: () {
                            widget.showGeminiPrompt();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 18),
                          onPressed:() {
                            widget.onEdit();
                          } ,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 18),
                          onPressed: () {
                            widget.onDelete();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  BoxDecoration customBoxDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color:Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).iconTheme.color == AppColors.kblack
        ?Colors.grey.withOpacity(0.3)
        :Colors.black.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

}
