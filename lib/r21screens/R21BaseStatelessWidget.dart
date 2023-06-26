import 'package:flutter/material.dart';

class R21BaseStatelessWidget extends StatelessWidget {
  final String text;

  R21BaseStatelessWidget (this.text) : super();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
