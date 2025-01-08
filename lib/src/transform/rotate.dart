import 'dart:ui';

import 'package:game_engine/game_engine.dart';

class Rotate implements Component, NeedsDetach {
  SizedPositionedComponent? _child;
  Offset _offset = Offset.zero;
  double _angle = 0;

  Rotate(
      {SizedPositionedComponent? child,
      double angle = 0,
      Offset offset = Offset.zero})
      : _offset = offset,
        _angle = angle,
        _child = child;

  @override
  void render(Canvas canvas) {
    if (_child == null) return;

    Offset translation = _offset;

    canvas.save();
    canvas.translate(translation.dx, translation.dy);
    canvas.rotate(_angle);
    // canvas.translate(-translation.dx, -translation.dy);
    try {
      _child!.render(canvas);
    } finally {
      canvas.restore();
    }
  }

  void set(
      {double? angle, Offset? offset, Argument<SizedPositionedComponent>? child}) {
    bool dirty = false;
    if (child != null && _child != child.value) {
      _child = child.value;
      dirty = true;
    }
    if (offset != null && offset != _offset) {
      _offset = offset;
      dirty = true;
    }
    if (angle != null && angle != _angle) {
      _angle = angle;
      dirty = true;
    }
    if (dirty) {
      _ctx?.requestRender(this);
    }
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
    if (_child != null) {
      _ctx?.registerComponent(_child!);
    }
  }

  @override
  void onDetach(ComponentContext ctx) {
    if (_child != null) {
      ctx.unregisterComponent(_child!);
    }
  }
}
