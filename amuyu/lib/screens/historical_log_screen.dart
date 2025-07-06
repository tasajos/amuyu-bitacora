// lib/screens/historical_log_screen.dart
import 'package:flutter/material.dart';
import 'package:amuyu/widgets/document_category_card.dart'; // Reutilizamos el card elegante
import 'package:amuyu/screens/add_historical_event_screen.dart'; // Importamos la pantalla del formulario
import 'package:amuyu/screens/historical_event_list_screen.dart';

class HistoricalLogScreen extends StatelessWidget {
  const HistoricalLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de categorías de hechos históricos
    final List<Map<String, dynamic>> eventCategories = [
      {'title': 'Nacimiento de Hijos', 'icon': Icons.child_care, 'startColor': Colors.lightBlue.shade300, 'endColor': Colors.lightBlue.shade600},
      {'title': 'Terminar Estudios', 'icon': Icons.school, 'startColor': Colors.green.shade300, 'endColor': Colors.green.shade600},
      {'title': 'Obtener Certificado', 'icon': Icons.card_membership, 'startColor': Colors.amber.shade400, 'endColor': Colors.amber.shade700},
      {'title': 'Casarse', 'icon': Icons.favorite, 'startColor': Colors.pink.shade200, 'endColor': Colors.pink.shade400},
      {'title': 'Divorciarse', 'icon': Icons.heart_broken, 'startColor': Colors.grey.shade500, 'endColor': Colors.grey.shade700},
      {'title': 'Luto o Duelo', 'icon': Icons.church, 'startColor': Colors.deepPurple.shade300, 'endColor': Colors.deepPurple.shade600},
      {'title': 'Nuevo Trabajo', 'icon': Icons.work, 'startColor': Colors.indigo.shade300, 'endColor': Colors.indigo.shade600},
      {'title': 'Fin de Trabajo', 'icon': Icons.work_off, 'startColor': Colors.brown.shade300, 'endColor': Colors.brown.shade600},
      {'title': 'Reconocimiento', 'icon': Icons.emoji_events, 'startColor': Colors.yellow.shade600, 'endColor': Colors.yellow.shade800},
      {'title': 'Competencias', 'icon': Icons.sports_kabaddi, 'startColor': Colors.red.shade400, 'endColor': Colors.red.shade700},
      {'title': 'Viajes', 'icon': Icons.flight_takeoff, 'startColor': Colors.cyan.shade300, 'endColor': Colors.cyan.shade600},
      {'title': 'Pérdidas de Peso', 'icon': Icons.monitor_weight, 'startColor': Colors.lime.shade400, 'endColor': Colors.lime.shade700},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Hecho Histórico'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: eventCategories.length,
        itemBuilder: (context, index) {
          final category = eventCategories[index];
          return DocumentCategoryCard(
            title: category['title'],
            icon: category['icon'],
            startColor: category['startColor'],
            endColor: category['endColor'],
            onTap: () {
            // --- 2. Cambiar la navegación ---
              // Ahora navegamos a la pantalla de lista, pasando el tipo y el ícono.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoricalEventListScreen(
                    eventType: category['title'],
                    icon: category['icon'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
