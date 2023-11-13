import 'dart:ui';

typedef LERPer<T> = T Function(T a, T b, double t);

class DurTween<T> {
  final Duration startTime;
  final Duration endTime;
  final LERPer<T> lerper;
  final T start;
  final T end;

  DurTween(
      {required this.startTime,
      required this.endTime,
      required this.start,
      required this.end,
      required this.lerper});

  late final duration = endTime - startTime;

  T tween(Duration now) {
    // TODO implement infinite loop, finite loop, alternate
    if (now > endTime) {
      return end;
    } else if (now < startTime) {
      return start;
    }
    final t = (now.inMicroseconds - startTime.inMicroseconds) /
        duration.inMicroseconds;
    return lerper(start, end, t);
  }
}

class DateTween<T> {
  final DateTime startTime;
  final DateTime endTime;
  final LERPer<T> lerper;
  final T start;
  final T end;

  DateTween(
      {required this.startTime,
      required this.endTime,
      required this.start,
      required this.end,
      required this.lerper});

  static DateTween<double> forDouble(
          {required DateTime startTime,
          required DateTime endTime,
          required double start,
          required double end}) =>
      DateTween(
          startTime: startTime,
          endTime: endTime,
          start: start,
          end: end,
          lerper: (a, b, t) => lerpDouble(a, b, t)!);

  late final duration = endTime.difference(startTime);

  T tween(DateTime now) {
    // TODO implement infinite loop, finite loop, alternate
    if (now.isAfter(endTime)) {
      return end;
    } else if (now.isBefore(startTime)) {
      return start;
    }
    final t =
        now.difference(startTime).inMicroseconds / duration.inMicroseconds;
    return lerper(start, end, t);
  }
}
