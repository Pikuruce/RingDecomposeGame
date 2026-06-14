import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:blindring/utils/logger.dart';

// 円を表すためのクラス
class Radius {
  int period;
  int length;
  double phase;
  Radius(this.period, this.length, this.phase);

  Vector2 getValue(double time) {
    double t = (time - phase) / period * pi * 2;
    return Vector2(cos(t), sin(t)) * length.toDouble();
  }

  void reDefine(int period, int length, double phase) {
    this.period = period;
    this.length = length;
    this.phase = phase;
  }

  (String, int) getInfo() {
    return ("${(phase % period)}-$period", length);
  }

  String getInfoToString() {
    return "period: $period, length: $length, phase: $phase";
  }
}

// 円の組み合わせを表すためのクラス
class BlindRing {
  List<Radius> radiusList = [];
  List<Radius> answerList = [];
  double rLcm = 0.0;
  BlindRing();

  void addRadius(int period, int length, double phase) {
    radiusList.add(Radius(period, length, phase));
  }

  void addAnswer(int period, int length, double phase) {
    answerList.add(Radius(period, length, phase));
  }

  Vector2 getValue(double time) {
    Vector2 result = Vector2.zero();
    for (var radius in radiusList) {
      result += radius.getValue(time);
    }
    return result;
  }

  Vector2 getAnswer(double time) {
    Vector2 result = Vector2.zero();
    for (var radius in answerList) {
      result += radius.getValue(time);
    }
    return result;
  }

  void reDefine(int index, int period, int length, double phase) {
    if (index < answerList.length) {
      answerList[index].reDefine(period, length, phase);
    }
  }

  void radiusLcm() {
    double lcmValue = 1;
    for (var radius in radiusList) {
      lcmValue = lcm(lcmValue, radius.period.round().toDouble());
    }
    rLcm = lcmValue;
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

  bool isClear() {
    Map<String, int> ringInfo = {};
    for (Radius el in radiusList) {
      var info = el.getInfo();
      ringInfo.update(
        info.$1,
        (existingValue) => existingValue + info.$2,
        ifAbsent: () => info.$2,
      );
    }
    for (Radius el in answerList) {
      var info = el.getInfo();
      ringInfo.update(
        info.$1,
        (existingValue) => existingValue - info.$2,
        ifAbsent: () => info.$2,
      );
    }
    int total = ringInfo.values.fold(0, (sum, value) => sum + value);
    return total == 0;
  }

  void cheat() {
    AppLogger logger = AppLogger();
    for (var (i, el) in radiusList.indexed) {
      logger.i("index: $i, information: ${el.getInfoToString()}");
    }
  }
}

// 円の軌道を描画するためのクラス
class TrailComponent extends Component {
  final Path path = Path();
  Vector2? lastPoint;
  double length = 0.0;
  final Color customColor;

  TrailComponent({required this.customColor});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = customColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);
  }

  void addPoint(Vector2 point) {
    if (lastPoint == null) {
      path.moveTo(point.x, point.y);
    } else {
      path.moveTo(lastPoint!.x, lastPoint!.y);
      path.lineTo(point.x, point.y);
    }
    if (lastPoint != null) {
      length += (point - lastPoint!).length;
    }
    lastPoint = point;
  }

  void clear() {
    path.reset();
    length = 0.0;
    lastPoint = null;
  }

  void ahead(BlindRing ring) {
    clear();
    for (
      double t = 0;
      t < ring.lcm(ring.rLcm, ring.answerLcm()) + 0.1;
      t += 0.1
    ) {
      addPoint(ring.getValue(t) - ring.getAnswer(t));
    }
  }

  void aheadUseTime(BlindRing ring, double prevT, double nowT) {
    clear();
    for (double t = prevT; t < nowT + 0.1; t += 0.1) {
      addPoint(ring.getValue(t) - ring.getAnswer(t));
    }
  }
}

