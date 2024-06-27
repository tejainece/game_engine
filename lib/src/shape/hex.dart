import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class HexComponent implements Component, CanHitTest, DimensionedComponent {
  late Offset _offset;
  late Size _size;
  BorderPainter? _border;
  Color? _color;

  late Path _path;
  Path? _borderPath;

  HexComponent(
      {Offset offset = const Offset(0, 0),
      Size size = const Size(0, 0),
      Color? color,
      BorderPainter? border}) {
    _color = color;
    _offset = offset;
    _size = size;
    _border = border;
    _update();
  }

  @override
  Offset get offset => _offset;
  set offset(Offset value) {
    if (_offset == value) return;
    _offset = value;
    _update();
  }

  @override
  Size get size => _size;
  set size(Size value) {
    if (_size == value) return;
    _size = value;
    _update();
  }

  set border(BorderPainter? border) {
    if (border == _border) return;
    _border = border;
    _update();
  }

  Color? get color => _color;
  set color(Color? value) {
    if (_color == value) return;
    _color = value;
    _update();
  }

  @override
  void set({Offset? offset, Size? size, Color? color}) {
    bool needsUpdate = false;
    if (offset != null && offset != _offset) {
      _offset = offset;
      needsUpdate = true;
    }
    if (size != null && size != _size) {
      _size = size;
      needsUpdate = true;
    }
    if (color != null && color != _color) {
      _color = color;
      needsUpdate = true;
    }
    if (needsUpdate) _update();
  }

  Paint? _paint;

  @override
  bool hitTest(Offset point) => _path.contains(point);

  @override
  void tick(TickCtx ctx) {
    if (_dirty) {
      _dirty = false;
      ctx.shouldRender();
    }
  }

  bool _dirty = true;

  @override
  void render(Canvas canvas) {
    if (_paint != null) {
      canvas.drawPath(_path, _paint!);
    }

    if (_borderPath != null && _border != null) {
      canvas.drawPath(_borderPath!, _border!.paint);
    }
  }

  void _update() {
    _dirty = true;

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

    if (_color != null) {
      _paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _color!;
    } else {
      _paint = null;
    }

    if (_border != null) {
      final borderPos =
          offset + Offset(_border!.strokeWidth / 2, _border!.strokeWidth / 2);
      final w2 = (size.width - _border!.strokeWidth) / 2;
      final h4 = (size.height - _border!.strokeWidth) / 4;
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

  @override
  void handlePointerEvent(PointerEvent event) {}
}

class BorderPainter {
  BorderAlign align = BorderAlign.center;

  BorderPainter({required Color color, required double strokeWidth}) {
    this.color = color;
    this.strokeWidth = strokeWidth;
  }

  final paint = Paint()..style = PaintingStyle.stroke;

  Color get color => paint.color;
  set color(Color value) => paint.color = value;

  double get strokeWidth => paint.strokeWidth;
  set strokeWidth(double value) => paint.strokeWidth = value;
}

enum BorderAlign { inside, center, outside }
