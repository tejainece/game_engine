import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TapDetector {
  _TapTracker? _first, _second;

  ValueChanged<ClickEvent>? onTap;
  ValueChanged<ClickEvent>? onLongPress;
  ValueChanged? onDoubleTap;

  TapDetector({this.onTap, this.onLongPress, this.onDoubleTap});

  void handlePointerEvent(PointerEvent event) {
    // final point = event.localPosition;

    // TODO detect hover

    if (event is PointerDownEvent) {
      _handleDown(event);
      return;
    } else if (event is PointerUpEvent) {
      _handleUp(event);
      return;
    } else if (event is PointerExitEvent || event is PointerEnterEvent) {
      print('exit or enter');
      // TODO
      return;
    } else {
      _first = null;
      _second = null;
      return;
    }
  }

  void _handleDown(PointerDownEvent event) {
    final now = DateTime.now();
    if (_first == null) {
      _first = _TapTracker(down: event, downTime: now);
      _second = null;
      return;
    }
    final first = _first!;
    if(first.pointer == event.pointer) {
      return;
    }
    if (!first.hasUp || first.pointer != event.pointer) {
      _first = _TapTracker(down: event, downTime: now);
      _second = null;
      return;
    }

    if (_second != null) {
      if(_second!.pointer == event.pointer) {
        return;
      }
      _first = _TapTracker(down: event, downTime: now);
      _second = null;
      return;
    }
    if (now.difference(first.upTime!) > const Duration(milliseconds: 500)) {
      _first = _TapTracker(down: event, downTime: now);
      _second = null;
      return;
    }
    if ((first.down.localPosition - event.localPosition).distance > 10) {
      _first = _TapTracker(down: event, downTime: now);
      _second = null;
      return;
    }
    _second = _TapTracker(down: event, downTime: now);
  }

  void _handleUp(PointerUpEvent event) {
    final second = _second;
    if (second != null) {
      final distance =
          (second.down.localPosition - event.localPosition).distance;
      if (second.pointer != event.pointer || second.hasUp || distance > 10) {
        _first = null;
        _second = null;
        return;
      }
      onDoubleTap?.call(null);
      _first = null;
      _second = null;
      return;
    }

    final first = _first;
    if (first == null || first.pointer != event.pointer || first.hasUp) {
      _first = null;
      return;
    }
    if ((first.down.localPosition - event.localPosition).distance > 10) {
      _first = null;
      return;
    }
    if(first.up != null && first.up!.pointer == event.pointer) {
      return;
    }
    first.setUp(event);
    /*Timer(const Duration(milliseconds: 100), () {
      print('up event');
      if (_second != null) return;
      final first = _first;
      if (first == null || first.pointer != event.pointer || !first.hasUp) {
        return;
      }
      if (first.isLongPress) {
        _first = null;
        onLongPress?.call(first.makeClickEvent());
      } else {
        _first = null;
        onTap?.call(first.makeClickEvent());
      }
    });*/
    if (first.isLongPress) {
      onLongPress?.call(first.makeClickEvent());
    } else {
      onTap?.call(first.makeClickEvent());
    }
  }

  static const longPressDuration = Duration(seconds: 3);
  static const shortPressDuration = Duration(seconds: 2);
}

class _TapTracker {
  final PointerDownEvent down;
  final DateTime downTime;
  PointerUpEvent? up;
  DateTime? upTime;

  _TapTracker({required this.down, required this.downTime});

  bool get hasUp => up != null;

  void setUp(PointerUpEvent event) {
    if (up != null) {
      throw Exception('tap already has up event');
    }
    up = event;
    upTime = DateTime.now();
  }

  bool get isLongPress =>
      upTime!.difference(downTime) > const Duration(milliseconds: 1000);

  int get pointer => down.pointer;

  ClickEvent makeClickEvent() {
    if (up == null) {
      throw Exception('tap does not have up event');
    }
    return ClickEvent(down: down, downTime: downTime, up: up!, upTime: upTime!);
  }
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
