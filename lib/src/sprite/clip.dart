import 'dart:ui';

import 'package:game_engine/game_engine.dart';

class RectClip extends Component {
  final _children = <Component>[];
  var _offset = const Offset(0, 0);
  var _size = const Size(0, 0);

  RectClip(
      {required List<Component> children,
      Offset offset = const Offset(0, 0),
      Size size = const Size(0, 0)})
      : _offset = offset,
        _size = size {
    _children.addAll(children);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.clipRect(rect);
    try {
      for (final child in _children) {
        child.render(canvas);
      }
    } finally {
      canvas.restore();
    }
  }

  void set({Offset? offset, Size? size, List<Component>? children}) {
    bool needsUpdate = false;
    if (offset != null && _offset != offset) {
      _offset = offset;
      needsUpdate = true;
    }
    if (size != null && _size != size) {
      _size = size;
      needsUpdate = true;
    }
    if (children != null) {
      _setChildren(children);
      needsUpdate = true;
    }
    if (needsUpdate) {
      _ctx?.requestRender(this);
    }
  }

  void _setChildren(List<Component> value) {
    final set = Set<Component>.from(value);
    for (final component in _children) {
      if (set.contains(component)) continue;
      _ctx?.unregisterComponent(component);
    }
    _children.clear();
    _children.addAll(value);
    _ctx?.registerComponents(_children);
  }

  Rect get rect => _offset & _size;

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
    _ctx?.registerComponents(_children);
  }
}
