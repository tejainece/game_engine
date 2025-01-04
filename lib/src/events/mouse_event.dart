import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class MouseInteraction implements Component, CanHitTest {
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

  @override
  void tick(TickCtx ctx) => child.tick(ctx);

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
}

class BlockPointerEvents implements Component {
  final Component child;

  BlockPointerEvents(this.child);

  @override
  void render(Canvas canvas) => child.render(canvas);

  @override
  void tick(TickCtx ctx) => child.tick(ctx);

  @override
  void handlePointerEvent(PointerEvent event) {}
}

mixin BlockPointerMixin on Object implements Component {
  @override
  void handlePointerEvent(PointerEvent event) {}
}

abstract class OnPointerEvents {
  Stream<PointerEvent> get onPointerEvents;
}

mixin OnPointerEventsMixin implements Component, OnPointerEvents {
  final _controller = StreamController<PointerEvent>.broadcast();

  @override
  Stream<PointerEvent> get onPointerEvents => _controller.stream;

  @override
  void handlePointerEvent(PointerEvent event) {
    _controller.add(event);
  }

  Future<void> disposePointerEventController() async {
    await _controller.close();
  }
}

abstract class ComponentMouseEvent {}

class ComponentMouseDownEvent implements ComponentMouseEvent {
  final PointerDownEvent event;

  ComponentMouseDownEvent(this.event);
}
