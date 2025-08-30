import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

export 'box.dart';

abstract class PositionedComponent implements Component {
  void set({Offset? offset});

  Offset get offset;

  Size get size;
}

abstract class SizedPositionedComponent implements Component {
  void set({Offset? offset, Size? size});

  Offset get offset;

  Size get size;
}

abstract class OnResizeComponent implements SizedPositionedComponent {
  void onResizeListener(Object key, VoidCallback callback);

  void deregisterOnResizeListener(Object key);
}

class RowComponent
    implements
        Component,
        PositionedComponent,
        SizedPositionedComponent,
        NeedsDetach {
  SizedPositionedComponent? _bg;
  List<_Child> _children = [];
  Offset _offset = const Offset(0, 0);
  Size _size = const Size(0, 0);
  var _crossAxisAlign = CrossAxisAlignment.start;
  var _align = MainAxisAlignment.start;
  EdgeInsets _padding = const EdgeInsets.all(0);

  @override
  Size get size => _size;

  @override
  Offset get offset => _offset;

  RowComponent({
    required List<PositionedComponent> children,
    SizedPositionedComponent? bg,
    Offset offset = const Offset(0, 0),
    Size size = const Size(0, 0),
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment align = MainAxisAlignment.start,
    EdgeInsets? padding,
  }) : _offset = offset,
       _size = size,
       _bg = bg,
       _crossAxisAlign = crossAxisAlignment,
       _align = align {
    _bg?.set(offset: offset, size: size);
    _updateChildren(children);
    _layout();
  }

  @override
  void render(Canvas canvas) {
    _bg?.render(canvas);
    for (final child in _children) {
      child.component.render(canvas);
    }
  }

  @override
  void set({
    Offset? offset,
    Size? size,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisAlignment? align,
    SizedPositionedComponent? bg,
    EdgeInsets? padding,
    List<PositionedComponent>? children,
  }) {
    bool needsLayout = false;
    bool dimChanged = false;
    if (bg != null && bg != _bg) {
      if (_bg != null) {
        _ctx?.unregisterComponent(_bg!);
      }
      _bg = bg;
      _ctx?.registerComponent(_bg!);
    }
    if (offset != null && offset != _offset) {
      _offset = offset;
      needsLayout = true;
      dimChanged = true;
    }
    if (size != null && size != _size) {
      _size = size;
      needsLayout = true;
      dimChanged = true;
    }
    if (dimChanged) {
      _bg?.set(offset: _offset, size: _size);
    }
    if (padding != null && padding != _padding) {
      _padding = padding;
      needsLayout = true;
    }
    if (crossAxisAlignment != null && crossAxisAlignment != _crossAxisAlign) {
      _crossAxisAlign = crossAxisAlignment;
      needsLayout = true;
    }
    if (align != null && align != _align) {
      _align = align;
      needsLayout = true;
    }
    if (children != null && _compareChildren(children)) {
      _updateChildren(children);
      needsLayout = true;
    }
    if (needsLayout) {
      _layout();
      _ctx?.requestRender(this);
    }
  }

  Map<PositionedComponent, _Child> _childSet = {};

  void _updateChildren(List<PositionedComponent> children) {
    final newChildren = <_Child>[];
    final childSet = <PositionedComponent, _Child>{};
    for (final child in children) {
      _Child? existing = _childSet[child];
      if (existing == null) {
        existing = _Child(component: child);
        _childSet[child] = existing;
        _ctx?.registerComponent(child);
      }
      childSet[child] = existing;
      newChildren.add(existing);
    }
    for (final existing in _childSet.values) {
      if (!childSet.containsKey(existing.component)) {
        _ctx?.unregisterComponent(existing.component);
      }
    }
    _childSet = childSet;
    _children = newChildren;
  }

  List<PositionedComponent> get children =>
      _children.map((e) => e.component).toList();

  bool _compareChildren(Iterable<PositionedComponent> children) {
    if (children.length != _children.length) {
      return false;
    }

    for (final pair in IterableZip([children, this.children])) {
      if (pair[0] != pair[1]) {
        return false;
      }
    }

    return true;
  }

  void _layout() {
    Size size = _padding.deflateSize(_size);
    Offset _offset = this._offset + _padding.topLeft;
    // TODO implement wrapping
    if (_align == MainAxisAlignment.start) {
      double offset = _offset.dx;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        child.component.set(offset: Offset(offset, dy));
        offset += child.component.size.width;
        /*print(
            'row ${child.component.runtimeType} ${child.component.offset} ${child.component.size}');*/ // TODO remove
      }
    } else if (_align == MainAxisAlignment.end) {
      double offset = _offset.dx + size.width;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        final tmp = offset - child.component.size.width;
        child.component.set(offset: Offset(tmp, dy));
        offset = tmp;
      }
    } else if (_align == MainAxisAlignment.center) {
      double totalWidth = _children.fold(
        0.0,
        (p, e) => p + e.component.size.width,
      );
      var offset = _offset.dx + (size.width - totalWidth) / 2;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        child.component.set(offset: Offset(offset, dy));
        offset += child.component.size.width;
      }
    } else if (_align == MainAxisAlignment.spaceBetween) {
      final totWid = _children.fold(0.0, (p, e) => p + e.component.size.width);
      final space = (size.width - totWid) / (_children.length - 1);

      double dx = _offset.dx;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        child.component.set(offset: Offset(dx, dy));
        dx += child.component.size.width + space;
      }
    } else if (_align == MainAxisAlignment.spaceAround) {
      final totWid = _children.fold(0.0, (p, e) => p + e.component.size.width);
      final space = (size.width - totWid) / (_children.length * 2);

      double offset = _offset.dx + space;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        child.component.set(offset: Offset(offset, dy));
        offset += child.component.size.width + space * 2;
      }
    } else if (_align == MainAxisAlignment.spaceEvenly) {
      final totWid = _children.fold(0.0, (p, e) => p + e.component.size.width);
      final space = (size.width - totWid) / (_children.length + 1);

      double dx = _offset.dx + space;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        child.component.set(offset: Offset(dx, dy));
        dx += child.component.size.width + space;
      }
    }
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
    if (_bg != null) {
      _ctx?.registerComponent(_bg!);
    }
    for (final child in _children) {
      _ctx?.registerComponent(child.component);
    }
  }

  @override
  void onDetach(ComponentContext ctx) {
    if (_bg != null) {
      ctx.unregisterComponent(_bg!);
    }
    for (final child in _children) {
      ctx.unregisterComponent(child.component);
    }
    _ctx = null;
  }
}

class _Child {
  final PositionedComponent component;

  _Child({required this.component});
}
