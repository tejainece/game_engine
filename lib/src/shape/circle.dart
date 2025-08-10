import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';
import 'package:optional/optional.dart';
import 'package:ramanujan/ramanujan.dart';

class CircleComponent extends Component implements ShapeComponent {
  Circle _circle;
  Offset _offset;
  Stroke? _stroke;
  Fill? _fill;
  Paint? _fillPaint;
  Paint? _strokePaint;
  late Path _arc1;
  late Path _arc2;

  CircleComponent(
    this._circle, {
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
    final arcLength = _circle.arcLengthBetweenT(start, end, clockwise: false);
    final perimeter = _circle.perimeter;
    return Path()
      ..moveToOffset(_circle.lerp(start).o)
      ..arcToPoint(
        _circle.lerp(end).o,
        radius: Radius.circular(_circle.radius),
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
    Circle? circle,
    Optional<Stroke>? stroke,
    Optional<Fill>? fill,
    Offset? offset,
  }) {
    bool needsUpdate = false;
    if (circle != null && circle != _circle) {
      _circle = circle;
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

  R get boundingBox => _circle.boundingBox;

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
    return _circle.containsPoint(P(p.x, p.y));
  }
}

/*
class OvalComponent
    with BlockPointerMixin
    implements Component, FlexChild, DimensionedComponent, ShapeComponent {
  Offset _offset;
  Size _size;
  Stroke? _stroke;
  Fill? _fill;
  Paint? _strokePaint;
  Paint? _fillPaint;

  OvalComponent(
      {Size size = Size.zero,
      Offset offset = Offset.zero,
      Stroke? stroke,
      Fill? fill})
      : _offset = offset,
        _size = size,
        _stroke = stroke,
        _fill = fill {
    _strokePaint = stroke?.paint;
    _fillPaint = fill?.paint;
    // TODO update
  }

  @override
  void render(Canvas canvas) {
    if (_strokePaint != null) {
      canvas.drawOval(offset & size, _strokePaint!);
    }
    if (_fillPaint != null) {
      canvas.drawOval(offset & size, _fillPaint!);
    }
  }

  @override
  Size get size => _size;

  set size(Size value) {
    if (value == _size) return;
    _size = value;
    _dirty = true;
  }

  @override
  Offset get offset => _offset;

  set offset(Offset value) {
    if (value == _offset) return;
    _offset = value;
    _dirty = true;
  }

  bool _dirty = true;

  @override
  void set(
      {Offset? offset,
      Size? size,
      Optional<Stroke?>? stroke,
      Optional<Fill?>? fill}) {
    if (offset != null && offset != _offset) {
      _offset = offset;
      _dirty = true;
    }
    if (size != null && size != _size) {
      _size = size;
      _dirty = true;
    }
    if (stroke != null && stroke.value != _stroke) {
      _stroke = stroke.value;
      _strokePaint = _stroke?.paint;
      _dirty = true;
    }
    if (fill != null && fill.value != _fill) {
      _fill = fill.value;
      _fillPaint = _fill?.paint;
      _dirty = true;
    }
  }

  @override
  void tick(TickCtx ctx) {
    if (_dirty) {
      ctx.shouldRender();
      _dirty = false;
    }
  }
}
 */
