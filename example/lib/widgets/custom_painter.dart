import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomPainterWidget extends StatefulWidget {
  final Paint? paint;
  final bool isOpenDraw;
  final Function(PainterPolygonModel)? onFinishDrawing;

  const CustomPainterWidget(
      {this.paint, this.onFinishDrawing, this.isOpenDraw = false, Key? key})
      : super(key: key);

  @override
  State<CustomPainterWidget> createState() => CustomPainterWidgetState();
}

class CustomPainterWidgetState extends State<CustomPainterWidget> {
  List<Offset> points = [];
  bool isDrawing = false;
  LinePolygonType _lineType = LinePolygonType.line;

  Offset? currentPoint;

  LinePolygonType get linePolygonType => _lineType;

  set linePolygonType(LinePolygonType value) {
    _lineType = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("adwad");
    return widget.isOpenDraw
        ? GestureDetector(
            onScaleStart: ((details) {
              isDrawing = true;
              // details.localFocalPoint;
              if (points.isEmpty) {
                points.add(details.localFocalPoint);
              }
              setState(() {});
              print("Start : ${details}");
            }),
            onScaleUpdate: ((details) {
              currentPoint = details.localFocalPoint;
              setState(() {});
              print("onScaleUpdate : ${details}");
            }),
            onScaleEnd: ((details) {
              if (currentPoint != null) {
                points.add(currentPoint!);
              }
              currentPoint = null;
            }),
            child: Container(
                color: Colors.transparent,
                constraints: const BoxConstraints(
                    minWidth: double.infinity, minHeight: double.infinity),
                child: CustomPaint(
                  painter: PolygonPainter(points, isDrawing,
                      paintC: widget.paint,
                      current: currentPoint,
                      lineType: _lineType),
                )))
        : Container();
  }

  void resetPolygon() {
    isDrawing = false;
    points = [];
  }

  Future<void> renderImage() async {
    if (points.isEmpty) return;
    final dx =
        points.map((e) => e.dx).reduce((value, element) => value + element);
    final dy =
        points.map((e) => e.dy).reduce((value, element) => value + element);

    final minDx = points
            .map((e) => e.dx)
            .reduce((value, element) => value < element ? value : element) -
        (_lineType == LinePolygonType.cloud ? 40 : 0);
    final maxDx = points
            .map((e) => e.dx)
            .reduce((value, element) => value > element ? value : element) +
        (_lineType == LinePolygonType.cloud ? 40 : 0);
    final minDy = points
            .map((e) => e.dy)
            .reduce((value, element) => value < element ? value : element) -
        (_lineType == LinePolygonType.cloud ? 40 : 0);
    final maxDy = points
            .map((e) => e.dy)
            .reduce((value, element) => value > element ? value : element) +
        (_lineType == LinePolygonType.cloud ? 40 : 0);

    final center = Offset((dx / points.length).ceilToDouble(),
        (dy / points.length).ceilToDouble());

    final width = (minDx - maxDx).abs();
    final height = (minDy - maxDy).abs();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    canvas.translate(-minDx, -minDy);

    final painter = PolygonPainter(points, false,
        paintC: widget.paint, lineType: _lineType);

    painter.paint(canvas, Size(width, height));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.ceil(), height.ceil());

    widget.onFinishDrawing?.call(PainterPolygonModel(
        points: points, image: img, position: center, lineType: _lineType));

    isDrawing = false;
    points = [];

    // final drawable = ImageDrawable(image: img, position: center);
    // controller.addDrawables([drawable]);
    // setState(() {});
  }
}

class PainterPolygonModel {
  List<Offset> points;
  LinePolygonType lineType;
  ui.Image image;
  ui.Offset? position;

  PainterPolygonModel(
      {required this.points,
      required this.image,
      this.position,
      this.lineType = LinePolygonType.line});
}

enum LinePolygonType { line, cloud }

class PolygonPainter extends CustomPainter {
  List<Offset> points = [];
  bool drawing = false;
  LinePolygonType lineType;
  Offset? current;
  Paint? paintC;

  PolygonPainter(this.points, this.drawing,
      {this.paintC, this.current, this.lineType = LinePolygonType.line});

  @override
  void paint(Canvas canvas, Size size) {
    if (paintC == null) {
      paintC = Paint();
      paintC?.style = PaintingStyle.stroke;
      paintC?.strokeWidth = 4.0;
      paintC?.color = Colors.indigo;
    }

    if (lineType == LinePolygonType.cloud) {
      _drawCloud(canvas);
    } else {
      final path = Path();
      final a = [...points];
      if (drawing && current != null) {
        a.add(current!);
      }
      path.addPolygon(a, true);
      canvas.drawPath(path, paintC!);
    }
  }

  void _drawCloud(Canvas canvas) {
    canvas.save();
    final path = Path();

    for (var i = 0; i < points.length; i++) {
      var p2 = points[0];
      final p1 = points[i];

      if (points.length - 1 == i && drawing) break;

      if (points.length - 1 != i) {
        p2 = points[i + 1];
      }

      path.moveTo(p1.dx, p1.dy);
      _pointStartToEnd(path, p1, p2);
    }

    if (current != null && points.isNotEmpty) {
      final f = points.first;
      final l = points.last;
      path.moveTo(l.dx, l.dy);
      _pointStartToEnd(path, l, current!);
      _pointStartToEnd(path, current!, f);
    } else if (current == null && points.isNotEmpty) {
      final f = points.first;
      final l = points.last;
      _pointStartToEnd(path, l, f);
    }

    canvas.drawPath(path, paintC!);

    canvas.restore();
  }

  void _pointStartToEnd(Path path, Offset p1, Offset p2) {
    final disX = (p2.dx - p1.dx) / 5;
    final disY = (p2.dy - p1.dy) / 5;

    for (var index = 1; index <= 5; index++) {
      if (index == 1) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.moveTo(p1.dx + (disX * (index - 1)), p1.dy + (disY * (index - 1)));
      }

      final currentPoint =
          Offset(p1.dx + (disX * index), p1.dy + (disY * index));
      path.arcToPoint(currentPoint, radius: const Radius.circular(20));
    }
  }

  @override
  bool shouldRepaint(PolygonPainter oldDelegate) => false;
}
