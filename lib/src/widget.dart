import 'package:game_engine/game_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class GameWidget extends LeafRenderObjectWidget {
  final ValueChanged<Size>? onResize;
  final List<List<Component>> components;

  const GameWidget({Key? key, this.onResize, required this.components})
      : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      GameWidgetRenderObject(onResize: onResize, components: components);

  @override
  void updateRenderObject(
      BuildContext context, GameWidgetRenderObject renderObject) {
    renderObject._update(onResize: onResize, components: components);
  }
}

class GameWidgetRenderObject extends RenderBox {
  Size? _oldSize;
  ValueChanged<Size>? _onResize;
  List<List<Component>> _components;

  GameWidgetRenderObject(
      {ValueChanged<Size>? onResize, required List<List<Component>> components})
      : _components = components {
    this.onResize = onResize;
  }

  set onResize(ValueChanged<Size>? value) {
    _onResize = value;
    if (_oldSize != null) {
      _onResize?.call(_oldSize!);
    }
  }

  void _update(
      {required ValueChanged<Size>? onResize,
      required List<List<Component>> components}) {
    _onResize = onResize;
    _components = components;
    markNeedsPaint();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    super.performResize();
    if (_oldSize == size) return;

    _oldSize = size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onResize?.call(_oldSize!);
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawColor(Colors.black, BlendMode.src);

    context.canvas.save();
    for (final layer in _components) {
      for (final component in layer) {
        component.paint(context.canvas);
      }
    }
    context.canvas.restore();
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    for (final layer in _components) {
      for (final component in layer) {
        component.handleEvent(event);
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  late final _ticker = Ticker(_tick);

  void _tick(Duration elapsed) {
    bool needsUpdate = false;
    for (final layer in _components) {
      for (final component in layer) {
        if (component.tick(elapsed)) {
          needsUpdate = true;
        }
      }
    }
    if (needsUpdate) {
      markNeedsPaint();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _ticker.start();
    if (_oldSize != null) {
      _onResize?.call(_oldSize!);
    }
  }

  @override
  void detach() {
    _ticker.stop();
    super.detach();
  }

  @override
  void dispose() {
    _ticker.stop();
    super.dispose();
  }
}
