import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:game_engine/game_engine.dart';

class GameWidget extends StatefulWidget {
  final ValueChanged<Size>? onResize;
  final Color color;
  final CanvasTransformer? transformer;
  final List<List<Component>> components;
  final bool debug;
  final ValueChanged<PanData>? onPan;
  final ValueChanged<ScaleData>? onScale;

  const GameWidget(
      {super.key,
      required this.components,
      this.color = Colors.black,
      this.onResize,
      this.transformer,
      this.debug = false,
      this.onPan,
      this.onScale});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  late final ViewportGestureDetector _detector = ViewportGestureDetector(
    onPan: (data) {
      widget.onPan?.call(data);
    },
    onScale: (data) {
      widget.onScale?.call(data);
    },
  );

  @override
  Widget build(BuildContext context) {
    final child = _GameWidget(
      components: widget.components,
      color: widget.color,
      onResize: widget.onResize,
      transformer: widget.transformer,
      debug: widget.debug,
    );
    if (widget.onPan == null && widget.onScale == null) {
      return child;
    }
    return GestureDetector(
      onScaleStart: _detector.scaleStart,
      onScaleUpdate: _detector.scaleUpdate,
      onScaleEnd: _detector.scaleEnd,
      child: child,
    );
  }
}

class _GameWidget extends LeafRenderObjectWidget {
  final ValueChanged<Size>? onResize;
  final Color color;
  final CanvasTransformer? transformer;
  final List<List<Component>> components;
  final bool debug;

  const _GameWidget(
      {Key? key,
      this.onResize,
      this.color = Colors.black,
      this.transformer,
      required this.components,
      this.debug = false})
      : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      GameWidgetRenderObject(
          onResize: onResize,
          color: color,
          transformer: transformer,
          components: components,
          debug: debug);

  @override
  void updateRenderObject(
      BuildContext context, GameWidgetRenderObject renderObject) {
    renderObject._update(
        onResize: onResize,
        color: color,
        transformer: transformer,
        components: components,
        debug: debug);
  }
}

class GameWidgetRenderObject extends RenderBox {
  Size _oldSize = Size.zero;
  ValueChanged<Size>? _onResize;
  Color color;
  List<List<Component>> _components;
  bool debug;
  CanvasTransformer? transformer;

  GameWidgetRenderObject(
      {ValueChanged<Size>? onResize,
      required this.color,
      required List<List<Component>> components,
      this.transformer,
      this.debug = false})
      : _components = components {
    this.onResize = onResize;
  }

  set onResize(ValueChanged<Size>? value) {
    _onResize = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onResize?.call(_oldSize);
    });
  }

  void _update(
      {required ValueChanged<Size>? onResize,
      required Color color,
      required CanvasTransformer? transformer,
      required List<List<Component>> components,
      required bool debug}) {
    _onResize = onResize;
    this.color = color;
    this.transformer = transformer;
    _components = components;
    this.debug = debug;
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
      _onResize?.call(_oldSize);
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final clock = Stopwatch()..start();

    context.canvas.save();
    context.canvas.clipRect(offset & size);
    context.canvas.translate(offset.dx, offset.dy);
    if (transformer != null) transformer!(context.canvas, _oldSize);
    context.canvas.drawColor(color, BlendMode.src);
    for (final layer in _components) {
      for (final component in layer) {
        component.render(context.canvas);
      }
    }
    context.canvas.restore();
    if (debug) {
      debugPrint('${DateTime.now()} => painting took ${clock.elapsed}');
    }
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

  TickCtx? _ctx, otherCtx;

  void _tick(Duration elapsed) {
    final clock = Stopwatch()..start();
    _ctx ??=
        TickCtx(timestamp: elapsed, dt: const Duration(), canvasSize: _oldSize);
    _ctx!.nextTick(elapsed, _oldSize);

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
    if (debug) {
      debugPrint('${DateTime.now()} => ticking took ${clock.elapsed}');
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _ticker.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onResize?.call(_oldSize);
    });
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

typedef CanvasTransformer = void Function(Canvas canvas, Size size);

void originToCenter(Canvas canvas, Size size) {
  canvas.translate(size.width / 2, size.height / 2);
  canvas.scale(1, -1);
}

CanvasTransformer originToCenterWith({Offset? scale, Offset? translate}) {
  return (Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale?.dx ?? 1, -1 * (scale?.dy ?? 1));
    if (translate != null) {
      canvas.translate(-translate.dx, -translate.dy);
    }
  };
}
