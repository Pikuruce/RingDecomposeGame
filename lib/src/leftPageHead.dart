import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';

class Radius {
  double period;
  double length;
  Radius(this.period, this.length);

  Vector2 getValue(double time, double start) {
    double t = (time - start) / period * pi * 2;
    return Vector2(cos(t), sin(t)) * length;
  }

  void reDefine(double period, double length) {
    this.period = period;
    this.length = length;
  }
}

class BlindRing {
  List<Radius> radiusList = [];
  List<Radius> answerList = [];
  BlindRing();

  void addRadius(double period, double length) {
    radiusList.add(Radius(period, length));
  }

  void addAnswer(double period, double length) {
    answerList.add(Radius(period, length));
  }

  Vector2 getValue(double time, double start) {
    Vector2 result = Vector2.zero();
    for (var radius in radiusList) {
      result += radius.getValue(time, start);
    }
    return result;
  }

  Vector2 getAnswer(double time, double start) {
    Vector2 result = Vector2.zero();
    for (var radius in answerList) {
      result += radius.getValue(time, start);
    }
    return result;
  }

  void reDefine(int index, double period, double length) {
    if (index < answerList.length) {
      answerList[index].reDefine(period, length);
    }
  }

  double radiusLcm() {
    double lcmValue = 1;
    for (var radius in radiusList) {
      lcmValue = lcm(lcmValue, radius.period);
    }
    return lcmValue;
  }

  double lcm(double a, double b) {
    return a * b / gcd(a, b);
  }

  double gcd(double a, double b) {
    if (b == 0) {
      return a;
    }
    return gcd(b, a % b);
  }
}

class TrailComponent extends Component {
  final Path path = Path();
  Vector2? lastPoint;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);
  }

  void addPoint(Vector2 point) {
    if (lastPoint == null) {
      path.moveTo(point.x, point.y);
    } else {
      path.lineTo(point.x, point.y);
    }
    lastPoint = point;
  }

  void clear() {
    path.reset();
    lastPoint = null;
  }

  void ahead(BlindRing ring) {
    for (double t = 0; t < ring.radiusLcm() + 0.1; t += 0.1) {
      addPoint(ring.getValue(t, 0));
    }
  }
}

class GameScreen extends FlameGame {
  double t = 0;
  int indexPointer = 0;
  BlindRing ring = BlindRing();
  TrailComponent trail = TrailComponent();
  CircleComponent pointer = CircleComponent(
    radius: 5,
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFFFF0000),
  );

  bool isLoad = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.center;
    world.add(pointer);
    world.add(trail);
    debugMode = true;
    Random random = Random();
    for (int i = 0; i < 3; i++) {
      ring.addRadius(
        random.nextIntBetween(4, 12).toDouble(),
        random.nextIntBetween(10, 70).toDouble(),
      );
      ring.addAnswer(1, 0);
    }
    trail.ahead(ring);
    isLoad = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    t += dt;
    Vector2 value = ring.getValue(t, 0);
    pointer.position = value;
    //trail.addPoint(value);
  }
}
