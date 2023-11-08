import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class TickCtx {
  Duration _timestamp;
  Duration _dt;

  TickCtx({required Duration timestamp, required Duration dt})
      : _timestamp = timestamp,
        _dt = dt;

  void nextTick(Duration timestamp) {
    _dt = timestamp - _timestamp;
    _timestamp = timestamp;

    _needsRender = false;
    _needsDetachOld = _needsDetach;
    _needsDetach = {};
  }

  Duration get timestamp => _timestamp;
  Duration get dt => _dt;

  bool _needsRender = false;

  var _needsDetachOld = <NeedsDetach>{};

  var _needsDetach = <NeedsDetach>{};

  bool get needsRender => _needsRender;

  Iterable<NeedsDetach> get detached => _needsDetachOld;

  void shouldRender() {
    _needsRender = true;
  }

  void registerDetach(NeedsDetach component) {
    if (!_needsDetachOld.remove(component)) {
      component.attach();
    }
    _needsDetach.add(component);
  }
}

abstract class NeedsDetach {
  void attach();

  void detach();
}

abstract class Component {
  void render(Canvas canvas);

  void tick(TickCtx ctx);

  void handlePointerEvent(PointerEvent event);
}

class BlockTicks implements Component {
  final Component child;

  BlockTicks(this.child);

  @override
  void render(Canvas canvas) {
    child.render(canvas);
  }

  @override
  void tick(TickCtx ctx) {}

  @override
  void handlePointerEvent(PointerEvent event) =>
      child.handlePointerEvent(event);
}

mixin BlockTicksMixin on Object implements Component {
  @override
  void tick(TickCtx ctx) {}
}

class HexComponent implements Component, CanHitTest {
  late Offset _position;
  late Size _size;
  BorderPainter? _borderPainter;

  late Path _path;
  Path? _borderPath;

  HexComponent(
      {required Offset position,
      required Size size,
      required Color color,
      BorderPainter? border}) {
    this.color = color;
    _position = position;
    _size = size;
    _borderPainter = border;
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
    if (border == _borderPainter) return;
    _borderPainter = border;
    _update();
  }

  Color get color => _paint.color;
  set color(Color value) => _paint.color = value;

  final _paint = Paint()..style = PaintingStyle.fill;

  @override
  bool hitTest(Offset point) => _path.contains(point);

  @override
  void tick(TickCtx ctx) {
    if (_dirty) ctx.shouldRender();
  }

  bool _dirty = true;

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, _paint);

    if (_borderPath != null && _borderPainter != null) {
      canvas.drawPath(_borderPath!, _borderPainter!.paint);
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

    if (_borderPainter != null) {
      final borderPos = position +
          Offset(_borderPainter!.strokeWidth, _borderPainter!.strokeWidth);
      final w2 = (size.width - (_borderPainter!.strokeWidth *)) / 2;
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
