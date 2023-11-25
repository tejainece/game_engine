import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

abstract class FlexComponent implements Component {
  void set({Offset? offset});

  Size get size;
}

class RowComponent implements Component {
  var _children = <FlexComponent>[];
  Offset _offset = const Offset(0, 0);
  Size _size = const Size(0, 0);
  var _crossAxisAlign = CrossAxisAlignment.start;
  var _align = MainAxisAlignment.start;

  RowComponent(
      {required List<Component> children,
      required Offset offset,
      required Size size,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
      MainAxisAlignment align = MainAxisAlignment.start}) {
    _offset = offset;
    _size = size;
    _crossAxisAlign = crossAxisAlignment;
    _align = align;
  }

  @override
  void handlePointerEvent(PointerEvent event) {
    for (final child in _children) {
      child.handlePointerEvent(event);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final child in _children) {
      child.render(canvas);
    }
  }

  @override
  void tick(TickCtx ctx) {
    for (final child in _children) {
      child.tick(ctx);
    }

    _layout();
  }

  void _layout() {
    if(_align == MainAxisAlignment.start) {
      double offset = 0;
      for(final child in _children) {
        child.set(offset: Offset(dx, dy));
        offset += child.;
      }
    }
  }
}
