import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

class RichTextComponent implements Component {
  late InlineSpan _text;
  late TextAlign _textAlign;
  late TextDirection _textDirection;
  late Offset _offset;
  late Size _size;

  RichTextComponent({
    required InlineSpan text,
    Offset offset = const Offset(0, 0),
    Size size = const Size(0, 0),
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
  })  : _offset = offset,
        _size = size,
        _text = text,
        _textAlign = textAlign,
        _textDirection = textDirection {
    _update();
  }

  @override
  void render(Canvas canvas) {
    _painter.paint(canvas, _offset);
  }

  void set(
      {Offset? offset,
      Size? size,
      TextAlign? textAlign,
      InlineSpan? text,
      TextDirection? textDirection}) {
    bool needsUpdate = false;
    if (offset != null && offset != _offset) {
      _offset = offset;
      needsUpdate = true;
    }
    if (size != null && size != _size) {
      _size = size;
      needsUpdate = true;
    }
    if (textAlign != null && textAlign != _textAlign) {
      _textAlign = textAlign;
      needsUpdate = true;
    }
    if (text != null && text != _text) {
      _text = text;
      needsUpdate = true;
    }
    if (textDirection != null && textDirection != _textDirection) {
      _textDirection = textDirection;
      needsUpdate = true;
    }
    if (needsUpdate) {
      _update();
      _ctx?.requestRender(this);
    }
  }

  late TextPainter _painter;

  void _update() {
    _painter = TextPainter(
        text: _text, textAlign: _textAlign, textDirection: _textDirection);
    _painter.layout(minWidth: _size.width, maxWidth: _size.width);
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
  }
}
