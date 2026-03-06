import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class LessonTimerElement extends StatefulWidget {
//   const LessonTimerElement({super.key});

//   @override
//   State<LessonTimerElement> createState() => _LessonTimerElementState();
// }

// class _LessonTimerElementState extends State<LessonTimerElement> {
//   final String startTimeStr = "18:40";
//   final String endTimeStr = "19:05";
  

//   int convertTimeToMinutes(String timeStr) {
//     DateTime time = DateFormat.Hm().parse(timeStr);
//     return time.hour * 60 + time.minute;
//   }

//   double calculateProgressPercentage(
//     String startTime,
//     String endTime,
//     String currentTime,
//   ) {
//     int startMinutes = convertTimeToMinutes(startTime);
//     int endMinutes = convertTimeToMinutes(endTime);
//     int currentMinutes = convertTimeToMinutes(currentTime);
//     int durationMinutes = endMinutes - startMinutes;
//     int elapsedMinutes = currentMinutes - startMinutes;
//     return (elapsedMinutes / durationMinutes) * 100;
//   }

//   @override
//   Widget build(BuildContext context) {
    
//   DateTime now = DateTime.now();
//     String currentTimeStr = DateFormat.Hm().format(now).toString();
//     double percent =
//         calculateProgressPercentage(startTimeStr, endTimeStr, currentTimeStr) /
//         100;
//     return SizedBox(
//       width: 10,
//       height: 10,
//       child: LinePercentWidget(
//         percent: percent,
//         backgroundColor: Color.fromARGB(255, 61, 4, 4),
//         mainColor: Color.fromARGB(255, 180, 12, 12),
//         lineWidth: 2,
//       ),
//     );
//   }
// }

// class LinePercentWidget extends StatelessWidget {
//   final double percent;
//   final Color backgroundColor;
//   final Color mainColor;
//   final double lineWidth;

//   const LinePercentWidget({
//     super.key,
//     required this.percent,
//     required this.backgroundColor,
//     required this.mainColor,
//     required this.lineWidth,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20),
//       child: CustomPaint(
//         painter: LinePainter(
//           percent: percent,
//           backgroundColor: backgroundColor,
//           mainColor: mainColor,
//           lineWidth: lineWidth,
//         ),
//       ),
//     );
//   }
// }

// class LinePainter extends CustomPainter {
//   final double percent;
//   final Color backgroundColor;
//   final Color mainColor;
//   final double lineWidth;

//   LinePainter({
//     super.repaint,
//     required this.percent,
//     required this.backgroundColor,
//     required this.mainColor,
//     required this.lineWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final backGroundLine = Paint();
//     backGroundLine.strokeWidth = lineWidth;
//     backGroundLine.color = backgroundColor;
//     backGroundLine.strokeCap = StrokeCap.round;
//     canvas.drawLine(
//       Offset(lineWidth, lineWidth),
//       Offset(lineWidth, size.height - (lineWidth)),
//       backGroundLine,
//     );

//     final mainLine = Paint();
//     mainLine.strokeWidth = lineWidth;
//     mainLine.color = mainColor;
//     mainLine.strokeCap = StrokeCap.round;
//     canvas.drawLine(
//       Offset(lineWidth / 2, (size.height - (lineWidth / 2)) * percent),
//       Offset(lineWidth / 2, size.height - (lineWidth / 2)),
//       mainLine,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }


class LessonTimerElement extends StatefulWidget {
  final String startTime;
  final String endTime;

  const LessonTimerElement({
    super.key,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<LessonTimerElement> createState() => _LessonTimerElementState();
}

class _LessonTimerElementState extends State<LessonTimerElement> {
  double percent = 0;

  @override
  void initState() {
    super.initState();
    _updatePercent();

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 30));
      if (!mounted) return false;
      _updatePercent();
      return true;
    });
  }

  void _updatePercent() {
    setState(() {
      percent = _calculateProgress(widget.startTime, widget.endTime);
    });
  }

  int _minutes(String t) {
    final dt = DateFormat.Hm().parse(t);
    return dt.hour * 60 + dt.minute;
  }

  double _calculateProgress(String start, String end) {
    final now = DateFormat.Hm().format(DateTime.now());
    int s = _minutes(start);
    int e = _minutes(end);
    int c = _minutes(now);

    if (c <= s) return 0;
    if (c >= e) return 1;

    return (c - s) / (e - s);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,               // ширина фиксирована
      child: CustomPaint(
        painter: LinePainter(
          percent: percent,
          backgroundColor: Colors.grey.shade300,
          mainColor: Colors.redAccent,
          lineWidth: 3,
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double percent;
  final Color backgroundColor;
  final Color mainColor;
  final double lineWidth;

  LinePainter({
    required this.percent,
    required this.backgroundColor,
    required this.mainColor,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    final mainPaint = Paint()
      ..color = mainColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // вертикальная фоновая линия
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      bgPaint,
    );

    // активная часть
    final startY = size.height * (1 - percent);

    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width / 2, startY),
      mainPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

