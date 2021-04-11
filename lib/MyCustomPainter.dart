import 'dart:ui';
import 'package:flutter/material.dart';

import 'CustomPointMode.dart';
import 'DrawingArea.dart';

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points;
  final previousPointDistance = 2;

  MyCustomPainter({@required this.points}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    for (int x = 0; x < points.length - 1; x++) {
      if (points[x] != null &&
          points[x].pointMode == CustomPointMode.endOfLine) {
        canvas.drawLine(
            points[x - previousPointDistance].point, points[x].point, points[x].areaPaint);
      } else if (points[x] != null &&
          points[x].pointMode == CustomPointMode.endOfRect) {
        final rect = Rect.fromPoints(points[x - previousPointDistance].point, points[x].point);
        canvas.drawRect(rect, points[x].areaPaint);
      } else if (points[x] != null && points[x + 1] != null) {
        canvas.drawLine(
            points[x].point, points[x + 1].point, points[x].areaPaint);
      } else if (points[x] != null &&
          points[x + 1] == null &&
          points[x].pointMode == CustomPointMode.point) {
        canvas.drawPoints(
            PointMode.points, [points[x].point], points[x].areaPaint);
      }
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) => true;
}
