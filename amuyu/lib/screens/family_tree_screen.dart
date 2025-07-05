// lib/screens/family_tree_screen.dart

import 'package:flutter/material.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/screens/add_person_screen.dart';
import 'package:amuyu/screens/person_detail_screen.dart';

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  // Lista temporal en memoria. ¡LOS DATOS SE PIERDEN AL CERRAR LA APP!
  final List<Person> _people = [];

  void _navigateAndAddPerson(BuildContext context) async {
    final newPerson = await Navigator.of(context).push<Person>(
      MaterialPageRoute(
        builder: (_) => AddPersonScreen(existingPeople: _people),
      ),
    );

    if (newPerson != null) {
      setState(() {
        _people.add(newPerson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Árbol Genealógico'),
      ),
      body: _people.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay nadie en tu árbol.\n¡Añade a la primera persona!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _people.length,
              itemBuilder: (ctx, index) {
                final person = _people[index];
                // El Card y ListTile mejorado que hicimos antes
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      child: Text(
                        person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('ID: ${person.id.substring(0, 8)}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PersonDetailScreen(
                            person: person,
                            allPeople: _people,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      // --- CORRECCIÓN AQUÍ ---
      // El FloatingActionButton va aquí, como un parámetro del Scaffold.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndAddPerson(context),
        tooltip: 'Añadir Persona',
        child: const Icon(Icons.add),
      ),
    );
  }
}