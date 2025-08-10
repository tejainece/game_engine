import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';
import 'package:optional/optional.dart';
import 'package:ramanujan/ramanujan.dart';

class EllipseComponent extends Component implements ShapeComponent {
  Ellipse _ellipse;
  Offset _offset;
  Stroke? _stroke;
  Fill? _fill;
  Paint? _fillPaint;
  Paint? _strokePaint;
  late Path _arc1;
  late Path _arc2;

  EllipseComponent(
    this._ellipse, {
    Stroke? stroke = const Stroke(),
    Fill? fill,
    Offset offset = Offset.zero,
  }) : _offset = offset,
       _stroke = stroke,
       _fill = fill {
    _strokePaint = _stroke?.paint;
    _fillPaint = _fill?.paint;
    _arc1 = _makeArc(0, 0.5);
    _arc2 = _makeArc(0.5, 1);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(_offset.dx, _offset.dy);
    try {
      _transform = Affine2d.fromMatrix4Cols(canvas.getTransform());
      _drawArc(canvas, _arc1);
      _drawArc(canvas, _arc2);
    } finally {
      canvas.restore();
    }
  }

  Path _makeArc(double start, double end) {
    final arcLength = _ellipse.arcLengthBetweenT(start, end, clockwise: false);
    final perimeter = _ellipse.perimeter;
    return Path()
      ..moveToOffset(_ellipse.lerp(start).o)
      ..arcToPoint(
        _ellipse.lerp(end).o,
        rotation: _ellipse.rotation.toDegree,
        radius: _ellipse.radii.r,
        clockwise: false,
        largeArc: arcLength > perimeter / 2,
      );
  }

  void _drawArc(Canvas canvas, Path path) {
    if (_fillPaint != null) {
      canvas.drawPath(path, _fillPaint!);
    }
    if (_strokePaint != null) {
      canvas.drawPath(path, _strokePaint!);
    }
  }

  @override
  void set({
    Ellipse? circle,
    Optional<Stroke>? stroke,
    Optional<Fill>? fill,
    Offset? offset,
  }) {
    bool needsUpdate = false;
    if (circle != null && circle != _ellipse) {
      _ellipse = circle;
      _arc1 = _makeArc(0, 0.5);
      _arc2 = _makeArc(0.5, 1);
      needsUpdate = true;
    }
    if (offset != null && offset != _offset) {
      _offset = offset;
      needsUpdate = true;
    }
    if (stroke != null && stroke.value != _stroke) {
      _stroke = stroke.value;
      _strokePaint = _stroke?.paint;
      needsUpdate = true;
    }
    if (fill != null && fill.value != _fill) {
      _fill = fill.value;
      _fillPaint = _fill?.paint;
      needsUpdate = true;
    }
    if (needsUpdate) {
      _ctx?.requestRender(this);
    }
  }

  R get boundingBox => _ellipse.boundingBox;

  @override
  Offset get offset => boundingBox.topLeft.o + _offset;

  @override
  Size get size => Size(boundingBox.width, boundingBox.height);

  ComponentContext? _ctx;
  Affine2d _transform = Affine2d();

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
  }

  @override
  bool hitTest(Offset point) {
    final p = P(point.dx, point.dy).transform(_transform);
    return _ellipse.containsPoint(P(p.x, p.y));
  }
}
