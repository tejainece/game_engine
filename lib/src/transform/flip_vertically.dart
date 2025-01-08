import 'dart:ui';

import 'package:game_engine/game_engine.dart';

class FlipVerticallyComponent extends Component {
  double _atY;

  Component? _child;

  FlipVerticallyComponent({double atY = 0, Component? child})
      : _atY = atY,
        _child = child;

  @override
  void render(Canvas canvas) {
    canvas.save();
    try {
      transformCanvas(canvas, atY: _atY);
      _child?.render(canvas);
    } finally {
      canvas.restore();
    }
  }

  void set({double? atY, Component? child}) {
    bool needsUpdate = false;
    if (atY != null && _atY != atY) {
      _atY = atY;
      needsUpdate = true;
    }
    if(child != null && _child != child) {
      _child = child;
      needsUpdate = true;
    }
    if (needsUpdate) {
      _ctx?.requestRender(this);
    }
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
  }

  static void transformCanvas(Canvas canvas, {double atY = 0}) {
    canvas.translate(0, atY);
    canvas.scale(1, -1);
    canvas.translate(0, -atY);
  }
}
