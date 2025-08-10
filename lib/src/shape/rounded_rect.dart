import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';
import 'package:optional/optional.dart';
import 'package:ramanujan/ramanujan.dart';

class RoundedRectangleComponent extends Component
    implements ShapeComponent, SizedPositionedComponent {
  Offset _offset = Offset.zero;
  R _rect;
  double _radius;
  Stroke? _stroke;
  Fill? _fill;
  Paint? _fillPaint;
  Paint? _strokePaint;

  late Path _path;

  RoundedRectangleComponent(
    this._rect, {
    Offset offset = Offset.zero,
    Stroke? stroke,
    Fill? fill,
    double radius = 0,
  }) : _offset = offset,
       _stroke = stroke,
       _fill = fill,
       _radius = radius {
    _strokePaint = _stroke?.paint;
    _fillPaint = _fill?.paint;
    _path = _makePath();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(_offset.dx, _offset.dy);
    try {
      _transform = Affine2d.fromMatrix4Cols(canvas.getTransform());
      if (_fillPaint != null) {
        canvas.drawPath(_path, _fillPaint!);
      }
      if (_strokePaint != null) {
        canvas.drawPath(_path, _strokePaint!);
      }
    } finally {
      canvas.restore();
    }
  }

  Path _makePath() {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(_rect.left, _rect.top, _rect.width, _rect.height),
          Radius.circular(_radius),
        ),
      );
    return path;
  }

  @override
  void set({
    R? rectangle,
    Offset? offset,
    Size? size,
    Optional<Stroke>? stroke,
    Optional<Fill>? fill,
    double? radius,
  }) {
    bool needsUpdate = false;
    if (rectangle != null && rectangle != _rect) {
      _rect = rectangle;
      needsUpdate = true;
    } else if (size != null && _rect != R(0, 0, size.width, size.height)) {
      _rect = R(0, 0, size.width, size.height);
      needsUpdate = true;
    }
    if (radius != null && radius != _radius) {
      _radius = radius;
      needsUpdate = true;
    }
    if (needsUpdate) {
      _path = _makePath();
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

  @override
  bool hitTest(Offset point) {
    final p = P(point.dx, point.dy).transform(_transform);
    return _rect.containsPoint(P(p.x, p.y));
  }

  ComponentContext? _ctx;
  Affine2d _transform = Affine2d();

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
  }

  @override
  Offset get offset => _offset + _rect.topLeft.o;

  @override
  Size get size => Size(_rect.width, _rect.height);
}
