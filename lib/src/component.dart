import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

abstract class Component {
  void paint(Canvas canvas);

  void dispose();

  bool tick(Duration timestamp);

  void handleEvent(PointerEvent event);
}

class BlockTicks implements Component {
  final Component child;

  BlockTicks(this.child);

  @override
  void paint(Canvas canvas) {
    child.paint(canvas);
  }

  @override
  void dispose() {}

  @override
  bool tick(Duration timestamp) => false;

  @override
  void handleEvent(PointerEvent event) => child.handleEvent(event);
}

class HexComponent implements Component, CanHitTest {
  late Offset _position;
  late Size _size;
  final BorderPainter? border;

  late Path _path;

  HexComponent(
      {required Offset position,
      required Size size,
      required Color color,
      this.border}) {
    this.color = color;
    _position = position;
    _size = size;
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

  Color get color => _paint.color;
  set color(Color value) => _paint.color = value;

  final _paint = Paint()..style = PaintingStyle.fill;

  @override
  bool hitTest(Offset point) => _path.contains(point);

  @override
  void paint(Canvas canvas) {
    canvas.drawPath(_path, _paint);

    if (border != null) {
      canvas.drawPath(_path, border!.paint);
    }
  }

  void _update() {
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
  }

  @override
  void dispose() {}

  @override
  bool tick(Duration timestamp) => false;

  @override
  void handleEvent(PointerEvent event) {}
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

enum BorderAlign {inside, center, outside}
