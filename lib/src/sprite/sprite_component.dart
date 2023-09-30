import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_sprite/flutter_sprite.dart';
import 'package:game_engine/game_engine.dart';

class _Render {
  final int index;
  ui.Image get image => frame.image;
  final SpriteFrame frame;
  late final Rect rect;

  _Render.make({required this.index, required this.frame}) {
    // TODO compute rect
  }
}

class SpriteComponent implements Component, CanAnimate {
  final Sprite sprite;

  double opacity;

  double scale;

  SpriteComponent(this.sprite, {this.opacity = 1, this.scale = 1});

  _Render? _info;

  @override
  void paint(Canvas canvas) {
    if (_info == null) return;
    paintImage(
        canvas: canvas,
        rect: _info!.rect,
        image: _info!.image,
        opacity: opacity,
        scale: scale,
        // TODO flipHorizontally: _info!.flip,
        isAntiAlias: true);
  }

  @override
  bool tick(Duration timestamp, Duration delta) {
    if (sprite.frames.isEmpty) return false;
    if (_paused) return false;
    _elapsed += delta;
    if (_info == null) {
      _info = _Render.make(index: 0, frame: sprite.frames[0]);
      return true;
    }
    final frameInterval = _info!.frame.interval ?? sprite.interval;
    if (_elapsed < frameInterval) return true;
    int index = (_info!.index + 1) % sprite.frames.length;
    _info = _Render.make(index: index, frame: sprite.frames[index]);
    return true;
  }

  @override
  void handlePointerEvent(PointerEvent event) {}

  @override
  void dispose() {}

  Duration _elapsed = Duration();

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
