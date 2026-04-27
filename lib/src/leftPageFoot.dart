import 'package:blindring/main.dart';
import 'package:blindring/src/leftPageHead.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class AnswerUi extends StatefulWidget {
  final GameScreen game;
  const AnswerUi({super.key, required this.game});

  @override
  State<AnswerUi> createState() => _AnswerUiState();
}

class _AnswerUiState extends State<AnswerUi>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            setState(() {}); // 毎フレーム更新
          })
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.game.loaded,
      builder: (context, snapshot) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth,
              height: 200,
              color: const Color.fromARGB(255, 0, 0, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Center(
                    child: Row(
                      children: List.generate(
                        widget.game.ring.radiusList.length,
                        (index) => AnswerBox(game: widget.game, index: index),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AnswerBox extends StatefulWidget {
  final int index;
  final GameScreen game;

  const AnswerBox({super.key, required this.game, required this.index});

  @override
  State<AnswerBox> createState() => AnswerBoxState();
}

class AnswerBoxState extends State<AnswerBox> {
  double boxSize = 200;
  double circleSize = 5;
  void reSet() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Vector2 value = widget.game.ring.answerList[widget.index].getValue(
      widget.game.t,
      0,
    );
    return GestureDetector(
      onTap: () {
        widget.game.indexPointer = widget.index;
        //widget.game.updatePrevt();
        context.findAncestorStateOfType<SplitScreenState>()?.reload();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: Colors.black, // 内側
              border: Border.all(
                color: Colors.white, // 枠の色
                width: 2,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: boxSize,
                height: boxSize,
                child: Stack(
                  children: [
                    Positioned(
                      top: (boxSize - circleSize) / 2,
                      left: (boxSize - circleSize) / 2,
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: (boxSize - circleSize) / 2 + value.y,
                      left: (boxSize - circleSize) / 2 + value.x,
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: LinePainter(
                        Offset(boxSize / 2, boxSize / 2),
                        Offset(boxSize / 2 + value.x, boxSize / 2 + value.y),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            "周期: ${widget.game.ring.answerList[widget.index].period}\n振幅: ${widget.game.ring.answerList[widget.index].length}",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) => true;
}
