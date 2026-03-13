import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      width: 10,         
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

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      bgPaint,
    );

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

