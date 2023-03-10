import 'dart:isolate';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Stream<int> autoCounter() {
  final ReceivePort rp = ReceivePort();
  return Isolate.spawn(_autoCounter, rp.sendPort)
      .asStream()
      .asyncExpand((_) => rp)
      .takeWhile((element) => element is int)
      .cast<int>();
}

void _autoCounter(SendPort sp) async {
  int counter = 1;
  await for (final count in Stream<int>.periodic(
    const Duration(seconds: 1),
    (_) => counter++,
  ).take(100)) {
    sp.send(count);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _counter2 = 0;

  void _incrementCounterNormal() async {
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _counter2 = i;
      });
    }
  }

  void _incrementCounterIsolate() async {
    await for (final count in autoCounter()) {
      setState(() {
        _counter = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Isolate $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 2),
            Text(
              'Normal : $_counter2',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounterNormal();
          _incrementCounterIsolate();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
