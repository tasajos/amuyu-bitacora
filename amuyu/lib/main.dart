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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define una paleta de colores cohesiva
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal.shade700,
          secondary: Colors.amber.shade600,
          // Se elimina la propiedad 'background' que estaba obsoleta.
          surface: Colors.white,
        ),
        useMaterial3: true, // Habilita el diseño más moderno de Material 3
        
        // Estilo de las tarjetas
        // CORRECCIÓN: Se usa CardThemeData en lugar de CardTheme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Estilo de los AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}