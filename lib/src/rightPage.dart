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
  int level = 3;
  @override
  Widget build(BuildContext context) {
    if (widget.game.isLoad) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: const Color.fromARGB(255, 0, 0, 0),
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: GameSlider(
                      slider: Slider(
                        value: widget
                            .game
                            .ring
                            .answerList[widget.game.indexPointer]
                            .period
                            .toDouble(),
                        min: 1,
                        max: widget.game.maxPeriod.toDouble(),
                        onChanged: (value) {
                          if (!widget.game.clear) {
                            setState(() {
                              widget.game.ring.reDefine(
                                widget.game.indexPointer,
                                value.round(),
                                widget
                                    .game
                                    .ring
                                    .answerList[widget.game.indexPointer]
                                    .length,
                                widget
                                    .game
                                    .ring
                                    .answerList[widget.game.indexPointer]
                                    .phase,
                              );
                              widget.game.reAhead();
                              context
                                  .findAncestorStateOfType<SplitScreenState>()
                                  ?.reload();
                            });
                          }
                        },
                      ),
                      itemName: "周期",
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GameSlider(
                      slider: Slider(
                        value: widget
                            .game
                            .ring
                            .answerList[widget.game.indexPointer]
                            .length
                            .toDouble(),
                        min: 0,
                        max: widget.game.maxLength.toDouble(),
                        onChanged: (value) {
                          if (!widget.game.clear) {
                            setState(() {
                              widget.game.ring.reDefine(
                                widget.game.indexPointer,
                                widget
                                    .game
                                    .ring
                                    .answerList[widget.game.indexPointer]
                                    .period,
                                value.round(),
                                widget
                                    .game
                                    .ring
                                    .answerList[widget.game.indexPointer]
                                    .phase,
                              );
                              widget.game.reAhead();
                              context
                                  .findAncestorStateOfType<SplitScreenState>()
                                  ?.reload();
                            });
                          }
                        },
                      ),
                      itemName: "振幅",
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GameSlider(
                      slider: Slider(
                        value: widget
                            .game
                            .ring
                            .answerList[widget.game.indexPointer]
                            .phase
                            .toDouble(),
                        min: 0,
                        max: widget.game.maxPeriod.toDouble(),
                        onChanged: (value) {
                          if (!widget.game.clear) {
                            setState(() {
                              widget.game.ring.reDefine(
                                widget.game.indexPointer,
                                widget
                                    .game
                                    .ring
                                    .answerList[widget.game.indexPointer]
                                    .period,
                                widget
                                    .game
                                    .ring
                                    .answerList[widget.game.indexPointer]
                                    .length,
                                (value * 10).round() / 10,
                              );
                              widget.game.reAhead();
                              context
                                  .findAncestorStateOfType<SplitScreenState>()
                                  ?.reload();
                            });
                          }
                        },
                      ),
                      itemName: "位相",
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.game.modeSwitch();
                        });
                      },
                      child: Text("全体表示/答え合わせ"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.game.updatePrevt();
                          widget.game.reAhead();
                        });
                      },
                      child: Text("追跡線のリセット"),
                    ),
                  ),
                  Expanded(flex: 5, child: Container()),
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: constraints.maxWidth,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 54, 98, 244),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: GameSlider(
                              slider: Slider(
                                min: 1,
                                max: 5,
                                value: level.toDouble(),
                                onChanged: (value) {
                                  setState(() {
                                    level = value.toInt();
                                  });
                                },
                              ),
                              itemName: "レベル設定",
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                context
                                    .findAncestorStateOfType<SplitScreenState>()
                                    ?.reloadGame(level);
                              },
                              child: Text(
                                "再構築",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
