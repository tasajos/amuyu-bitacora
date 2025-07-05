// lib/screens/family_tree_screen.dart
import 'package:flutter/material.dart';

class FamilyTreeScreen extends StatelessWidget {
  const FamilyTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Árbol Genealógico'),
      ),
      body: const Center(
        child: Text('Aquí se gestionará el árbol genealógico y la descendencia.'),
      ),
    );
  }
}