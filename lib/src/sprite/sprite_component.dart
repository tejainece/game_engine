import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_sprite/flutter_sprite.dart';
import 'package:game_engine/game_engine.dart';

class _Render {
  final int index;
  final Sprite sprite;
  final SpriteFrame frame;
  late final Rect src;
  late Rect _dest;

  _Render.make({
    required this.index,
    required this.sprite,
    required this.frame,
    double scale = 1,
    required Offset offset,
    required Offset anchor,
  }) {
    src = frame.portion.offset.toOffset & frame.portion.size.toSize;

    update(offset, anchor, scale);
  }

  void update(Offset offset, Offset anchor, double scale) {
    _dest = offset +
            ((anchor - sprite.anchor.toOffset + frame.translate.toOffset) *
                scale) &
        (sprite.size.toSize * scale);
  }

  ui.Image get image => frame.image;
  bool get flip => frame.flip;
  Rect get dest => _dest;
}

class SpriteComponent with BlockPointerMixin implements Component, CanAnimate {
  final Sprite sprite;

  Offset _offset = const Offset(0, 0);

  Offset _anchor = const Offset(0, 0);

  double _scale = 1;

  SpriteComponent(this.sprite,
      {required Offset offset,
      required Offset anchor,
      double scale = 1,
      double opacity = 1}) {
    this.opacity = opacity;
    this.scale = scale;
  }

  bool _dirty = true;

  _Render? _info;

  final _paint = Paint()..color = const Color.fromRGBO(255, 255, 255, 1);

  double get opacity => _paint.color.opacity;
  set opacity(double value) {
    if (opacity == value) return;
    _paint.color = _paint.color.withOpacity(value);
    _dirty = true;
  }

  double get scale => _scale;
  set scale(double value) {
    if (scale == value) return;
    set(scale: value);
  }

  Offset get offset => _offset;
  set offset(Offset value) {
    if (_offset == value) return;
    set(offset: value);
  }

  Offset get anchor => _anchor;
  set anchor(Offset value) {
    if (_anchor == value) return;
    set(anchor: value);
  }

  void set({double? scale, Offset? offset, Offset? anchor}) {
    if (offset == _offset) {
      offset = null;
    } else {
      _offset = offset!;
    }
    if (anchor == _anchor) {
      anchor = null;
    } else {
      _anchor = anchor!;
    }
    if (scale == _scale) {
      scale = null;
    } else {
      _scale = scale!;
    }
    if (offset != null || anchor != null || scale != null) {
      _info?.update(_offset, _anchor, _scale);
      _dirty = true;
    }
  }

  @override
  void paint(Canvas canvas) {
    if (_info == null) return;
    canvas.drawImageRect(_info!.image, _info!.src, _info!.dest, _paint);
  }

  @override
  bool tick(Duration timestamp, Duration delta) {
    bool oldDirty = _dirty;
    _dirty = true;

    if (sprite.frames.isEmpty) return oldDirty;
    if (_info == null) {
      _info = _Render.make(
        index: 0,
        frame: sprite.frames[0],
        scale: scale,
        offset: offset,
        anchor: anchor,
        sprite: sprite,
      );
      return true;
    }
    if (_paused) return oldDirty;
    _elapsed += delta;
    final frameInterval = _info!.frame.interval ?? sprite.interval;
    if (_elapsed < frameInterval) return true;
    int index = (_info!.index + 1) % sprite.frames.length;
    _info = _Render.make(
      index: index,
      frame: sprite.frames[index],
      scale: scale,
      offset: offset,
      anchor: anchor,
      sprite: sprite,
    );
    return true;
  }

  @override
  void dispose() {}

  Duration _elapsed = const Duration();

  bool _paused = false;

  @override
  bool get isPaused => _paused;

  @override
  void play() {
    _paused = false;
  }

  @override
  void pause() {
    _paused = true;
  }
}

abstract class CanAnimate {
  void play();

  void pause();

  bool get isPaused;
}

extension PointExt on Point<num> {
  Point<int> get toInt => Point(x.toInt(), y.toInt());
  Point<double> get toDouble => Point(x.toDouble(), y.toDouble());
  Size get toSize => Size(x.toDouble(), y.toDouble());
  Offset get toOffset => Offset(x.toDouble(), y.toDouble());
}
