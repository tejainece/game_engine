import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:game_engine/game_engine.dart';

class Rotate implements Component {
  Component? child;
  Offset _offset = Offset.zero;
  double _angleDegreeACW = 0;
  Offset _center = Offset.zero;

  Rotate(
      {required this.child,
      double angleDegreeACW = 0,
      Offset offset = Offset.zero,
      Offset center = Offset.zero});

  @override
  void handlePointerEvent(PointerEvent event) {
    child?.handlePointerEvent(event);
  }

  Offset _anchor = Offset.zero;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(-_anchor.dx, -_anchor.dy);
    canvas.rotate(-_angleDegreeACW);
    canvas.translate(_anchor.dx, _anchor.dy);

    child?.render(canvas);
    canvas.restore();
  }

  bool _dirty = true;

  void set({double? angleDegree, Offset? offset, Offset? center, NullableValue<Component>? child}) {
    if(child != null) {
      this.child = child.value;
    }
    bool anchorChanged = false;
    if (offset != null && offset != _offset) {
      _offset = offset;
      _dirty = true;
      anchorChanged = true;
    }
    if (center != null && center != _center) {
      _center = center;
      _dirty = true;
      anchorChanged = true;
    }
    if (anchorChanged) {
      _anchor = _offset + _center;
    }
    if (angleDegree != null && angleDegree != _angleDegreeACW) {
      _angleDegreeACW = angleDegree;
      _dirty = true;
    }
  }

  @override
  void tick(TickCtx ctx) {
    if (_dirty) {
      _dirty = false;
      ctx.shouldRender();
    }

    child?.tick(ctx);
  }
}
