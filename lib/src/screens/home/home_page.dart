import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/drawer/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pill Reminder"),
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await SharedPrefs.prefs.setString(
                  "timestamp",
                  jsonEncode(
                    {
                      "time": DateTime.now()
                          .add(const Duration(seconds: 20))
                          .millisecondsSinceEpoch,
                      "isShown": false,
                    },
                  ),
                );
                log(DateTime.now()
                    .add(const Duration(seconds: 20))
                    .millisecondsSinceEpoch
                    .toString());
              },
              child: const Text("Local Notifications"),
            ),
            ElevatedButton(
              onPressed: () async {
                await SharedPrefs.prefs.setString(
                  "timestamp",
                  jsonEncode(
                    {
                      "time": DateTime.now()
                          .add(const Duration(seconds: 20))
                          .millisecondsSinceEpoch,
                      "isShown": false,
                    },
                  ),
                );
                log(DateTime.now()
                    .add(const Duration(seconds: 20))
                    .millisecondsSinceEpoch
                    .toString());
              },
              child: const Text("Local Notifications"),
            ),
          ],
        ),
      ),
    );
  }
}
