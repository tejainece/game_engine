import 'dart:math';
import 'dart:ui';

extension PointExt on Point<num> {
  Point<int> get toInt => Point(x.toInt(), y.toInt());
  Point<double> get toDouble => Point(x.toDouble(), y.toDouble());
  Size get s => Size(x.toDouble(), y.toDouble());
  Offset get o => Offset(x.toDouble(), y.toDouble());

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
  Size operator /(num other) => Size(width / 2, height / 2);

  Point<double> get p => Point<double>(width, height);

  Offset get o => Offset(width, height);

  Size sub(other) {
    if(other is num) {
      return Size(width - other, height - other);
    } else if(other is Size) {
      return Size(width - other.width, height - other.height);
    } else if(other is Offset) {
      return Size(width - other.dx, height - other.dy);
    } else {
      throw ArgumentError.value(other, 'other', 'cannot subtract a size with ${other.runtimeType}');
    }
  }

  Size multiply(num other) => Size(width * other, height * other);

  Size divide(num other) => Size(width / other, height / other);
}

extension OffsetExt on Offset {
  Point<double> get p => Point<double>(dx, dy);

  Offset mul(other) {
    if(other is num) {
      return Offset(dx * other, dy * other);
    } else if(other is Offset) {
      return Offset(dx * other.dx, dy * other.dy);
    } else if(other is Size) {
      return Offset(dx * other.width, dy * other.height);
    } else {
      throw ArgumentError.value(other, 'other', 'cannot multiply an offset with ${other.runtimeType}');
    }
  }
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
