// lib/screens/family_documents_screen.dart
import 'package:flutter/material.dart';
import 'package:amuyu/widgets/document_category_card.dart'; // Importamos el nuevo widget

class FamilyDocumentsScreen extends StatelessWidget {
  const FamilyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos la lista de categorías para nuestras tarjetas
    final List<Map<String, dynamic>> documentCategories = [
      {
        'title': 'Carnet de Identidad',
        'icon': Icons.badge_outlined,
        'startColor': Colors.teal.shade400,
        'endColor': Colors.teal.shade700,
      },
      {
        'title': 'Certificados',
        'icon': Icons.school_outlined,
        'startColor': Colors.blue.shade400,
        'endColor': Colors.blue.shade700,
      },
      {
        'title': 'Memorandos',
        'icon': Icons.article_outlined,
        'startColor': Colors.orange.shade400,
        'endColor': Colors.orange.shade700,
      },
      {
        'title': 'Reconocimientos',
        'icon': Icons.emoji_events_outlined,
        'startColor': Colors.purple.shade400,
        'endColor': Colors.purple.shade700,
      },
      {
        'title': 'Facturas',
        'icon': Icons.receipt_long_outlined,
        'startColor': Colors.red.shade400,
        'endColor': Colors.red.shade700,
      },
      {
        'title': 'Otros',
        'icon': Icons.miscellaneous_services_outlined,
        'startColor': Colors.grey.shade600,
        'endColor': Colors.grey.shade800,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos Familiares'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 tarjetas por fila
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0, // Hace que las tarjetas sean cuadradas
        ),
        itemCount: documentCategories.length,
        itemBuilder: (context, index) {
          final category = documentCategories[index];
          return DocumentCategoryCard(
            title: category['title'],
            icon: category['icon'],
            startColor: category['startColor'],
            endColor: category['endColor'],
            onTap: () {
              // Por ahora, solo mostramos un mensaje.
              // Aquí iría la lógica para subir un archivo.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Función para subir "${category['title']}" próximamente.'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
