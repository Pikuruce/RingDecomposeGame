import 'dart:math';

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

class SplitScreen extends StatelessWidget {
  const SplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("画面分割サンプル")),
      body: Row(
        children: [
          // 左部：画面の2/3
          Expanded(
            flex: 3,
            child: Container(color: Colors.blue[100], child: SplitGameScreen()),
          ),
          // 右部：画面の1/3
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.green[100],
              child: Center(child: Text("右側のUIエリア")),
            ),
          ),
        ],
      ),
    );
  }
}

class SplitGameScreen extends StatefulWidget {
  const SplitGameScreen({super.key});

  @override
  State<SplitGameScreen> createState() => _SplitGameScreenState();
}

class _SplitGameScreenState extends State<SplitGameScreen> {
  final List<int> _flexValues = [2, 1];
  double _borderY = 200;

  void _updateNewFlexValues(BoxConstraints constraints) {
    setState(() {
      _flexValues[0] = _borderY.toInt();
      _flexValues[1] = (constraints.maxHeight - _borderY).toInt();
    });
  }

  @override
  void initState() {
    super.initState();
    // 初期のflex値を設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final constraints =
          context.findRenderObject()!.constraints as BoxConstraints;
      _updateNewFlexValues(constraints);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 画面を上下に分割するためのColumn
            Column(
              children: [
                Expanded(
                  flex: _flexValues[0],
                  child: Container(color: Colors.blue[200]),
                ),
                Expanded(
                  flex: _flexValues[1],
                  child: Container(color: Colors.blue[300]),
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
                child: Container(height: 5, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
