part of 'widget.dart';

class ComponentContext {
  bool _needsRerender = false;

  void requestRender(Component component) {
    if (!_children.contains(component)) return;
    _needsRerender = true;
  }

  final _children = <Component>{};

  final _pointerEventHandlers = <PointerEventHandler>{};

  final _tickHandlers = <NeedsTick>{};

  void registerComponent(Component component) {
    _children.add(component);
    if (component is PointerEventHandler) {
      _pointerEventHandlers.add(component);
    }
    if (component is NeedsTick) {
      _tickHandlers.add(component);
    }
    // TODO register
    requestRender(component);
    component.onAttach(this);
  }

  void registerComponents(List<Component> components) {
    for (final component in components) {
      registerComponent(component);
    }
  }

  void unregisterComponent(Component? component) {
    if (component == null) return;
    _children.remove(component);
    if (component is PointerEventHandler) {
      _pointerEventHandlers.remove(component);
    }
    // TODO deregister
    if (component is NeedsTick) {
      _tickHandlers.remove(component);
    }
    if (component is NeedsDetach) {
      component.onDetach(this);
    }
  }

  void unregisterComponents(List<Component> components) {
    for (final component in components) {
      unregisterComponent(component);
    }
  }
}
