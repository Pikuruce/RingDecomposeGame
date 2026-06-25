import 'dart:math';

import 'package:blindring/src/leftPageFoot.dart';
import 'package:blindring/src/leftPageHead.dart';
import 'package:blindring/src/rightPage.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplitScreen(),
    );
  }
}

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => SplitScreenState();
}

class SplitScreenState extends State<SplitScreen> {
  GameScreen game = GameScreen(level: 3);

  void reloadGame(int level) {
    game = GameScreen(level: level);
    setState(() {});
  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // gameのonLoadが終わってから開始するためのFutureBuilder
    return FutureBuilder(
      future: game.loaded,
      builder: (context, snapchot) {
        // 親ウィジェットから画面のサイズを取得するためのLayoutBuilder
        return LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              //appBar: AppBar(title: const Text("画面分割サンプル")),
              backgroundColor: Colors.black,
              body: Row(
                children: [
                  // 左部：画面の3/4
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.blue[100],
                      child: SplitGameScreen(game: game),
                    ),
                  ),
                  // 右部：画面の1/4
                  Expanded(
                    flex: 1,
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.green[100],
                          child: Center(child: AnswerController(game: game)),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 5,
                            height: constraints.maxHeight,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 54, 98, 244),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// SplitGameScreenウィジェットを定義
class SplitGameScreen extends StatefulWidget {
  final GameScreen game;
  const SplitGameScreen({super.key, required this.game});

  @override
  State<SplitGameScreen> createState() => _SplitGameScreenState();
}

class _SplitGameScreenState extends State<SplitGameScreen> {
  final List<int> _flexValues = [2, 1];
  double _borderY = 600;

  void _updateNewFlexValues(BoxConstraints constraints) {
    setState(() {
      _flexValues[0] = _borderY.toInt();
      _flexValues[1] = (constraints.maxHeight - _borderY).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 親ウィジェットから画面のサイズを取得するためにLayoutBuilderを使用
    return LayoutBuilder(
      builder: (context, constraints) {
        _flexValues[0] = _borderY.toInt();
        _flexValues[1] = (constraints.maxHeight - _borderY).toInt();
        return Stack(
          children: [
            // 画面を上下に分割するためのColumn
            Column(
              children: [
                Expanded(
                  flex: _flexValues[0],
                  child: GameWidget(game: widget.game),
                ),
                Expanded(
                  flex: _flexValues[1],
                  child: AnswerScreen(game: widget.game),
                ),
              ],
            ),
            // ドラッグ可能な境界線
            Positioned(
              top: min(
                constraints.maxHeight,
                max(
                  0,
                  constraints.maxHeight *
                          _flexValues[0] /
                          (_flexValues[0] + _flexValues[1]) -
                      2.5,
                ),
              ),
              left: 0,
              right: 0,
              child: GestureDetector(
                onTapDown: (details) {
                  setState(() {
                    _borderY = min(
                      constraints.maxHeight,
                      max(
                        0,
                        constraints.maxHeight *
                            _flexValues[0] /
                            (_flexValues[0] + _flexValues[1]),
                      ),
                    );
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _borderY += details.delta.dy;
                    _updateNewFlexValues(constraints);
                  });
                },
                child: Container(
                  height: 5,
                  color: const Color.fromARGB(255, 54, 98, 244),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
