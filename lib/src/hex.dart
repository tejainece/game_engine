import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class HexComponent implements Component, CanHitTest {
  late Offset _position;
  late Size _size;
  BorderPainter? _border;
  Color? _color;

  late Path _path;
  Path? _borderPath;

  HexComponent(
      {Offset position = const Offset(0, 0),
      Size size = const Size(0, 0),
      Color? color,
      BorderPainter? border}) {
    _color = color;
    _position = position;
    _size = size;
    _border = border;
    _update();
  }

  Offset get position => _position;
  set position(Offset value) {
    if (_position == value) return;
    _position = value;
    _update();
  }

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

  void set({Offset? position, Size? size, BorderPainter? border, Color? color}) {
    bool needsUpdate = false;
    if(position != null && position != _position) {
      _position = position;
      needsUpdate = true;
    }
    if(size != null && size != _size) {
      _size = size;
      needsUpdate = true;
    }
    if(border != null && border != _border) {
      _border = border;
      needsUpdate = true;
    }
    if(color != null && color != _color) {
      _color = color;
      needsUpdate = true;
    }
    if(needsUpdate) _update();
  }

  Paint? _paint;

  @override
  bool hitTest(Offset point) => _path.contains(point);

  @override
  void tick(TickCtx ctx) {
    if (_dirty) ctx.shouldRender();
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
      ..moveTo(position.dx + w2, position.dy + 0) // top mid
      ..lineTo(position.dx + 0, position.dy + h4) // left top
      ..lineTo(position.dx + 0, position.dy + h4 * 3) // left bot
      ..lineTo(position.dx + w2, position.dy + size.height) // bot mid
      ..lineTo(position.dx + size.width, position.dy + h4 * 3) // right bot
      ..lineTo(position.dx + size.width, position.dy + h4) // right top
      ..lineTo(position.dx + w2, position.dy + 0) // top mid
      ..close();

    if (_color != null) {
      _paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _color!;
    } else {
      _paint = null;
    }

    if (_border != null) {
      final borderPos = position +
          Offset(_border!.strokeWidth, _border!.strokeWidth);
      final w2 = (size.width - (_border!.strokeWidth * 2)) / 2;
      final h4 = (size.height - (_border!.strokeWidth * 2)) / 4;
      _borderPath = Path()
        ..moveTo(borderPos.dx + w2, borderPos.dy + 0) // top mid
        ..lineTo(borderPos.dx + 0, borderPos.dy + h4) // left top
        ..lineTo(borderPos.dx + 0, borderPos.dy + h4 * 3) // left bot
        ..lineTo(borderPos.dx + w2, borderPos.dy + size.height) // bot mid
        ..lineTo(borderPos.dx + size.width, borderPos.dy + h4 * 3) // right bot
        ..lineTo(borderPos.dx + size.width, borderPos.dy + h4) // right top
        ..lineTo(borderPos.dx + w2, borderPos.dy + 0) // top mid
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
