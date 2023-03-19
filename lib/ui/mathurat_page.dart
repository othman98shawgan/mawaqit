import 'dart:convert';
import 'dart:core';

import 'package:alfajr/models/mathurat.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class MathuratPage extends StatefulWidget {
  const MathuratPage({Key? key}) : super(key: key);

  @override
  State<MathuratPage> createState() => _MathuratPageState();
}

List<MathuratModel> mathuratList = [];

class _MathuratPageState extends State<MathuratPage> {
  List<MathuratModel> items = [];

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('lib/data/mathurat.json');
    final data = await json.decode(response);
    mathuratList = List<MathuratModel>.from(data.map((x) => MathuratModel.fromJson(x)));
    setState(() {
      items = List.from(mathuratList);
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  callback(String text) {
    setState(() {
      items.removeWhere((item) => item.text == text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ValueChanged<int> update;

    var list = ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        return Column(
          children: [
            _buildRow(items[i].text, items[i].count, callback),
            const Divider(
              thickness: 1,
            )
          ],
        );
      },
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.light_mode)),
              Tab(icon: Icon(Icons.nightlight_round)),
            ],
          ),
          title: const Text('Tabs Demo'),
        ),
        body: TabBarView(
          children: [
            list,
            Center(
              child: Text('Night'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String cardText, int count, Function callback) {
    return MathuratCard(cardText: cardText, count: count, removeRow: callback);
  }
}

class MathuratCard extends StatefulWidget {
  MathuratCard({Key? key, required this.cardText, required this.count, required this.removeRow})
      : super(key: key);

  final String cardText;
  int count;
  Function removeRow;

  @override
  State<MathuratCard> createState() => _MathuratCardState();
}

class _MathuratCardState extends State<MathuratCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(180, 0, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      // color: Colors.black54,
      child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
            right: 16,
            bottom: 8,
          ),
          child: Column(
            children: [
              Text(
                widget.cardText,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 24,
                ),
                locale: const Locale('ar', 'AE'),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
              FloatingActionButton.extended(
                heroTag: widget.cardText,
                label: Text("Count: ${widget.count}"),
                onPressed: () {
                  setState(() {
                    widget.count--;
                    if (widget.count == 0) {
                      widget.removeRow(widget.cardText);
                    }
                  });
                },
              )
            ],
          )),
    );
  }
}
