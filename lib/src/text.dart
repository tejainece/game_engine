import 'package:flutter/cupertino.dart';
import 'package:game_engine/game_engine.dart';

class TextComponent implements Component {
  late InlineSpan _text;
  late TextAlign _textAlign;
  late Offset _offset;
  late Size _size;

  TextComponent(
      {required InlineSpan text,
      Offset offset = const Offset(0, 0),
      Size size = const Size(0, 0),
      TextAlign textAlign = TextAlign.start}) {
    _offset = offset;
    _size = size;
    _text = text;
    _textAlign = textAlign;
    _update();
  }

  @override
  void handlePointerEvent(PointerEvent event) {
    // TODO: implement handlePointerEvent
  }

  @override
  void render(Canvas canvas) {
    _painter.paint(canvas, _offset);
  }

  @override
  void tick(TickCtx ctx) {
    if (_dirty) {
      _dirty = false;
      ctx.shouldRender();
    }
  }

  InlineSpan get text => _text;
  set text(InlineSpan value) {
    if (value == _text) return;
    _text = value;
    _update();
  }

  TextAlign get textAlign => _textAlign;
  set textAlign(TextAlign value) {
    if (value == _textAlign) return;
    _textAlign = value;
    _update();
  }

  Offset get offset => _offset;
  set offset(Offset value) {
    if (_offset == value) return;
    _offset = value;
    _dirty = true;
  }

  Size get size => _size;
  set size(Size value) {
    if (_size == value) return;
    _size = value;
    _update();
  }

  void set(
      {Offset? offset, Size? size, TextAlign? textAlign, InlineSpan? text}) {
    if (offset != null && offset != _offset) {
      _offset = offset;
      _dirty = true;
    }

    bool needsUpdate = false;
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
    if (needsUpdate) {
      _update();
    }
  }

  void _update() {
    _dirty = true;

    _painter = TextPainter(text: _text, textAlign: _textAlign);
    _painter.layout(maxWidth: _size.width);
  }

  late TextPainter _painter;

  bool _dirty = true;
}
