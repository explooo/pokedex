import 'package:flutter/material.dart';
import 'widgets/home_screen.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return  MaterialApp(
      title: "Pokedex",
      home: home_screen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color.fromRGBO(238,21,21,1)
      ),
    );
  }
}
