import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Radius {
  int period;
  int length;
  Radius(this.period, this.length);

  Vector2 getValue(double time, double start) {
    double t = (time - start) / period * pi * 2;
    return Vector2(cos(t), sin(t)) * length.toDouble();
  }

  void reDefine(int period, int length) {
    this.period = period;
    this.length = length;
  }
}

class BlindRing {
  List<Radius> radiusList = [];
  List<Radius> answerList = [];
  BlindRing();

  void addRadius(int period, int length) {
    radiusList.add(Radius(period, length));
  }

  void addAnswer(int period, int length) {
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

  void reDefine(int index, int period, int length) {
    if (index < answerList.length) {
      answerList[index].reDefine(period, length);
    }
  }

  double radiusLcm() {
    double lcmValue = 1;
    for (var radius in radiusList) {
      lcmValue = lcm(lcmValue, radius.period.round().toDouble());
    }
    return lcmValue;
  }

  double answerLcm() {
    double lcmValue = 1;
    for (var answer in answerList) {
      lcmValue = lcm(lcmValue, answer.period.round().toDouble());
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
    for (
      double t = 0;
      t < ring.lcm(ring.radiusLcm(), ring.answerLcm()) + 0.1;
      t += 0.1
    ) {
      addPoint(ring.getValue(t, 0) - ring.getAnswer(t, 0));
    }
  }
}

class GameScreen extends FlameGame {
  final int maxPeriod = 20;
  final int maxLength = 100;
  final int level;
  double t = 0;
  int indexPointer = 0;
  BlindRing ring = BlindRing();
  TrailComponent trail = TrailComponent();
  CircleComponent pointer = CircleComponent(
    radius: 5,
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFFFF0000),
  );
  bool aheading = true;

  bool isLoad = false;

  void reAhead() {
    if (aheading) {
      trail.clear();
      trail.ahead(ring);
    }
  }

  void modeSwitch() {
    if (aheading) {
      trail.clear();
    } else {
      trail.clear();
      trail.ahead(ring);
    }

    aheading = !aheading;
  }

  GameScreen({required this.level});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.center;
    world.add(pointer);
    world.add(trail);
    debugMode = true;
    Random random = Random();
    for (int i = 0; i < level; i++) {
      ring.addRadius(
        random.nextIntBetween(1, 20),
        random.nextIntBetween(1, 100),
      );
      ring.addAnswer(1, 0);
    }
    trail.clear();
    trail.ahead(ring);
    isLoad = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    t += dt;
    Vector2 value = ring.getValue(t, 0) - ring.getAnswer(t, 0);
    pointer.position = value;
    if (!aheading) trail.addPoint(value);
  }
}
