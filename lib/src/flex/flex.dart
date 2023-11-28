import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:game_engine/game_engine.dart';

class FlexComponent implements Component, DimensionedComponent, FlexChild {
  double _flex = 1;
  DimensionedComponent? _child;

  FlexComponent({double flex = 1, DimensionedComponent? child})
      : _flex = flex,
        _child = child;

  bool _dirty = true;

  @override
  Size get size => _child?.size ?? Size.zero;

  set size(Size size) => _child?.set(size: size);

  @override
  Offset get offset => _child?.offset ?? Offset.zero;

  set offset(Offset offset) => _child?.set(offset: offset);

  @override
  void set(
      {double? flex, Offset? offset, Size? size, DimensionedComponent? child}) {
    if (flex != null && flex != _flex) {
      _flex = flex;
      _dirty = true;
    }
    if (child != null && child != _child) {
      _child = child;
      _dirty = true;
    }
    _child?.set(offset: offset, size: size);
  }

  @override
  void tick(TickCtx ctx) {
    if (_dirty) {
      _dirty = false;
      ctx.shouldRender();
    }

    _child?.tick(ctx);
  }

  @override
  void render(Canvas canvas) {
    _child?.render(canvas);
  }

  @override
  void handlePointerEvent(PointerEvent event) {
    _child?.handlePointerEvent(event);
  }
}
