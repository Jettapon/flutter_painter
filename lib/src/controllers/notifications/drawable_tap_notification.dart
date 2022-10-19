import 'package:flutter_painter/flutter_painter.dart';

import '../drawables/drawable.dart';
import 'drawable_notification.dart';

/// A notification that is dispatched when a drawable is created internally in Flutter Painter.
class DrawableTapNotification
    extends DrawableNotification<ObjectDrawable> {
  /// Creates a [DrawableDoubleTapNotification] with the given [drawable].
  DrawableTapNotification(drawable) : super(drawable);
}
