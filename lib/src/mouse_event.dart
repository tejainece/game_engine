import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class MouseInteraction implements Component, CanHitTest {
  late CanHitTest child;

  VoidCallback? onTap;

  MouseInteraction({required this.child, this.onTap});

  @override
  void paint(Canvas canvas) {
    child.paint(canvas);
  }

  @override
  bool hitTest(Offset point) => child.hitTest(point);

  @override
  void dispose() {
    child.dispose();
  }

  @override
  bool tick(Duration timestamp) => child.tick(timestamp);

  late final _tapRecognizer = TapRecognizer(this);

  @override
  void handleEvent(PointerEvent event) {
    if (onTap != null) {
      if (_tapRecognizer.handleEvent(event)) {
        onTap!.call();
      }
    }
    child.handleEvent(event);
  }
}

class TapRecognizer {
  PointerEvent? _down;

  final CanHitTest component;

  TapRecognizer(this.component);

  bool handleEvent(PointerEvent event) {
    final point = event.localPosition;

    if (event is PointerDownEvent) {
      if (component.hitTest(point)) {
        _down = event;
      }
    } else if (event is PointerUpEvent) {
      if (component.hitTest(point) &&
          _down != null &&
          event.pointer == _down!.pointer) {
        _down = null;
        return true;
      }
    } else if (event is PointerExitEvent) {
      _down = null;
    } else if (event is PointerMoveEvent) {
      if (!component.hitTest(point)) {
        _down = null;
      }
    }
    return false;
  }
}

abstract class CanHitTest implements Component {
  bool hitTest(Offset point);
}
