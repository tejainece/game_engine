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
    required Size size,
  }) {
    src = frame.rectangle.rect;
    update(offset, anchor, scale, size);
  }

  void update(Offset offset, Offset anchor, double scale, Size size) {
    Offset o = offset;
    if(!flip) {
      o += anchor - (sprite.anchor - frame.translate).o * scale;
    } else {
      anchor = Offset(size.width - anchor.dx, anchor.dy);
      o += anchor - (sprite.anchor - frame.translate).o * scale;
      // TODO
    }

    _dest = o & frame.portion.size.s * scale;
  }

  ui.Image get image => frame.image;

  Rect get dest => _dest;

  bool get flip => sprite.flip;
}

class SpriteComponent with BlockPointerMixin implements Component, CanAnimate {
  Sprite? _sprite;

  var _offset = const Offset(0, 0);
  var _anchor = const Offset(0, 0);
  double _scale = 1;
  VoidCallback? onLoopOver;

  SpriteComponent(Sprite sprite,
      {required Offset offset,
      required Offset anchor,
      double scale = 1,
      num? scaleWidth,
      double opacity = 1,
      this.onLoopOver}) {
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

  Size _size = Size(0, 0);

  set size(Size value) {
    if(_size == value) return;
    set(size: value);
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
      Offset? anchor, Size? size}) {
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

    if (_info!.flip) {
      canvas.save();
      double dx = -(_info!._dest.left + _info!._dest.width / 2);
      canvas.translate(-dx, 0.0);
      canvas.scale(-1.0, 1.0);
      canvas.translate(dx, 0.0);
    }

    canvas.drawImageRect(_info!.image, _info!.src, _info!.dest, _paint);

    if (_info!.flip) {
      canvas.restore();
    }
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
        if (onLoopOver != null) {
          if (_info!.index == sprite.frames.length - 1) {
            onLoopOver!();
          }
        }
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
