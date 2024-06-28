import 'package:game_engine/game_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class GameWidget extends LeafRenderObjectWidget {
  final ValueChanged<Size>? onResize;
  final ValueChanged<PointerEvent>? onPanZoom;
  final List<List<Component>> components;
  final ValueChanged<Offset>? onMoveOffset;

  const GameWidget(
      {Key? key,
      this.onResize,
      this.onPanZoom,
      this.onMoveOffset,
      required this.components})
      : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      GameWidgetRenderObject(
          onResize: onResize, components: components, onPanZoom: onPanZoom);

  @override
  void updateRenderObject(
      BuildContext context, GameWidgetRenderObject renderObject) {
    renderObject._update(
        onResize: onResize,
        onPanZoom: onPanZoom,
        components: components,
        onMoveOffset: onMoveOffset);
  }
}

class GameWidgetRenderObject extends RenderBox {
  Size? _oldSize;
  ValueChanged<Size>? _onResize;
  ValueChanged<PointerEvent>? onPanZoom;
  ValueChanged<Offset>? onMoveOffset;
  List<List<Component>> _components;

  GameWidgetRenderObject(
      {ValueChanged<Size>? onResize,
      this.onPanZoom,
      this.onMoveOffset,
      required List<List<Component>> components})
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
      required ValueChanged<PointerEvent>? onPanZoom,
      required ValueChanged<Offset>? onMoveOffset,
      required List<List<Component>> components}) {
    _onResize = onResize;
    this.onPanZoom = onPanZoom;
    this.onMoveOffset = onMoveOffset;
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
    context.canvas.translate(offset.dx, offset.dy);
    for (final layer in _components) {
      for (final component in layer) {
        component.render(context.canvas);
      }
    }
    context.canvas.restore();
    // print('${DateTime.now()} => painting took ${start.elapsed}');
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    for (final layer in _components) {
      for (final component in layer) {
        component.handlePointerEvent(event);
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  late final _ticker = Ticker(_tick);

  TickCtx? _ctx;

  void _tick(Duration elapsed) {
    _ctx ??= TickCtx(timestamp: elapsed, dt: const Duration());
    _ctx!.nextTick(elapsed);

    for (final layer in _components) {
      for (final component in layer) {
        component.tick(_ctx!);
      }
    }
    if (_ctx!.needsRender) {
      markNeedsPaint();
    }
    for (final object in _ctx!.detached) {
      object.onDetach();
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
