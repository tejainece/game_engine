import 'package:game_engine/game_engine.dart';

export 'circle.dart';
export 'ellipse.dart';
export 'hex.dart';
export 'rect.dart';

abstract class ShapeComponent implements Component, PositionedComponent, CanHitTest {}
