import 'package:flutter/material.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/drawer/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pill Reminder"),
      ),
      drawer: const MyDrawer(),
      body: const Center(
        child: Text("data"),
      ),
    );
  }
}
