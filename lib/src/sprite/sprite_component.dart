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
    src = frame.rectangle.rect;
    update(offset, anchor, scale);
  }

  void update(Offset offset, Offset anchor, double scale) {
    print('${anchor} ${frame.translate}');
    _dest = offset +
            ((anchor - frame.translate.toOffset) *
                scale) &
        (sprite.size.toSize * scale);
  }

  ui.Image get image => frame.image;
  bool get flip => frame.flip;
  Rect get dest => _dest;
}

class SpriteComponent with BlockPointerMixin implements Component, CanAnimate {
  Sprite? _sprite;

  Offset _offset = const Offset(0, 0);

  Offset _anchor = const Offset(0, 0);

  double _scale = 1;

  SpriteComponent(Sprite sprite,
      {required Offset offset,
      required Offset anchor,
      double scale = 1,
      num? scaleWidth,
      double opacity = 1}) {
    set(
        sprite: sprite,
        anchor: anchor,
        offset: offset,
        scale: scale,
        scaleWidth: scaleWidth);
    this.opacity = opacity;
  }

  bool _dirty = true;

  _Render? _info;

  final _paint = Paint()..color = const Color.fromRGBO(255, 255, 255, 1);

  Sprite get sprite => _sprite!;
  set sprite(Sprite value) {
    if (value == _sprite) return;
    _sprite = value;
    if (_sprite!.frames.isNotEmpty) {
      _info = _Render.make(
        index: 0,
        frame: _sprite!.frames[0],
        scale: _scale,
        offset: _offset,
        anchor: _anchor,
        sprite: _sprite!,
      );
    } else {
      _info = null;
    }
    _dirty = true;
  }

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

  void set(
      {Sprite? sprite,
      double? scale,
      num? scaleWidth,
      Offset? offset,
      Offset? anchor}) {
    bool needsUpdate = false;
    if (offset != null && offset != _offset) {
      _offset = offset;
      needsUpdate = true;
    }
    if (anchor != null && anchor != _anchor) {
      _anchor = anchor;
      needsUpdate = true;
    }
    if (scale != null && scale != _scale) {
      _scale = scale;
      needsUpdate = true;
    }
    if (sprite != null && sprite != _sprite) {
      this.sprite = sprite;
    }
    if (scaleWidth != null) {
      if (_sprite!.refScale == null) {
        throw Exception('cannot use scaleWidth when refScale is null');
      }
      scale = scaleWidth / _sprite!.refScale!;
      if (scale != _scale) {
        _scale = scale;
        needsUpdate = true;
      }
    }
    if (needsUpdate) {
      _info?.update(_offset, _anchor, _scale);
      _dirty = true;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_info == null) return;
    canvas.drawImageRect(_info!.image, _info!.src, _info!.dest, _paint);
  }

  @override
  void tick(TickCtx ctx) {
    bool needsRender = _dirty;
    _dirty = false;

    if (_sprite!.frames.length <= 1) {
      // Do nothing
    } else if (!_paused) {
      _elapsed += ctx.dt;
      final frameInterval = _info!.frame.interval ?? sprite.interval;
      if (_elapsed >= frameInterval) {
        int index = (_info!.index + 1) % sprite.frames.length;
        _info = _Render.make(
          index: index,
          frame: _sprite!.frames[index],
          scale: _scale,
          offset: _offset,
          anchor: _anchor,
          sprite: _sprite!,
        );
        _elapsed = const Duration();
        needsRender = true;
      }
    }

    if (needsRender) ctx.shouldRender();
  }

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
