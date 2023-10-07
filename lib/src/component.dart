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
    if(!_needsDetachOld.remove(component)) {
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

class HexComponent with BlockTicksMixin implements Component, CanHitTest {
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
  void render(Canvas canvas) {
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
