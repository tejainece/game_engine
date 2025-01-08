import 'dart:ui';

import 'package:vector_path/vector_path.dart';

export 'paint.dart';
export 'utils.dart';

extension SegmentsPathExt on Iterable<Segment> {
  Path get path {
    final path = Path();
    if (isEmpty) return path;
    path.moveTo(first.p1.x, first.p1.y);
    for (final segment in this) {
      if (segment is LineSegment) {
        path.lineTo(segment.p2.x, segment.p2.y);
      } else if (segment is CubicSegment) {
        path.cubicTo(segment.c1.x, segment.c1.y, segment.c2.x, segment.c2.y,
            segment.p2.x, segment.p2.y);
      } else if (segment is QuadraticSegment) {
        path.quadraticBezierTo(
            segment.c.x, segment.c.y, segment.p2.x, segment.p2.y);
      } else if (segment is ArcSegment) {
        path.arcToPoint(Offset(segment.p2.x, segment.p2.y),
            rotation: segment.rotation.toDegree,
            largeArc: segment.largeArc,
            clockwise: !segment.clockwise,
            radius: Radius.elliptical(segment.radii.x, segment.radii.y));
      } else if (segment is CircularArcSegment) {
        path.arcToPoint(Offset(segment.p2.x, segment.p2.y),
            largeArc: segment.largeArc,
            clockwise: !segment.clockwise,
            radius: Radius.circular(segment.radius));
      } else {
        throw UnimplementedError('${segment.runtimeType}');
      }
    }
    return path;
  }
}

extension PathExt on Path {
  void moveToOffset(Offset point) => moveTo(point.dx, point.dy);
}

extension LineSegmentPathExt on LineSegment {
  Path get path => Path()
    ..moveTo(p1.x, p1.y)
    ..lineTo(p2.x, p2.y);
}

extension CircularArcSegmentPathExt on CircularArcSegment {
  Path get path => Path()
    ..moveTo(p1.x, p1.y)
    ..arcToPoint(Offset(p2.x, p2.y),
        radius: Radius.circular(radius),
        largeArc: largeArc,
        clockwise: !clockwise);
}

extension ArcSegmentPathExt on ArcSegment {
  Path get path => Path()
    ..moveTo(p1.x, p1.y)
    ..arcToPoint(Offset(p2.x, p2.y),
        radius: Radius.elliptical(radii.x, radii.y),
        rotation: rotation.toDegree,
        largeArc: largeArc,
        clockwise: !clockwise);
}

extension QuadraticSegmentPathExt on QuadraticSegment {
  Path get path => Path()
    ..moveTo(p1.x, p1.y)
    ..quadraticBezierTo(c.x, c.y, p2.x, p2.y);
}

extension CubicSegmentPathExt on CubicSegment {
  Path get path => Path()
    ..moveTo(p1.x, p1.y)
    ..cubicTo(c1.x, c1.y, c2.x, c2.y, p2.x, p2.y);
}

extension SegmentPathExt on Segment {
  Path get path {
    if (this is LineSegment) {
      return (this as LineSegment).path;
    } else if (this is CircularArcSegment) {
      return (this as CircularArcSegment).path;
    } else if (this is ArcSegment) {
      return (this as ArcSegment).path;
    } else if (this is QuadraticSegment) {
      return (this as QuadraticSegment).path;
    } else if (this is CubicSegment) {
      return (this as CubicSegment).path;
    }
    throw UnimplementedError('$runtimeType');
  }
}
