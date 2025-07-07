// lib/screens/home_screen.dart

import 'package:amuyu/screens/daily_log_screen.dart';
import 'package:amuyu/screens/family_documents_screen.dart';
import 'package:amuyu/screens/family_tree_screen.dart';
import 'package:amuyu/screens/historical_log_screen.dart';
import 'package:amuyu/screens/maintenance_screen.dart';
import 'package:amuyu/widgets/menu_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amuyu - Bitácora de Vida'),
      ),
      // El body ahora es SÓLO la cuadrícula de tarjetas.
      body: GridView.count(
        crossAxisCount: 2,
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
            icon: Icons.folder_copy,
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
      // --- CORRECCIÓN DEFINITIVA: Usamos la propiedad 'bottomNavigationBar' ---
      bottomNavigationBar: Container(
        // Este padding le da espacio por debajo para que "suba"
        padding: const EdgeInsets.only(bottom: 40, top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Para que la columna no ocupe toda la pantalla
          children: [
            // 1. La imagen arriba
            Image.asset(
              'assets/logo/chlogotrans.png',
              height: 30,
            ),
            const SizedBox(height: 8),
            // 2. El texto abajo
            Text(
              'Desarrollado por Chakuy',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
