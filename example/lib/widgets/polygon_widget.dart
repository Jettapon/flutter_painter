import 'package:example/widgets/polygon_painter.dart';
import 'package:flutter/material.dart';

class PolygonWidget extends StatefulWidget {
  final Widget child;
  final bool drawPolygon;
  final Paint? paint;
  final Function(List<Offset> points) onFinishDrawing;
  const PolygonWidget({
    required this.child,
    required this.onFinishDrawing,
    this.paint,
    this.drawPolygon = false,
    Key? key,
  }) : super(key: key);

  @override
  State<PolygonWidget> createState() => _PolygonWidgetState();
}

class _PolygonWidgetState extends State<PolygonWidget> {
  bool isDrawing = false;
  bool finish = false;

  List<Offset> point = [];

  Offset? currentPoint;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.drawPolygon)
          Container(
            color: Colors.amber,
            child: InteractiveViewer(
                onInteractionStart: ((details) {
                  isDrawing = true;

                  // details.localFocalPoint;
                  if (point.isEmpty) {
                    point.add(details.localFocalPoint);
                  }
                  setState(() {});
                  // print("Start : ${details}");
                }),
                onInteractionUpdate: ((details) {
                  currentPoint = details.localFocalPoint;
                  setState(() {});
                }),
                onInteractionEnd: ((details) {
                  if (currentPoint != null) {
                    point.add(currentPoint!);
                  }

                  currentPoint = null;
                }),
                minScale: 1,
                maxScale: 1,
                panEnabled: true,
                scaleEnabled: true,
                child: Column(
                  children: [
                    isDrawing
                        ? TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () {
                              isDrawing = false;
                              finish = true;
                              widget.onFinishDrawing(point);
                              point = [];
                              setState(() {});
                            },
                            child: const Text("finish"),
                          )
                        : Container(),
                    // Text("aa"),
                    Expanded(
                      child: Container(
                          color: Colors.transparent,
                          constraints:
                              BoxConstraints(minWidth: double.maxFinite),
                          child: CustomPaint(
                            painter: PolygonPainter(point, isDrawing,
                                paintC: widget.paint, current: currentPoint),
                          )),
                    ),
                  ],
                )),
          )
      ],
    );
  }
}
