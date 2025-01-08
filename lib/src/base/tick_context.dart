part of 'widget.dart';

class TickContext {
  Duration _timestamp;
  Duration _dt;

  TickContext({Duration timestamp = Duration.zero, Duration dt = Duration.zero})
      : _timestamp = timestamp,
        _dt = dt;

  void nextTick(Duration timestamp) {
    _dt = timestamp - _timestamp;
    _timestamp = timestamp;
  }

  Duration get timestamp => _timestamp;

  Duration get dt => _dt;
}
