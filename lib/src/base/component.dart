import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

abstract class CanvasPainter {
  void render(Canvas canvas);
}

abstract class Component implements CanvasPainter {
  void onAttach(ComponentContext ctx);

  static bool compareChildren(List<Component> child1, List<Component> child2) {
    if (child1.length != child2.length) return false;

    for (int i = 0; i < child1.length; i++) {
      if (child1[i] != child2[i]) return false;
    }

    return true;
  }

  static bool compareChildrenIterable(
      Iterable<Component> children1, Iterable<Component> children2) {
    final it1 = children1.iterator;
    final it2 = children2.iterator;
    while (it1.moveNext()) {
      if (!it2.moveNext()) return false;
      if (it1.current != it2.current) return false;
    }
    return !it2.moveNext();
  }

  static Set<Component> updateChildren(Set<Component> oldChildren,
      List<Component> newChildren, ComponentContext? ctx) {
    final newSet = Set<Component>.from(newChildren);
    if (ctx != null) {
      for (final child in newChildren) {
        ctx.registerComponent(child);
      }
      for (final child in oldChildren) {
        if (!newSet.contains(child)) {
          ctx.unregisterComponent(child);
        }
      }
    }
    return newSet;
  }
}

abstract class NeedsDetach implements Component {
  void onDetach(ComponentContext ctx);
}

abstract class CanHitTest implements Component {
  bool hitTest(Offset point);
}

abstract class PointerEventHandler implements Component {
  void handlePointerEvent(PointerEvent event);
}

abstract class NeedsTick implements Component {
  void tick(TickContext ctx);
}

