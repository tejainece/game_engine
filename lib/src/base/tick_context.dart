part of 'widget.dart';

class TickContext {
  Duration _timestamp;
  Duration _dt;
  bool _needsRender = false;

  bool get needsRender => _needsRender;

  TickContext({Duration timestamp = Duration.zero, Duration dt = Duration.zero})
      : _timestamp = timestamp,
        _dt = dt;

  void nextTick(Duration timestamp) {
    _dt = timestamp - _timestamp;
    _timestamp = timestamp;
    _needsRender = false;
  }

  void requestRender() {
    _needsRender = true;
  }

  Duration get timestamp => _timestamp;

  Duration get dt => _dt;
}
