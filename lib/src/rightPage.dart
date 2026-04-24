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
              GameSlider(
                slider: Slider(
                  value: widget
                      .game
                      .ring
                      .answerList[widget.game.indexPointer]
                      .period,
                  min: 1,
                  max: 20,
                  onChanged: (value) {
                    setState(() {
                      widget.game.ring.reDefine(
                        widget.game.indexPointer,
                        value.round().toDouble(),
                        widget
                            .game
                            .ring
                            .answerList[widget.game.indexPointer]
                            .length,
                      );
                      context
                          .findAncestorStateOfType<SplitScreenState>()
                          ?.reload();
                    });
                  },
                ),
                itemName: "周期",
              ),
              GameSlider(
                slider: Slider(
                  value: widget
                      .game
                      .ring
                      .answerList[widget.game.indexPointer]
                      .length,
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      widget.game.ring.reDefine(
                        widget.game.indexPointer,
                        widget
                            .game
                            .ring
                            .answerList[widget.game.indexPointer]
                            .period,
                        value.round().toDouble(),
                      );
                      context
                          .findAncestorStateOfType<SplitScreenState>()
                          ?.reload();
                    });
                  },
                ),
                itemName: "振幅",
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
            context.findAncestorStateOfType<SplitScreenState>()?.reload();
          },
          child: Text("Load"),
        ),
      ),
    );
  }
}

class GameSlider extends StatefulWidget {
  final Slider slider;
  final String itemName;
  const GameSlider({super.key, required this.slider, required this.itemName});

  @override
  State<GameSlider> createState() => _GameSliderState();
}

class _GameSliderState extends State<GameSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.slider,
        Text(
          "${widget.itemName}: ${widget.slider.value}",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
