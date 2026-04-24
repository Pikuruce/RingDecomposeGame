import 'package:blindring/main.dart';
import 'package:blindring/src/leftPageHead.dart';
import 'package:flutter/material.dart';

class AnswerUi extends StatefulWidget {
  final GameScreen game;
  const AnswerUi({super.key, required this.game});

  @override
  State<AnswerUi> createState() => _AnswerUiState();
}

class _AnswerUiState extends State<AnswerUi> {
  @override
  Widget build(BuildContext context) {
    if (widget.game.isLoad) {
      return Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: Center(
          child: Row(
            children: List.generate(
              widget.game.ring.radiusList.length,
              (index) => AnswerBox(game: widget.game, index: index),
            ),
          ),
        ),
      );
    } else {
      return Container(
        /*color: const Color.fromARGB(255, 0, 0, 0),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              context.findAncestorStateOfType<SplitScreenState>()?.reload();
            },
            child: Text("Load"),
          ),
        ),*/
      );
    }
  }
}

class AnswerBox extends StatefulWidget {
  final int index;
  final GameScreen game;

  const AnswerBox({super.key, required this.game, required this.index});

  @override
  State<AnswerBox> createState() => _AnswerBoxState();
}

class _AnswerBoxState extends State<AnswerBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black, // 内側
        border: Border.all(
          color: Colors.white, // 枠の色
          width: 2,
        ),
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            widget.game.indexPointer = widget.index;
            context.findAncestorStateOfType<SplitScreenState>()?.reload();
          },
          child: Text(
            "周期: ${widget.game.ring.answerList[widget.index].period}\n振幅: ${widget.game.ring.answerList[widget.index].length}",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
