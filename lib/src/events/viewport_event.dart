import 'package:flutter/material.dart';

class PanData {
  final Offset offset;

  final Offset offsetDelta;

  PanData({required this.offset, required this.offsetDelta});
}

class ScaleData {
  final Offset focalPoint;

  final double scale;

  final double rotation;

  ScaleData(
      {required this.focalPoint, required this.scale, required this.rotation});
}

class TapData {
  final Offset position;

  TapData({required this.position});
}

class ViewportGestureDetector {
  final double threshold;

  final ValueChanged<PanData>? onPan;

  final ValueChanged<ScaleData>? onScale;

  _PinchPanTracker? _panTracker;

  _PinchScaleTracker? _scaleTracker;

  ViewportGestureDetector({this.threshold = 5, this.onPan, this.onScale});

  void scaleStart(ScaleStartDetails details) {
    if (details.pointerCount == 1) {
      if (onPan != null) {
        _panTracker = _PinchPanTracker(details, threshold: 5);
      }
    } else if (details.pointerCount == 2) {
      if (onScale != null) {
        _scaleTracker = _PinchScaleTracker(details);
      }
    }
  }

  void scaleEnd(ScaleEndDetails details) {
    _panTracker = null;
    _scaleTracker = null;
  }

  void scaleUpdate(ScaleUpdateDetails details) {
    if (_panTracker != null) {
      final data = _panTracker!.update(details);
      onPan?.call(data);
    } else if (_scaleTracker != null) {
      final data = _scaleTracker!.update(details);
      onScale?.call(data);
    }
  }
}

class _PinchPanTracker {
  final ScaleStartDetails _start;

  final double threshold;

  Offset get startOffset => _start.focalPoint;

  _PinchPanTracker(this._start, {this.threshold = 5})
      : _prev = _start.focalPoint;

  bool _exceededThreshold = false;

  Offset _prev;

  PanData update(ScaleUpdateDetails details) {
    if (!_exceededThreshold) {
      final diff = details.focalPoint - _start.focalPoint;
      final distance = diff.distance.abs();
      if (distance < threshold) {
        return PanData(offset: Offset.zero, offsetDelta: Offset.zero);
      }
      _exceededThreshold = true;
    }
    final prev = _prev;
    _prev = details.focalPoint;
    return PanData(
        offset: details.focalPoint - _start.focalPoint,
        offsetDelta: details.focalPoint - prev);
  }
}

class _PinchScaleTracker {
  final ScaleStartDetails start;

  _PinchScaleTracker(this.start);

  ScaleData update(ScaleUpdateDetails details) {
    return ScaleData(
        focalPoint: details.focalPoint,
        scale: details.scale,
        rotation: details.rotation);
  }
}