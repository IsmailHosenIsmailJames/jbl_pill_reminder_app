import "package:flutter/material.dart";

class RoutesNotFound extends StatelessWidget {
  final String routeName;
  const RoutesNotFound({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Route not found at $routeName"),
      ),
    );
  }
}
