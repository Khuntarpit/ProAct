import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCard extends StatefulWidget {
  final Map<String, String> event;
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
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Align delete button to the right
              children: [
                Row(
                  children: [
                    Icon(Icons.event, color: Colors.blueAccent, size: 20),
                    SizedBox(width: 8),
                    Container(
                      width: ((screenWidth - 10) / 2),
                      child: Text(
                        '${widget.event['name']}' ?? '',
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Color(0xFF1A1A1A)), // Delete icon button
                      onPressed: () {
                        widget.onEdit();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Color(0xFF1A1A1A)), // Delete icon button
                      onPressed: () {
                        widget
                            .onDelete(); // Call onDelete function when pressed
                      },
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(children: [
                  Icon(Icons.schedule, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Start Time: ${widget.event['startTime'] ?? ''}',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.message_rounded,
                          color: Color(0xFF1A1A1A)), // Delete icon button
                      onPressed: () {
                        widget.showGeminiPrompt();
                      },
                    ),
                    Checkbox(
                        value: widget.event['doneStatus'] == 'true',
                        checkColor: Colors.white,
                        activeColor: Color(0xFF1A1A1A),
                        onChanged: (value) {
                          print("checkbox on changed");
                          setState(() {
                            widget.markAsDone(value);
                          });
                        })
                  ],
                )
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blueAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'End Time: ${widget.event['endTime'] ?? ''}',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
