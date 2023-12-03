import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:game_engine/game_engine.dart';

class RectClip extends Component {
  final _children = <Component>[];
  var _offset = const Offset(0, 0);
  var _size = const Size(0, 0);

  RectClip(
      {required List<Component> children,
      Offset offset = const Offset(0, 0),
      Size size = const Size(0, 0)}) {
    _children.addAll(children);
    _offset = offset;
    _size = size;
  }

  bool _dirty = true;

  void set({Offset? offset, Size? size}) {
    bool needsUpdate = false;
    if (offset != null && _offset != offset) {
      _offset = offset;
      needsUpdate = true;
    }
    if (size != null && _size != size) {
      _size = size;
      needsUpdate = true;
    }
    if (needsUpdate) _dirty = true;
  }

  set children(List<Component> value) {
    _children.clear();
    _children.addAll(value);
    _dirty = true;
  }

  @override
  void handlePointerEvent(PointerEvent event) {
    for (final child in _children) {
      child.handlePointerEvent(event);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.clipRect(rect);
    for (final child in _children) {
      child.render(canvas);
    }
    canvas.restore();
  }

  Rect get rect => _offset & _size;

  @override
  void tick(TickCtx ctx) {
    if (_dirty) {
      _dirty = false;
      ctx.shouldRender();
    }

    for (final child in _children) {
      child.tick(ctx);
    }
  }
}

/*
class Opacity implements Component {
  final _children = <Component>[];

  @override
  void handlePointerEvent(PointerEvent event) {
    for(final comp in _children) {
      comp.handlePointerEvent(event);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.
    for(final comp in _children) {
      comp.render(canvas);
    }
  }

  bool _dirty = true;

  @override
  void tick(TickCtx ctx) {
    if(_dirty) {
      _dirty = false;
      ctx.shouldRender();
    }

    for(final comp in _children) {
      comp.tick(ctx);
    }
  }

  final _paint = Paint();

  set opacity(double value) {
    _paint.color = _paint.color.withOpacity(value);
  }
}
*/
