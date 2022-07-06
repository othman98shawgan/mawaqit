import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.95,
          width: MediaQuery.of(context).size.width * 0.95,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              InkWell(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                onLongPress: _resetCounter,
                onTap: _incrementCounter,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(200.0)),
                    color: Colors.black54,
                  ),
                  child: Center(
                    child: Text('$_counter', style: Theme.of(context).textTheme.headline1),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
