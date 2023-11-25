import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class ScaledImage with BlockPointerMixin implements Component {
  late ui.Image _image;
  var _offset = const Offset(0, 0);
  double _scale = 1;

  ScaledImage(
    this._image, {
    Offset offset = const Offset(0, 0),
    double scale = 1,
    double opacity = 1,
    num? refScale,
    num? toScale,
  }) {
    set(
        offset: offset,
        scale: scale,
        opacity: opacity,
        refScale: refScale,
        toScale: toScale);
  }

  late Rect _src =
      Rect.fromLTWH(0, 0, _image.width.toDouble(), _image.height.toDouble());

  late Rect _dest = Rect.fromLTWH(_offset.dx, _offset.dy,
      _image.width.toDouble() * _scale, _image.height.toDouble() * _scale);

  final _paint = Paint();

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(_image, _src, _dest, _paint);
  }

  @override
  void tick(TickCtx ctx) {
    if (_dirty) {
      _dirty = false;
      ctx.shouldRender();
    }
  }

  bool _dirty = true;

  void _update() {
    _src =
        Rect.fromLTWH(0, 0, _image.width.toDouble(), _image.height.toDouble());
    _dest = Rect.fromLTWH(_offset.dx, _offset.dy,
        _image.width.toDouble() * _scale, _image.height.toDouble() * _scale);
  }

  set image(ui.Image value) {
    if (_image == value) return;
    _image = value;
    _update();
  }

  set offset(Offset value) {
    if (_offset == value) return;
    _offset = value;
    _update();
  }

  void set(
      {ui.Image? image,
      Offset? offset,
      double? scale,
      num? refScale,
      num? toScale,
      double? opacity}) {
    bool needsUpdate = false;
    if (image != null && image != _image) {
      _image = image;
      needsUpdate = true;
    }
    if (offset != null && offset != _offset) {
      _offset = offset;
      needsUpdate = true;
    }
    if (toScale != null) {
      refScale ??= _image.width;
      double scale = toScale / refScale;
      if (scale != _scale) {
        _scale = scale;
        needsUpdate = true;
      }
    }
    if (scale != null && scale != _scale) {
      _scale = scale;
      needsUpdate = true;
    }
    if (opacity != null && opacity != this.opacity) {
      _paint.color = _paint.color.withOpacity(opacity);
      _dirty = true;
    }
    if (needsUpdate) {
      _update();
      _dirty = true;
    }
  }

  double get opacity => _paint.color.opacity;
}
