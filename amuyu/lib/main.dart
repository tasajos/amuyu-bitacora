// lib/main.dart

import 'package:amuyu/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AmuyuApp());
}

class AmuyuApp extends StatelessWidget {
  const AmuyuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amuyu',
      debugShowCheckedModeBanner: false, // Opcional: quita la cinta de "Debug"
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // Nuestra pantalla principal
    );
  }
}