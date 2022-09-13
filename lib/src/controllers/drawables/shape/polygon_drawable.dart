import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

class PolygonDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// The paint to be used for the line drawable.
  @override
  Paint paint;
  List<Offset> points;

  /// Creates a new [OvalDrawable] with the given [size] and [paint].
  PolygonDrawable({
    Paint? paint,
    required Size size,
    required Offset position,
    required this.points,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
  })  : paint = paint ?? ShapeDrawable.defaultPaint,
        super(
            size: size,
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            locked: locked,
            hidden: hidden);

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the paint.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(paint.strokeWidth / 2);

  /// Draws the arrow on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    final drawingSize = this.size * scale;
    canvas.drawOval(
        Rect.fromCenter(
            center: position,
            width: drawingSize.width,
            height: drawingSize.height),
        paint);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  PolygonDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    List<Offset>? points,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
  }) {
    return PolygonDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      points: points ?? this.points,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      size: size ?? this.size,
      locked: locked ?? this.locked,
      paint: paint ?? this.paint,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final size = super.getSize();
    return Size(size.width, size.height);
  }

  /// Compares two [OvalDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is OvalDrawable &&
  //       super == other &&
  //       other.paint == paint &&
  //       other.size == size;
  // }
  //
  // @override
  // int get hashCode => hashValues(
  //     hidden,
  //     locked,
  //     hashList(assists),
  //     hashList(assistPaints.entries),
  //     position,
  //     rotationAngle,
  //     scale,
  //     paint,
  //     size);
}
