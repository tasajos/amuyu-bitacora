// lib/screens/home_screen.dart

import 'package:amuyu/screens/daily_log_screen.dart';
import 'package:amuyu/screens/family_tree_screen.dart';
import 'package:amuyu/screens/historical_log_screen.dart';
import 'package:amuyu/widgets/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:amuyu/screens/family_documents_screen.dart';
import 'package:amuyu/screens/maintenance_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amuyu - Bitácora de Vida'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Muestra 2 tarjetas por fila
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          MenuCard(
            title: 'Actividades Diarias',
            icon: Icons.wb_sunny,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DailyLogScreen()),
              );
            },
          ),
          MenuCard(
            title: 'Hechos Históricos',
            icon: Icons.flag,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoricalLogScreen()),
              );
            },
          ),
          MenuCard(
            title: 'Árbol Genealógico',
            icon: Icons.family_restroom,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FamilyTreeScreen()),
              );
            },
          ),

 MenuCard(
            title: 'Documentos Familiares',
            icon: Icons.folder_copy, // Un buen ícono para documentos
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FamilyDocumentsScreen()),
              );
    },
    ),

 MenuCard(
            title: 'Mantenimiento',
            icon: Icons.settings_backup_restore,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
              );
            },
    ),



        ],
      ),
    );
  }
}