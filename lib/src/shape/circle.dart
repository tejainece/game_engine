import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

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
      Argument<Stroke?>? stroke,
      Argument<Fill?>? fill}) {
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
