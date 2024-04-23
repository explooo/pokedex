import 'package:flutter/material.dart';
import 'widgets/home_screen.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Pokedex",
      home: home_screen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
