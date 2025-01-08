import 'dart:ui';
import 'package:game_engine/game_engine.dart';

class FlexComponent implements Component, SizedPositionedComponent, PositionedComponent, NeedsDetach {
  double _flex = 1;
  SizedPositionedComponent? _child;

  double get flex => _flex;

  FlexComponent({double flex = 1, SizedPositionedComponent? child})
      : _flex = flex,
        _child = child;

  @override
  void render(Canvas canvas) {
    _child?.render(canvas);
  }

  @override
  Size get size => _child?.size ?? Size.zero;

  @override
  Offset get offset => _child?.offset ?? Offset.zero;

  @override
  void set(
      {double? flex, Offset? offset, Size? size, SizedPositionedComponent? child}) {
    if (flex != null && flex != _flex) {
      _flex = flex;
    }
    if (child != null && child != _child) {
      if (_child != null) {
        _ctx?.unregisterComponent(_child!);
      }
      _child = child;
      if (_ctx != null) {
        _ctx?.registerComponent(_child!);
      }
    }
    _child?.set(offset: offset, size: size);
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
    if (_child != null) {
      ctx.registerComponent(_child!);
    }
  }

  @override
  void onDetach(ComponentContext ctx) {
    if (_child != null) {
      ctx.unregisterComponent(_child!);
    }
  }
}
