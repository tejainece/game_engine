import 'package:flutter/material.dart';
import 'package:game_engine/game_engine.dart';

export 'anchored_text_component.dart';
export 'rich_text.dart';

class TextComponent implements Component, SizedPositionedComponent, PositionedComponent {
  late String _text;
  late TextStyle _style;
  late TextAlign _textAlign;
  late TextDirection _textDirection;
  late Offset _offset;
  late Size _size;

  TextComponent({
    required String text,
    Offset offset = const Offset(0, 0),
    Size size = const Size(0, 0),
    TextStyle style = const TextStyle(color: Colors.black),
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
  })  : _offset = offset,
        _size = size,
        _textAlign = textAlign,
        _textDirection = textDirection,
        _text = text,
        _style = style {
    _update();
  }

  @override
  void render(Canvas canvas) {
    _painter.paint(canvas, _offset);
  }

  @override
  void set(
      {Offset? offset,
      Size? size,
      TextAlign? textAlign,
      String? text,
      TextStyle? style,
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
    if (text != null && text != _text) {
      _text = text;
      needsUpdate = true;
    }
    if (textAlign != null && textAlign != _textAlign) {
      _textAlign = textAlign;
      needsUpdate = true;
    }
    if (style != null && style != _style) {
      _style = style;
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
    final text = TextSpan(text: _text, style: _style);
    _painter = TextPainter(
        text: text, textAlign: _textAlign, textDirection: _textDirection);
    _painter.layout(minWidth: _size.width, maxWidth: _size.width);
  }

  ComponentContext? _ctx;

  @override
  void onAttach(ComponentContext ctx) {
    _ctx = ctx;
  }

  @override
  Offset get offset => _offset;

  @override
  Size get size => _size;
}
