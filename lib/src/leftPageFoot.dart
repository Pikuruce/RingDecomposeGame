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
    return Container(
      color: const Color.fromARGB(255, 0, 0, 0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnswerBox(
              index: 0,
              onTap: (int index) {
                setState(() {
                  widget.game.indexPointer = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnswerBox extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const AnswerBox({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black, // 内側
          border: Border.all(
            color: Colors.white, // 枠の色
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                "Answer ${index + 1}",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
