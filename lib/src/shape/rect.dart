import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class RectComponent
    with BlockPointerMixin
    implements Component, FlexChild, DimensionedComponent {
  Offset _offset;
  Size _size;
  BorderPainter? _border;

  RectComponent(
      {Color color = Colors.transparent,
      Size size = Size.zero,
      Offset offset = Offset.zero,
      BorderPainter? border})
      : _size = size,
        _offset = offset,
        _border = border,
        _paint = Paint()..color = color;

  late final Paint _paint;

  double get opacity => _paint.color.opacity;

  set opacity(double value) {
    if (opacity == value) return;
    _paint.color = _paint.color.withOpacity(value);
    _dirty = true;
  }

  Color get color => _paint.color;

  set color(Color value) {
    if (color == value) return;
    _paint.color = value;
    _dirty = true;
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
      Color? color,
      double? opacity,
      BorderPainter? border}) {
    if (offset != null && offset != _offset) {
      _offset = offset;
      _dirty = true;
    }
    if (size != null && size != _size) {
      _size = size;
      _dirty = true;
    }
    if (color != null) {
      this.color = color;
      _dirty = true;
    }
    if (opacity != null) {
      this.opacity = opacity;
      _dirty = true;
    }
    if (border != null) {
      _border = border;
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

  @override
  void render(Canvas canvas) {
    canvas.drawRect(offset & size, _paint);

    if(_border != null) {
      canvas.drawRect(offset & size, _border!.paint);
    }
  }
}
