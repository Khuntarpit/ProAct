import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/value/app_colors.dart';

class EventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function onDelete;
  final Function onEdit;
  final Function showGeminiPrompt;
  final Function markAsDone;
  final int index;
  final int listLength;

  const EventCard(
      {super.key,
        required this.index,
        required this.listLength,
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
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                if(widget.index != 0)
                Column(
                  children: [
                    Text(".",style: TextStyle(color: Colors.grey),),
                    Text(".",style: TextStyle(color: Colors.grey),),
                  ],
                ), if(widget.index == 0)
                Column(
                  children: [
                    Text("",style: TextStyle(color: Colors.grey),),
                    Text("",style: TextStyle(color: Colors.grey),),
                  ],
                ),
                Text(widget.event['start_time'] ?? '',style: TextStyle(fontSize: 15,color: Colors.grey),),
                if(widget.listLength-1 != widget.index)
                Column(
                  children: [
                    Text(".",style: TextStyle(color: Colors.grey),),
                    Text(".",style: TextStyle(color: Colors.grey),),
                    Text(".",style: TextStyle(color: Colors.grey),),
                    Text(".",style: TextStyle(color: Colors.grey),),
                  ],
                ),
                if(widget.listLength == widget.index)
                  Column(
                    children: [
                      Text("",style: TextStyle(color: Colors.grey),),
                      Text("",style: TextStyle(color: Colors.grey),),
                      Text("",style: TextStyle(color: Colors.grey),),
                      Text("",style: TextStyle(color: Colors.grey),),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(15.0),
              decoration: customBoxDecoration(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${widget.event['title']}' ?? '',
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 2,
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8,),
                            if(widget.event['doneStatus'] == 1 )

                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:Color(0xff00d00e).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8)

                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text("Completed",style: TextStyle(color: Colors.green,fontSize: 12),),
                                ),
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0,left: 0,bottom: 8),
                          child: Container(
                            height: 0.3,
                            width: double.infinity,
                            color: Colors.grey,
                          ),
                        ),
                        Row(children: [
                          Icon(Icons.schedule, color: Colors.blueAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Time: ${widget.event['start_time'] ?? ''} - ${widget.event['end_time'] ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                            ),
                          ),

                        ]),
                        Container(
                          height: 30,
                        )

                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IconButton(
                      //   icon: Icon(Icons.message_rounded, size: 18),
                      //   onPressed: () {
                      //     widget.showGeminiPrompt();
                      //   },
                      // ),
                      GestureDetector(
                        onTap: () {
                          widget.onEdit();
                        },
                        child: SvgPicture.asset(
                          "assets/icons/edit_icon.svg",
                        ),
                      ),
                      SizedBox(height: 12,),
                      GestureDetector(
                        onTap: () {
                          widget.onDelete();
                        },
                        child: SvgPicture.asset(
                          "assets/icons/delete_icon.svg",
                        ),
                      ),
                      SizedBox(height: 12,),

                      GestureDetector(
                        onTap: () {
                         setState(() {
                           widget.event['doneStatus'] = widget.event['doneStatus'] == 0 ? 1 : 0;
                         });
                        },
                        child: SvgPicture.asset(
                          widget.event['doneStatus'] == 0 ?
                          "assets/icons/grey_check_icon.svg"
                          :"assets/icons/green_check_icon.svg"
                        ),
                      ),



                    ],
                  ),
                ],
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
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(65),topLeft: Radius.circular(20)),
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
