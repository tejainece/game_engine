import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:game_engine/game_engine.dart';
import 'package:vector_path/vector_path.dart';

part 'context.dart';
part 'tick_context.dart';

class GameWidget extends StatefulWidget {
  final ValueChanged<Size>? onResize;
  final Color color;
  final CanvasTransformer? transformer;
  final Component? component;
  final bool debug;

  final ValueChanged<ClickEvent>? onTap;

  // TODO onPanStart
  final ValueChanged<PanData>? onPan;

  // TODO onPanEnd
  // TODO onScaleStart
  final ValueChanged<ScaleData>? onScale;

  // TODO onScaleEnd

  const GameWidget(
      {super.key,
      this.component,
      this.color = Colors.black,
      this.onResize,
      this.transformer,
      this.debug = false,
      this.onTap,
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
    return GestureDetector(
      onScaleStart: _detector.scaleStart,
      onScaleUpdate: _detector.scaleUpdate,
      onScaleEnd: _detector.scaleEnd,
      child: _GameWidget(
        component: widget.component,
        color: widget.color,
        onResize: widget.onResize,
        transformer: widget.transformer,
        debug: widget.debug,
        onTap: widget.onTap,
      ),
    );
  }
}

class _GameWidget extends LeafRenderObjectWidget {
  final ValueChanged<Size>? onResize;
  final Color color;
  final CanvasTransformer? transformer;
  final Component? component;
  final bool debug;
  final ValueChanged<ClickEvent>? onTap;

  const _GameWidget(
      {Key? key,
      this.onResize,
      this.color = Colors.black,
      this.transformer,
      required this.component,
      this.debug = false,
      this.onTap})
      : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      GameWidgetRenderObject(
          onResize: onResize,
          color: color,
          transformer: transformer,
          component: component,
          debug: debug);

  @override
  void updateRenderObject(
      BuildContext context, GameWidgetRenderObject renderObject) {
    renderObject._update(
        onResize: onResize,
        color: color,
        transformer: transformer,
        component: component,
        debug: debug,
        onTap: onTap);
  }
}

class GameWidgetRenderObject extends RenderBox {
  Size _oldSize = Size.zero;
  ValueChanged<Size>? _onResize;
  Color color;
  Component? _component;
  bool debug;
  CanvasTransformer? transformer;
  ValueChanged<ClickEvent>? onTap;

  GameWidgetRenderObject(
      {ValueChanged<Size>? onResize,
      required this.color,
      required Component? component,
      this.transformer,
      this.debug = false,
      this.onTap}) {
    this.onResize = onResize;
    _updateComponents(component);
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
      required Component? component,
      required bool debug,
      required ValueChanged<ClickEvent>? onTap}) {
    _onResize = onResize;
    this.color = color;
    this.transformer = transformer;
    _updateComponents(component);
    this.debug = debug;
    this.onTap = onTap;
    markNeedsPaint();
  }

  void _updateComponents(Component? component) {
    if (_component != component) {
      if (_component != null) {
        _ctx.unregisterComponent(_component!);
      }
    }
    _component = component;
    if (_component != null) {
      _ctx.registerComponent(_component!);
    }
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
    _component?.render(context.canvas);
    context.canvas.restore();
    if (debug) {
      debugPrint('${DateTime.now()} => painting took ${clock.elapsed}');
    }
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    for (final handler in _ctx._pointerEventHandlers) {
      handler.handlePointerEvent(event);
    }
    _tapDetector.handlePointerEvent(event);
  }

  late final _tapDetector = TapDetector(
    onTap: (value) {
      onTap?.call(value);
    },
  );

  final _ctx = ComponentContext();

  @override
  bool hitTestSelf(Offset position) => true;

  late final _ticker = Ticker(_tick);

  final TickContext _tickCtx = TickContext();

  void _tick(Duration elapsed) {
    final clock = Stopwatch()..start();
    _tickCtx.nextTick(elapsed);

    for (final handler in _ctx._tickHandlers) {
      handler.tick(_tickCtx);
    }
    if (_ctx._needsRerender) {
      markNeedsPaint();
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

void centeredYUp(Canvas canvas, Size size) {
  canvas.translate(size.width / 2, size.height / 2);
  canvas.scale(1, -1);
}

CanvasTransformer centeredYUpWith({P? scale, P? translate}) {
  return (Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(1, -1);
    if (translate != null) {
      canvas.translate(-translate.x, -translate.y);
    }
    if (scale != null) {
      canvas.scale(scale.x, -1 * scale.y);
    }
  };
}

void centeredYDown(Canvas canvas, Size size) {
  canvas.translate(size.width / 2, size.height / 2);
}

CanvasTransformer centeredYDownWith({P? scale, P? translate}) {
  return (Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    if (translate != null) {
      canvas.translate(-translate.x, -translate.y);
    }
    if (scale != null) {
      canvas.scale(scale.x, scale.y);
    }
  };
}
