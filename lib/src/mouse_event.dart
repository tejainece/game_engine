import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class MouseInteraction implements Component, CanHitTest {
  late CanHitTest child;

  VoidCallback? onTap;

  VoidCallback? onLongPress;

  VoidCallback? onShortPress;

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
      if (_tapDetector.handlePointerEvent(event)) {
        onTap!.call();
      }
    }
    if (onLongPress != null) {
      if (_longPressDetector.handlePointerEvent(event)) {
        onLongPress!.call();
      }
    }
    if(onShortPress != null) {
      if(_shortPressDetector.handlePointerEvent(event)) {
        onShortPress!.call();
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

class TapDetector {
  ({PointerEvent event, DateTime start})? _down;

  final CanHitTest component;

  Duration? tapDurationLessThan;
  Duration? tapDurationGreaterThan;

  TapDetector(this.component,
      {this.tapDurationLessThan, this.tapDurationGreaterThan});

  TapDetector.longPress(this.component,
      {this.tapDurationGreaterThan = longPressDuration});

  TapDetector.shortPress(this.component,
      {this.tapDurationLessThan = shortPressDuration});

  bool handlePointerEvent(PointerEvent event) {
    final point = event.localPosition;

    if (event is PointerDownEvent) {
      if (component.hitTest(point)) {
        _down = (event: event, start: DateTime.now());
      } else {
        _down = null;
      }
    } else if (event is PointerUpEvent) {
      if (component.hitTest(point) &&
          _down != null &&
          event.pointer == _down!.event.pointer &&
          (tapDurationLessThan == null ||
              DateTime.now().difference(_down!.start) < tapDurationLessThan!) &&
          (tapDurationGreaterThan == null ||
              DateTime.now().difference(_down!.start) >
                  tapDurationGreaterThan!)) {
        _down = null;
        return true;
      }
      _down = null;
    } else if (event is PointerPanZoomStartEvent ||
        event is PointerPanZoomUpdateEvent ||
        event is PointerPanZoomEndEvent ||
        event is PointerCancelEvent ||
        event is PointerExitEvent) {
      _down = null;
    }
    return false;
  }

  static const longPressDuration = Duration(seconds: 3);
  static const shortPressDuration = Duration(seconds: 2);
}

abstract class CanHitTest implements Component {
  bool hitTest(Offset point);
}
