import 'package:flutter/material.dart';

class NotificationsResponsePage extends StatefulWidget {
  final String? payload;
  const NotificationsResponsePage({super.key, this.payload});

  @override
  State<NotificationsResponsePage> createState() =>
      _NotificationsResponsePageState();
}

class _NotificationsResponsePageState extends State<NotificationsResponsePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.payload ?? "Null"),
      ),
    );
  }
}
