import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

enum AnchorPlacement { start, center, end }

class AnchoredTextComponent implements Component {
  late String _text;
  late TextStyle _style;
  late Alignment _anchorPlacement;
  late Offset _anchor;

  // TODO late Size _size;

  AnchoredTextComponent({
    required String text,
    TextStyle style = const TextStyle(color: Colors.black),
    Offset anchor = const Offset(0, 0),
    Alignment anchorPlacement = Alignment.bottomCenter,
  })  : _text = text,
        _style = style,
        _anchor = anchor,
        _anchorPlacement = anchorPlacement {
    _update();
  }

  @override
  void render(Canvas canvas) {
    _painter.paint(canvas, _offset);
  }

  void set(
      {String? text,
      TextStyle? style,
      Offset? anchor,
      Alignment? anchorPlacement}) {
    bool needsUpdate = false;
    if (text != null && text != _text) {
      _text = text;
      needsUpdate = true;
    }
    if (style != null && style != _style) {
      _style = style;
      needsUpdate = true;
    }
    if (anchor != null && _anchor != anchor) {
      _anchor = anchor;
      needsUpdate = true;
    }
    if (anchorPlacement != null && _anchorPlacement != anchorPlacement) {
      _anchorPlacement = anchorPlacement;
      needsUpdate = true;
    }
    if (needsUpdate) {
      _update();
      _ctx?.requestRender(this);
    }
  }

  late TextPainter _painter;

  void _update() {
    final text = TextSpan(text: _text, style: _style);
    _painter = TextPainter(text: text, textDirection: TextDirection.ltr);
    _painter.layout();
    _offset = _anchor - _anchorPlacement.alongSize(_painter.size);
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
  }

  Offset _offset = const Offset(0, 0);

  Offset get anchor => _anchor;
}
