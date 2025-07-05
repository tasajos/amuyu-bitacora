// lib/screens/historical_log_screen.dart
import 'package:flutter/material.dart';

class HistoricalLogScreen extends StatelessWidget {
  const HistoricalLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hechos Históricos'),
      ),
      body: const Center(
        child: Text('Aquí se registrarán los hechos históricos importantes.'),
      ),
    );
  }
}