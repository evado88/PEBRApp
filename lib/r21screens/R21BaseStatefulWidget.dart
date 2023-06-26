import 'package:flutter/material.dart';

class R21BaseStatefulWidget extends StatefulWidget {
  final String title;

  const R21BaseStatefulWidget(
    this.title,
  );

  @override
  State<R21BaseStatefulWidget> createState() => _R21BaseStatefulWidgetState();
}

class _R21BaseStatefulWidgetState extends State<R21BaseStatefulWidget> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            'current is ' + counter.toString(),
            textDirection: TextDirection.ltr,
          ),
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                counter++;
              });
            },
            child: const Text('Add One'),
          ),
        ],
      ),
    );
  }
}
