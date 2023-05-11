import 'package:flutter/material.dart';

class Testable extends StatelessWidget {
  const Testable({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: SafeArea(child: child),
      ),
    );
  }
}
