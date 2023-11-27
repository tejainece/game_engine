import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';
import 'package:collection/collection.dart';

abstract class FlexComponent implements Component {
  void set({Offset? offset});

  Offset get offset;

  Size get size;
}

abstract class DimensionedComponent implements Component {
  Offset get offset;

  Size get size;

  void set({Offset? offset, Size? size});
}

class _Child {
  final FlexComponent component;
  Size? size;

  _Child({required this.component, this.size});
}

class RowComponent implements Component, FlexComponent, DimensionedComponent {
  DimensionedComponent? _bg;
  final _children = <_Child>[];
  Offset _offset = const Offset(0, 0);
  Size _size = const Size(0, 0);
  var _crossAxisAlign = CrossAxisAlignment.start;
  var _align = MainAxisAlignment.start;

  RowComponent(
      {required List<FlexComponent> children,
      DimensionedComponent? bg,
      Offset offset = const Offset(0, 0),
      Size size = const Size(0, 0),
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
      MainAxisAlignment align = MainAxisAlignment.start}) {
    _bg = bg;
    _crossAxisAlign = crossAxisAlignment;
    _align = align;

    set(offset: offset, size: size, children: children);
  }

  @override
  Size get size => _size;

  @override
  Offset get offset => _offset;

  Iterable<FlexComponent> get children => _children.map((e) => e.component);

  set children(Iterable<FlexComponent> children) {
    if (_compareChildren(children)) return;

    _children.clear();
    for (final child in children) {
      _children.add(_Child(component: child, size: child.size));
    }

    _layout();
  }

  bool _compareChildren(Iterable<FlexComponent> children) {
    if (children.length != _children.length) {
      return false;
    }

    for (final pair in IterableZip([children, this.children])) {
      if (pair[0] != pair[0]) {
        return false;
      }
    }

    return true;
  }

  bool _dirty = true;

  @override
  void set(
      {Offset? offset,
      Size? size,
      CrossAxisAlignment? crossAxisAlignment,
      MainAxisAlignment? align,
      List<FlexComponent>? children}) {
    bool needsLayout = false;
    bool dimChanged = false;
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
    if (crossAxisAlignment != null && crossAxisAlignment != _crossAxisAlign) {
      _crossAxisAlign = crossAxisAlignment;
      needsLayout = true;
    }
    if (align != null && align != _align) {
      _align = align;
      needsLayout = true;
    }
    if (children != null && !_compareChildren(children)) {
      _children.clear();
      for (final child in children) {
        _children.add(_Child(component: child));
      }
      needsLayout = true;
    }
    if (needsLayout) {
      _bg?.set(offset: _offset, size: _size);
      _layout();
      _dirty = true;
    }
  }

  @override
  void handlePointerEvent(PointerEvent event) {
    _bg?.handlePointerEvent(event);
    for (final child in _children) {
      child.component.handlePointerEvent(event);
    }
  }

  @override
  void render(Canvas canvas) {
    _bg?.render(canvas);
    for (final child in _children) {
      child.component.render(canvas);
    }
  }

  @override
  void tick(TickCtx ctx) {
    _bg?.tick(ctx);
    bool shouldLayout = false;
    for (final child in _children) {
      child.component.tick(ctx);
      if (child.size != child.component.size) {
        child.size = child.component.size;
        shouldLayout = true;
      }
    }

    if (shouldLayout) {
      _layout();
      ctx.shouldRender();
    }

    if(_dirty) {
      ctx.shouldRender();
      _dirty = false;
    }
  }

  void _layout() {
    // TODO implement wrapping
    if (_align == MainAxisAlignment.start) {
      double offset = _offset.dx;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (_size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += _size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        final tmp = offset + child.component.size.width;
        child.component.set(offset: Offset(tmp, dy));
        print('row ${child.runtimeType} €{${child.component.offset} ${child.component.size}}'); // TODO remove
        offset = tmp;
      }
    } else if (_align == MainAxisAlignment.end) {
      double offset = _offset.dx + _size.width;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (_size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += _size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        final tmp = offset - child.component.size.width;
        child.component.set(offset: Offset(tmp, dy));
        offset = tmp;
      }
    } else if (_align == MainAxisAlignment.center) {
      double totalWidth =
          _children.fold(0.0, (p, e) => p + e.component.size.width);
      var offset = _offset.dx + (_size.width - totalWidth) / 2;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (_size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += _size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        final tmp = offset + child.component.size.width;
        child.component.set(offset: Offset(tmp, dy));
        offset = tmp;
      }
    } else if (_align == MainAxisAlignment.spaceBetween) {
      final totWid = _children.fold(0.0, (p, e) => p + e.component.size.width);
      final space = (_size.width - totWid) / (_children.length - 1);

      double dx = _offset.dx;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (_size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += _size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        child.component.set(offset: Offset(dx, dy));
        dx += child.component.size.width + space;
      }
    } else if (_align == MainAxisAlignment.spaceAround) {
      final totWid = _children.fold(0.0, (p, e) => p + e.component.size.width);
      final space = (_size.width - totWid) / (_children.length * 2);

      double offset = _offset.dx + space;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (_size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += _size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        child.component.set(offset: Offset(offset, dy));
        offset += child.component.size.width + space * 2;
      }
    } else if (_align == MainAxisAlignment.spaceEvenly) {
      final totWid = _children.fold(0.0, (p, e) => p + e.component.size.width);
      final space = (_size.width - totWid) / (_children.length + 1);

      double dx = _offset.dx + space;
      for (final child in _children) {
        double dy = _offset.dy;
        if (_crossAxisAlign == CrossAxisAlignment.center) {
          dy += (_size.height - child.component.size.height) / 2;
        } else if (_crossAxisAlign == CrossAxisAlignment.end) {
          dy += _size.height - child.component.size.height;
        } else if (_crossAxisAlign == CrossAxisAlignment.stretch) {
          // TODO
        }

        child.component.set(offset: Offset(dx, dy));
        dx += child.component.size.width + space;
      }
    }
  }
}
