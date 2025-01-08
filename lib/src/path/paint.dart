import 'package:flutter/material.dart';

abstract class ToPaint {}

class Stroke implements ToPaint {
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double strokeMiterLimit;

  const Stroke.none() : this(color: Colors.transparent);

  const Stroke(
      {this.color = Colors.black,
        this.strokeWidth = 1,
        this.strokeCap = StrokeCap.butt,
        this.strokeJoin = StrokeJoin.miter,
        this.strokeMiterLimit = 4});

  @override
  bool operator ==(other) =>
      other is Stroke &&
          color == other.color &&
          strokeWidth == other.strokeWidth &&
          strokeCap == other.strokeCap &&
          strokeJoin == other.strokeJoin &&
          strokeMiterLimit == strokeMiterLimit;

  @override
  int get hashCode =>
      Object.hash(color, strokeWidth, strokeCap, strokeJoin, strokeMiterLimit);
}

extension StrokeExt on Stroke {
  Paint get paint => Paint()
    ..style = PaintingStyle.stroke
    ..color = color
    ..strokeWidth = strokeWidth
    ..strokeCap = strokeCap
    ..strokeJoin = strokeJoin
    ..strokeMiterLimit = strokeMiterLimit;
}

class Fill implements ToPaint {
  final Color color;
  final BlendMode blendMode;

  const Fill({this.color = Colors.black, this.blendMode = BlendMode.srcOver});

  @override
  bool operator ==(other) =>
      other is Fill && color == other.color && blendMode == other.blendMode;

  @override
  int get hashCode => Object.hash(color, blendMode);
}

extension FillExt on Fill {
  Paint get paint => Paint()
    ..style = PaintingStyle.fill
    ..color = color
    ..blendMode = blendMode;
}

extension ToPaintExt on ToPaint {
  Paint get paint {
    if (this is Stroke) {
      return (this as Stroke).paint;
    } else if (this is Fill) {
      return (this as Fill).paint;
    }
    throw UnsupportedError('Unsupported paint type $runtimeType');
  }
}

class Argument<T> {
  final T? value;

  const Argument(this.value);
}

extension ObjectArgumentExt<T> on T {
  Argument<T> get asArg => Argument<T>(this);
}