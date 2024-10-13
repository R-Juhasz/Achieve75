import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('75 Hard Challenge')),
      body: Center(
        child: Text('Progress screen - No database or notification integration.'),
      ),
    );
  }
}
