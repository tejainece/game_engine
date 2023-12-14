import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class MouseInteraction implements Component, CanHitTest {
  late CanHitTest child;

  ValueChanged<ClickEvent>? onTap;

  ValueChanged<ClickEvent>? onLongPress;

  ValueChanged<ClickEvent>? onShortPress;

  MouseInteraction({required this.child, this.onTap});

  @override
  void render(Canvas canvas) {
    child.render(canvas);
  }

  @override
  bool hitTest(Offset point) => child.hitTest(point);

  @override
  void tick(TickCtx ctx) => child.tick(ctx);

  late final _tapDetector = TapDetector(this);

  late final _longPressDetector = TapDetector.longPress(this);

  late final _shortPressDetector = TapDetector.shortPress(this);

  @override
  void handlePointerEvent(PointerEvent event) {
    if (onTap != null) {
      final click = _tapDetector.handlePointerEvent(event);
      if (click != null) {
        onTap!.call(click);
      }
    }
    if (onLongPress != null) {
      final click = _longPressDetector.handlePointerEvent(event);
      if (click != null) {
        onLongPress!.call(click);
      }
    }
    if (onShortPress != null) {
      final click = _shortPressDetector.handlePointerEvent(event);
      if (click != null) {
        onShortPress!.call(click);
      }
    }
    child.handlePointerEvent(event);
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

class ClickEvent {
  final PointerDownEvent down;
  final DateTime downTime;
  final PointerUpEvent up;
  final DateTime upTime;

  ClickEvent(
      {required this.down,
      required this.downTime,
      required this.up,
      required this.upTime});

  int get buttons => down.buttons;

  PointerDeviceKind get kind => down.kind;
}

class TapTracker {
  final PointerDownEvent down;
  final DateTime downTime;

  TapTracker({required this.down, required this.downTime});

  int get pointer => down.pointer;
}

class TapDetector {
  TapTracker? _tracker;

  final CanHitTest component;

  Duration? lessThan;
  Duration? greaterThan;

  TapDetector(this.component, {this.lessThan, this.greaterThan});

  TapDetector.longPress(this.component, {this.greaterThan = longPressDuration});

  TapDetector.shortPress(this.component, {this.lessThan = shortPressDuration});

  ClickEvent? handlePointerEvent(PointerEvent event) {
    final point = event.localPosition;

    if (!component.hitTest(point)) {
      return null;
    }

    if (event is PointerDownEvent) {
      _tracker = TapTracker(down: event, downTime: DateTime.now());
      return null;
    } else if (event is PointerPanZoomStartEvent ||
        event is PointerPanZoomUpdateEvent ||
        event is PointerPanZoomEndEvent ||
        event is PointerCancelEvent ||
        event is PointerExitEvent) {
      _tracker = null;
      return null;
    } else if (event is! PointerUpEvent) {
      return null;
    }

    if (_tracker == null || event.pointer != _tracker!.pointer) {
      _tracker = null;
      return null;
    }

    final distance = (_tracker!.down.position - event.position).distanceSquared;
    if (distance > 10) {
      _tracker = null;
      return null;
    }

    final upTime = DateTime.now();
    final dur = upTime.difference(_tracker!.downTime);
    if ((lessThan == null || dur < lessThan!) &&
        (greaterThan == null || dur > greaterThan!)) {
      final tracker = _tracker!;
      _tracker = null;
      return ClickEvent(
          down: tracker.down,
          downTime: tracker.downTime,
          up: event,
          upTime: upTime);
    }
    _tracker = null;
    return null;
  }

  static const longPressDuration = Duration(seconds: 3);
  static const shortPressDuration = Duration(seconds: 2);
}

abstract class CanHitTest implements Component {
  bool hitTest(Offset point);
}