// ゲームのロジックを管理するクラス
class GameScreen extends FlameGame {
  late int maxPeriod = 64;
  final int maxLength = 100;
  final int level;
  double t = 0;
  double prevt = 0;
  int indexPointer = 0;
  BlindRing ring = BlindRing();
  TrailComponent trail = TrailComponent(customColor: Colors.white);
  CircleComponent pointer = CircleComponent(
    radius: 5,
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFFFF0000),
  );
  CircleComponent origin = CircleComponent(
    radius: 5,
    position: Vector2.zero(),
    anchor: Anchor.center,
    paint: Paint()..color = const Color.fromARGB(255, 0, 38, 255),
  );
  List<CircleComponent> nodes = [];
  TrailComponent nodeTrails = TrailComponent(
    customColor: Color.fromARGB(199, 60, 199, 0),
  );
  TextComponent clearMessage = TextComponent(
    text: "FALL DOWN",
    position: Vector2.zero(),
    size: Vector2.all(1000),
    anchor: Anchor.center,
    textRenderer: TextPaint(
      style: TextStyle(color: Color.fromARGB(255, 67, 67, 67), fontSize: 100),
    ),
    priority: -1,
  );
  bool aheading = false;
  bool clear = false;

  bool isLoad = false;

  void reAhead() {
    if (aheading) {
      trail.ahead(ring);
    } else {
      trail.aheadUseTime(ring, prevt, t);
    }
  }

  void updatePrevt() {
    prevt = t;
  }

  void showAnswers() {
    nodeTrails.clear();
    nodeTrails.addPoint(Vector2.zero());
    Vector2 totalValue = Vector2.zero();
    int ti = 0;
    for (int i = 0; i < ring.answerList.length; i++) {
      if (ring.answerList[i].length > 0) {
        if (nodes.length < ti + 1) {
          CircleComponent node = CircleComponent(
            radius: 2.5,
            anchor: Anchor.center,
            paint: Paint()..color = const Color.fromARGB(200, 155, 39, 176),
          );
          nodes.add(node);
          world.add(node);
        }
        totalValue += ring.answerList[i].getValue(t);
        nodeTrails.addPoint(totalValue);
        nodes[ti].position = totalValue;
        ti++;
      }
    }
  }

  void modeSwitch() {
    if (aheading) {
      trail.clear();
      world.add(pointer);
      world.add(origin);
      updatePrevt();
      if (clear) {
        world.add(nodeTrails);
        for (var node in nodes) {
          world.add(node);
        }
      }
    } else {
      pointer.removeFromParent();
      origin.removeFromParent();
      trail.ahead(ring);
      if (clear) {
        nodeTrails.removeFromParent();
        for (var node in nodes) {
          node.removeFromParent();
        }
      }
    }

    aheading = !aheading;
  }

  GameScreen({required this.level}) {
    maxPeriod = (1 + (60 / level)).toInt();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.center;
    world.add(pointer);
    world.add(trail);
    //debugMode = true;
    Random random = Random();
    List<int> selected = [];
    for (int i = 0; i < level; i++) {
      int period = 0;
      do {
        period = random.nextIntBetween(1, maxPeriod + 1);
      } while (selected.contains(period));
      selected.add(period);
      ring.addRadius(
        period,
        random.nextIntBetween(1, maxLength + 1),
        (random.nextDoubleBetween(0, period.toDouble()) * 10).round() / 10,
      );
      ring.addAnswer(1, 0, 0);
    }
    ring.radiusLcm();
    isLoad = true;
    ring.cheat();
  }

  @override
  void update(double dt) {
    super.update(dt);

    t += dt;
    if (!clear && !aheading) {
      Vector2 value = ring.getValue(t) - ring.getAnswer(t);
      pointer.position = value;
      trail.addPoint(value);
    }
    if (ring.isClear() && aheading && !clear) {
      clear = true;
      world.add(clearMessage);
      world.add(nodeTrails);
    }

    if (clear && !aheading) {
      showAnswers();
      Vector2 value = ring.getAnswer(t);
      pointer.position = value;
      trail.addPoint(value);
    }
  }
}
