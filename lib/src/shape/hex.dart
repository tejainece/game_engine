import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class HexComponent implements Component, SizedPositionedComponent, ShapeComponent {
  late Offset _offset;
  late Size _size;
  Stroke? _stroke;
  Fill? _fill;
  Paint? _strokePaint;
  Paint? _fillPaint;

  late Path _path;
  // TODO do we need border paint
  Path? _borderPath;

  HexComponent(
      {Offset offset = const Offset(0, 0),
      Size size = const Size(0, 0),
      Stroke? stroke,
      Fill? fill})
      : _offset = offset,
        _size = size,
        _stroke = stroke,
        _fill = fill {
    _strokePaint = _stroke?.paint;
    _fillPaint = _fill?.paint;
    _update();
  }

  @override
  void set(
      {Offset? offset,
      Size? size,
      Argument<Stroke?>? stroke,
      Argument<Fill?>? fill}) {
    bool needsUpdate = false;
    if (offset != null && offset != _offset) {
      _offset = offset;
      needsUpdate = true;
    }
    if (size != null && size != _size) {
      _size = size;
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
      _update();
      _ctx?.requestRender(this);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_fillPaint != null) {
      canvas.drawPath(_path, _fillPaint!);
    }
    if (_borderPath != null && _strokePaint != null) {
      canvas.drawPath(_borderPath!, _strokePaint!);
    }
  }

  void _update() {
    final h4 = size.height / 4;
    final w2 = size.width / 2;
    _path = Path()
      ..moveTo(offset.dx + w2, offset.dy + 0) // top mid
      ..lineTo(offset.dx + 0, offset.dy + h4) // left top
      ..lineTo(offset.dx + 0, offset.dy + h4 * 3) // left bot
      ..lineTo(offset.dx + w2, offset.dy + size.height) // bot mid
      ..lineTo(offset.dx + size.width, offset.dy + h4 * 3) // right bot
      ..lineTo(offset.dx + size.width, offset.dy + h4) // right top
      ..lineTo(offset.dx + w2, offset.dy + 0) // top mid
      ..close();

    if (_stroke != null) {
      final borderPos =
          offset + Offset(_stroke!.strokeWidth / 2, _stroke!.strokeWidth / 2);
      final w2 = (size.width - _stroke!.strokeWidth) / 2;
      final h4 = (size.height - _stroke!.strokeWidth) / 4;
      _borderPath = Path()
        ..moveTo(borderPos.dx + w2, borderPos.dy + 0) // n
        ..lineTo(borderPos.dx + 0, borderPos.dy + h4) // nw
        ..lineTo(borderPos.dx + 0, borderPos.dy + h4 * 3) // sw
        ..lineTo(borderPos.dx + w2, borderPos.dy + h4 * 4) // s
        ..lineTo(borderPos.dx + w2 * 2, borderPos.dy + h4 * 3) // se
        ..lineTo(borderPos.dx + w2 * 2, borderPos.dy + h4) // ne
        ..lineTo(borderPos.dx + w2, borderPos.dy + 0) // n
        ..close();
    } else {
      _borderPath = null;
    }
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
  }

  @override
  Offset get offset => _offset;

  @override
  Size get size => _size;

  // TODO take into account transform
  @override
  bool hitTest(Offset point) => _path.contains(point);
}
