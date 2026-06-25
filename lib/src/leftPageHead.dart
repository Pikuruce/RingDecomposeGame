import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:blindring/utils/logger.dart';

// 円を表すためのクラス
class Wave {
  int period;
  int length;
  double phase;
  Wave(this.period, this.length, this.phase);

  // その時間時点でのベクトル値を取得
  Vector2 getValue(double time) {
    double t = (time - phase) / period * pi * 2;
    return Vector2(cos(t), sin(t)) * length.toDouble();
  }

  // 周期・振幅・位相の変更をする
  void reDefine(int period, int length, double phase) {
    this.period = period;
    this.length = length;
    this.phase = phase;
  }

  // 答え合わせに使うために文字列で位相と周期・整数で振幅を返す
  (String, int) getInfo() {
    return ("${(phase % period)}-$period", length);
  }

  // すべての情報を文字列で返す
  String getInfoToString() {
    return "period: $period, length: $length, phase: $phase";
  }
}

// 合成した波を表すためのクラス
class WaveBox {
  List<Wave> circleList = [];
  List<Wave> answerList = [];
  double wLcm = 1.0;
  double awLcm = 1.0;
  WaveBox();

  // 問題になる波を追加
  void addWave(int period, int length, double phase) {
    circleList.add(Wave(period, length, phase));
  }

  // 答えになる波を追加
  void addAnswerWave(int period, int length, double phase) {
    answerList.add(Wave(period, length, phase));
  }

  // 問題の波のベクトル値の合成
  Vector2 getValue(double time) {
    Vector2 result = Vector2.zero();
    for (var circle in circleList) {
      result += circle.getValue(time);
    }
    return result;
  }

  // 答えの波のベクトル値の合成
  Vector2 getAnswerValue(double time) {
    Vector2 result = Vector2.zero();
    for (var circle in answerList) {
      result += circle.getValue(time);
    }
    return result;
  }

  // 指定したインデックスの波を編集
  void reDefine(int index, int period, int length, double phase) {
    if (index < answerList.length) {
      answerList[index].reDefine(period, length, phase);
      answerLcm();
    }
  }

  // 問題の波の周期の最小公倍数を取得
  void waveLcm() {
    double lcmValue = 1;
    for (var circle in circleList) {
      lcmValue = lcm(lcmValue, circle.period.round().toDouble());
    }
    wLcm = lcmValue;
  }

  // 答えの波の周期の最小公倍数を取得
  void answerLcm() {
    double lcmValue = 1;
    for (var answer in answerList) {
      lcmValue = lcm(lcmValue, answer.period.round().toDouble());
    }
    awLcm = lcmValue;
  }

  // 最小公倍数を取得
  double lcm(double a, double b) {
    return a * b / gcd(a, b);
  }

  // 最大公約数を取得
  double gcd(double a, double b) {
    if (b == 0) {
      return a;
    }
    return gcd(b, a % b);
  }

  // クリア判定
  bool isClear() {
    Map<String, int> ringInfo = {};
    for (Wave el in circleList) {
      var info = el.getInfo();
      ringInfo.update(
        info.$1,
        (existingValue) => existingValue + info.$2,
        ifAbsent: () => info.$2,
      );
    }
    for (Wave el in answerList) {
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

  // loggerに答えを表示(デバッグ用)
  void cheat() {
    AppLogger logger = AppLogger();
    for (var (i, el) in circleList.indexed) {
      logger.i("index: $i, information: ${el.getInfoToString()}");
    }
  }
}

// 円の軌道を描画するためのクラス
class TrailComponent extends Component {
  final Path path = Path();
  Vector2? lastPoint;
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

  // 点を打って線を引く
  void addPoint(Vector2 point) {
    if (lastPoint == null) {
      path.moveTo(point.x, point.y);
    } else {
      path.moveTo(lastPoint!.x, lastPoint!.y);
      path.lineTo(point.x, point.y);
    }
    lastPoint = point;
  }

  // 点をリセット
  void clear() {
    path.reset();
    lastPoint = null;
  }

  // 合成した波が一周するまで線を引く
  void ahead(WaveBox ring) {
    clear();
    for (double t = 0; t < ring.lcm(ring.wLcm, ring.awLcm) + 0.1; t += 0.1) {
      addPoint(ring.getValue(t) - ring.getAnswerValue(t));
    }
  }

  // 合成した波の一部の線を引く
  void aheadUseTime(WaveBox ring, double prevT, double nowT) {
    clear();
    for (double t = prevT; t < nowT + 0.1; t += 0.1) {
      addPoint(ring.getValue(t) - ring.getAnswerValue(t));
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
  WaveBox ring = WaveBox();
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
  bool summing = false;
  bool clear = false;

  bool isLoad = false;

  // 合成した波の線を引く命令を出す
  void reAhead() {
    if (summing) {
      trail.ahead(ring);
    } else {
      trail.aheadUseTime(ring, prevt, t);
    }
  }

  // 線を引き始める時間を記憶する
  void updatePrevt() {
    prevt = t;
  }

  // 合成した波の様子がわかるように分解した波をつないで再現
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

  // 合成した波の線を一括表示をするかどうかの切り替え
  void modeSwitch() {
    if (summing) {
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

    summing = !summing;
  }

  // コンストラクタ
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
      ring.addWave(
        period,
        random.nextIntBetween(1, maxLength + 1),
        (random.nextDoubleBetween(0, period.toDouble()) * 10).round() / 10,
      );
      ring.addAnswerWave(1, 0, 0);
    }
    ring.waveLcm();
    isLoad = true;
    ring.cheat();
  }

  @override
  void update(double dt) {
    super.update(dt);

    t += dt;
    if (!clear && !summing) {
      Vector2 value = ring.getValue(t) - ring.getAnswerValue(t);
      pointer.position = value;
      trail.addPoint(value);
    }
    if (ring.isClear() && summing && !clear) {
      clear = true;
      world.add(clearMessage);
      world.add(nodeTrails);
    }

    if (clear && !summing) {
      showAnswers();
      Vector2 value = ring.getAnswerValue(t);
      pointer.position = value;
      trail.addPoint(value);
    }
  }
}
