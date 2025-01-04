import 'package:flutter/material.dart';

class TickCtx {
  Duration _timestamp;
  Duration _dt;

  TickCtx(
      {required Duration timestamp,
      required Duration dt,
      required Size canvasSize})
      : _timestamp = timestamp,
        _dt = dt;

  void nextTick(Duration timestamp, Size size) {
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
      component.onAttach();
    }
    _needsDetach.add(component);
  }
}

abstract class NeedsDetach {
  void onAttach();

  void onDetach();
}

abstract class CanvasPainter {
  void render(Canvas canvas);
}

abstract class Component implements CanvasPainter {
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

class NullableValue<T> {
  T? value;

  NullableValue(this.value);
}

abstract class CanHitTest implements Component {
  bool hitTest(Offset point);
}
