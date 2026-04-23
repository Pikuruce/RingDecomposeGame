import 'package:blindring/main.dart';
import 'package:blindring/src/leftPageHead.dart';
import 'package:flutter/material.dart';

class AnswerController extends StatefulWidget {
  final GameScreen game;
  const AnswerController({super.key, required this.game});

  @override
  State<AnswerController> createState() => _AnswerControllerState();
}

class _AnswerControllerState extends State<AnswerController> {
  @override
  Widget build(BuildContext context) {
    if (widget.game.isLoad) {
      return Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: Center(
          child: Column(
            children: [
              Slider(
                value: widget
                    .game
                    .ring
                    .answerList[widget.game.indexPointer]
                    .period
                    .toDouble(),
                min: 1,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    widget.game.ring.reDefine(
                      widget.game.indexPointer,
                      value,
                      widget
                          .game
                          .ring
                          .radiusList[widget.game.indexPointer]
                          .length,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      color: const Color.fromARGB(255, 0, 0, 0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            context.findAncestorStateOfType<SplitScreenState>()?.reloadGame();
          },
          child: Text("Load"),
        ),
      ),
    );
  }
}
