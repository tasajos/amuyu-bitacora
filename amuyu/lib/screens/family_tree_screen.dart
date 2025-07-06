// lib/screens/family_tree_screen.dart

import 'package:flutter/material.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/screens/add_person_screen.dart';
import 'package:amuyu/screens/person_detail_screen.dart';
import 'package:amuyu/helpers/database_helper.dart';
import 'package:amuyu/screens/tree_visualization_screen.dart';

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  late Future<List<Person>> _peopleFuture;

  @override
  void initState() {
    super.initState();
    _refreshPeopleList();
  }

  void _refreshPeopleList() {
    setState(() {
      _peopleFuture = DatabaseHelper.instance.getPeople();
    });
  }

  void _navigateAndAddPerson(BuildContext context, List<Person> currentPeople) async {
    final newPerson = await Navigator.of(context).push<Person>(
      MaterialPageRoute(
        builder: (_) => AddPersonScreen(existingPeople: currentPeople),
      ),
    );

    if (newPerson != null) {
      await DatabaseHelper.instance.insertPerson(newPerson);
      _refreshPeopleList(); // Recarga la lista desde la BD
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Árbol Genealógico'),
    ),
    // Usamos un Stack para poder poner los botones flotantes sobre la lista
    body: Stack(
      children: [
        FutureBuilder<List<Person>>(
          future: _peopleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Aún no hay nadie en tu árbol.\n¡Añade a la primera persona!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _navigateAndAddPerson(context, []),
                      child: const Text('Añadir Primera Persona'),
                    )
                  ],
                ),
              );
            }

            final people = snapshot.data!;
            return ListView.builder(
              itemCount: people.length,
              itemBuilder: (ctx, index) {
                final person = people[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: person.isAlive ? Theme.of(context).colorScheme.primary.withOpacity(0.8) : Colors.grey,
                      child: Text(
                        person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PersonDetailScreen(person: person, allPeople: people)),
                      ).then((_) => _refreshPeopleList());
                    },
                  ),
                );
              },
            );
          },
        ),
        // --- NUEVA SECCIÓN DE BOTONES FLOTANTES ---
        FutureBuilder<List<Person>>(
          future: _peopleFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink(); // No mostrar botones si no hay gente
            }
            final people = snapshot.data!;
            return Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Botón para ver el árbol
                  FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TreeVisualizationScreen(allPeople: people)),
                      );
                    },
                    heroTag: 'view_tree_btn', // Tag único para el Hero animation
                    label: const Text('Ver Árbol'),
                    icon: const Icon(Icons.account_tree),
                  ),
                  const SizedBox(height: 12),
                  // Botón para añadir persona
                  FloatingActionButton(
                    onPressed: () => _navigateAndAddPerson(context, people),
                    heroTag: 'add_person_btn', // Tag único
                    tooltip: 'Añadir Persona',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  );
}}