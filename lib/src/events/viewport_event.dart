import 'package:flutter/material.dart';

class PanData {
  final Offset offset;

  final Offset offsetDelta;

  PanData({required this.offset, required this.offsetDelta});
}

class ScaleData {
  final Offset focalPoint;

  final double previousScale;

  final double scale;

  final double previousRotation;

  final double rotation;

  ScaleData(
      {required this.focalPoint,
      required this.previousScale,
      required this.scale,
      required this.previousRotation,
      required this.rotation});
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

  _PinchScaleTracker(this.start)
      : _previousScale = 1.0,
        _previousRotation = 0;

  double _previousScale;

  double _previousRotation;

  ScaleData update(ScaleUpdateDetails details) {
    final ret = ScaleData(
        focalPoint: details.focalPoint,
        previousScale: 1/_previousScale,
        scale: details.scale,
        previousRotation: -_previousRotation, // TODO clamping
        rotation: details.rotation);
    _previousScale = details.scale;
    _previousRotation = details.rotation;
    return ret;
  }
}
