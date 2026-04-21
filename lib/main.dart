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
              child: Column(
                children: [
                  Expanded(child: Container(color: Colors.green[200])),
                  Expanded(child: Container(color: Colors.green[300])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SplitGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[200],
      child: const Center(child: Text("ゲームエリア")),
    );
  }
}
