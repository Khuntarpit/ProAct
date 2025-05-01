import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/controller/dashbord_controller.dart';
import 'package:proact/controller/home_controller.dart';

import 'dart:math';

import 'package:proact/core/value/app_colors.dart';


class TaskChartRow extends StatelessWidget {
  final int totalTask;
  final int completedTask;

   const TaskChartRow({
    Key? key,
    required this.totalTask,
    required this.completedTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double completionPercent = completedTask / totalTask;
    int pendingTask = totalTask - completedTask;
    return Container(
      color: Theme.of(context).iconTheme.color == AppColors.kblack ? Colors.white :Colors.black,
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 200,
            // width: 250,

            child: Center(
              child: Stack(
                children: [
                  _buildHalfLeftChart("Total", totalTask,context, isLeft: false),
                  _buildHalfRightChart("Pending", pendingTask,context, isLeft: false),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildFullChart(completedTask, "Completed", completionPercent,context),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totalTask.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 24,
                        
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Total\nTask",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),

                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pendingTask.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 24,
                        
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "pending\nTask",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),

                  ],
                )
                ],
            ),
          )

        ],
      )
    );
  }
  Widget _buildHalfLeftChart(String label, int value,BuildContext context, {required bool isLeft}  ) {
    return CustomPaint(
      size: const Size(90, 90),
      painter: HalfCirclePainter(progress: value.toDouble() / totalTask,activeColor: Theme.of(context).iconTheme.color ?? Colors.black),
    );
  }

  Widget _buildHalfRightChart(String label, int value,BuildContext context, {required bool isLeft}) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: Container(
        child: CustomPaint(
          size: const Size(90, 90),
          painter: HalfCirclePainter(progress: value.toDouble() / totalTask,activeColor: Theme.of(context).iconTheme.color ??Colors.black),
        ),
      ),
    );
  }

  Widget _buildFullChart(int value, String label, double percent, BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(120, 120),
              painter: FullCircleBackgroundPainter(),
            ),
            CustomPaint(
              size: const Size(120, 120),
              painter: FullCircleForegroundPainter(percent,Theme.of(context).iconTheme.color ?? Colors.black ),
            ),
           Column(
             children: [
               Text(
                 value.toString().padLeft(2, '0'),
                 style: const TextStyle(
                   fontSize: 28,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               Text(
                 "$label\nTask",
                 textAlign: TextAlign.center,
                 style: const TextStyle(fontSize: 14),
               ),
             ],
           ),

             ],
           )
      ],
    );
  }
}


class HalfCirclePainter extends CustomPainter {
  final double progress; // From 0 to 1
   Color activeColor; // From 0 to 1

  HalfCirclePainter({this.progress = 0.85,required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final foregroundPaint = Paint()
      ..color = activeColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final radius = size.width / 1.1;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final startAngle = -pi / 0.755; // -45° ; // Start from left
    final sweepAngle = 2.0; // Go 180 degrees

    // Draw background half arc
    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    // Draw progress arc
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class FullCircleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FullCircleForegroundPainter extends CustomPainter {
  final double percent;
  final Color activeColor;
  FullCircleForegroundPainter(this.percent,this.activeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = activeColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * percent,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



class TaskChart extends StatelessWidget {
   TaskChart({super.key});
 DashboardController dashboardController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:Theme.of(context).iconTheme.color == AppColors.kblack
                  ?Colors.grey.withOpacity(0.4)
                  :Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
          color: Theme.of(context).iconTheme.color == AppColors.kblack ? Colors.white :Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: GetBuilder<HomeController>(
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.tasksList.length < 4
                      ? 'You Have a Pretty Light Day'
                      : 'You Have a Pretty Busy Day',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.work, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${controller.tasksList.length} tasks',
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(width: 20),
                  ],
                ),
                Obx(() =>  TaskChartRow(
                  totalTask: dashboardController.totalTask.value,
                  completedTask: dashboardController.completedTask.value,
                ),)
               ,
                SizedBox(height: 8),
              ],
            );
          }
        ),
      ),
    );
  }
}
