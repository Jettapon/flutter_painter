import 'package:flutter/material.dart';

class PolygonPainter extends CustomPainter {
  List<Offset> points = [];
  bool drawing = false;
  Offset? current;
  Paint? paintC;

  PolygonPainter(this.points, this.drawing, {this.paintC, this.current});

  @override
  void paint(Canvas canvas, Size size) {
    if (paintC != null) {
      paintC = Paint();
      paintC?.style = PaintingStyle.stroke;
      paintC?.strokeWidth = 4.0;
      paintC?.color = Colors.indigo;
    }

    final path = Path();
    final a = [...points];
    if (drawing && current != null) {
      a.add(current!);
    }
    path.addPolygon(a, true);
    canvas.drawPath(path, paintC!);
  }

  @override
  bool shouldRepaint(PolygonPainter oldDelegate) => false;
}
