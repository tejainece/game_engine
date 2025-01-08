import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class MouseInteraction implements Component, PointerEventHandler, CanHitTest {
  late CanHitTest child;

  ValueChanged<ComponentMouseDownEvent>? onMouseDown;

  ValueChanged<ClickEvent>? onTap;

  ValueChanged<ClickEvent>? onLongPress;

  ValueChanged? onDoubleTap;

  MouseInteraction(
      {required this.child, this.onMouseDown, this.onTap, this.onDoubleTap, this.onLongPress});

  @override
  void render(Canvas canvas) {
    child.render(canvas);
  }

  @override
  bool hitTest(Offset point) => child.hitTest(point);

  late final _tapDetector = TapDetector(
      onTap: onTap, onDoubleTap: onDoubleTap, onLongPress: onLongPress);

  @override
  void handlePointerEvent(PointerEvent event) {
    if (!hitTest(event.localPosition)) {
      return;
    }
    if(event is PointerDownEvent) {
      onMouseDown?.call(ComponentMouseDownEvent(event));
    }
    _tapDetector.handlePointerEvent(event);
  }

  @override
  void onAttach(ComponentContext ctx) {
    ctx.registerComponent(child);
  }
}

abstract class OnPointerEvents {
  Stream<PointerEvent> get onPointerEvents;
}

abstract class ComponentMouseEvent {}

class ComponentMouseDownEvent implements ComponentMouseEvent {
  final PointerDownEvent event;

  ComponentMouseDownEvent(this.event);
}
