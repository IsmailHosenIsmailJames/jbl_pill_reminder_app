import 'package:flutter/material.dart';

class TakeMedicinePage extends StatefulWidget {
  final String? title;
  const TakeMedicinePage({super.key, this.title});

  @override
  State<TakeMedicinePage> createState() => _TakeMedicinePageState();
}

class _TakeMedicinePageState extends State<TakeMedicinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Take Medicine"),
      ),
      body: Center(
        child: Text(widget.title ?? "Take Medicine"),
      ),
    );
  }
}
