import 'dart:math';
import 'dart:ui';

extension PointExt on Point<num> {
  Point<int> get toInt => Point(x.toInt(), y.toInt());
  Point<double> get toDouble => Point(x.toDouble(), y.toDouble());
  Size get toSize => Size(x.toDouble(), y.toDouble());
  Offset get toOffset => Offset(x.toDouble(), y.toDouble());

  Point<double> operator /(other) {
    if (other == null) {
      throw ArgumentError.notNull('other');
    }

    if (other is Point) {
      return Point<double>(x / other.x, y / other.y);
    } else if (other is num) {
      return Point<double>(x / other, y / other);
    }

    throw ArgumentError.value(
        other, 'other', 'cannot divide a point with ${other.runtimeType}');
  }
}

extension SizeExt on Size {
  Point<double> get toPoint => Point<double>(width, height);
}

extension OffsetExt on Offset {
  Point<double> get toPoint => Point<double>(dx, dy);
}

extension RectangleExt on Rectangle<num> {
  Iterable<Point<int>> get positions sync* {
    for (int x = left.toInt(); x <= right; x++) {
      for (int y = top.toInt(); y <= bottom; y++) {
        yield Point<int>(x, y);
      }
    }
  }

  Rect get rect => Rect.fromLTWH(
      left.toDouble(), top.toDouble(), width.toDouble(), height.toDouble());
}
