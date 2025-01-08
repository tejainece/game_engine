import 'dart:ui';

import 'package:game_engine/game_engine.dart';

class LayerComponent implements Component, NeedsDetach {
  List<Component> _children = [];

  LayerComponent(List<Component> children) {
    _updateChildren(children);
  }

  @override
  void render(Canvas canvas) {
    for (final child in _children) {
      child.render(canvas);
    }
  }

  void set({List<Component>? children}) {
    bool needsUpdate = false;
    if(children != null && !Component.compareChildren(children, _children)) {
      _updateChildren(children);
      needsUpdate = true;
    }
    if(needsUpdate) {
      _ctx?.requestRender(this);
    }
  }

  Set<Component> _set = {};

  void _updateChildren(List<Component> children) {
    _set = Component.updateChildren(_set, _children, _ctx);
    _children = children;
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
    _ctx?.registerComponents(_children);
  }

  @override
  void onDetach(ComponentContext ctx) {
    _ctx?.unregisterComponents(_children);
    _ctx = null;
  }
}