// lib/screens/family_tree_screen.dart

import 'package:flutter/material.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/screens/add_person_screen.dart';
import 'package:amuyu/screens/person_detail_screen.dart';
import 'package:amuyu/helpers/database_helper.dart';

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
      body: FutureBuilder<List<Person>>(
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
                  // Pasamos una lista vacía para la primera persona
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
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
                    ).then((_) => _refreshPeopleList()); // Refresca si hay cambios en el futuro
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Person>>(
        future: _peopleFuture,
        builder: (context, snapshot) {
          // Solo muestra el botón si ya hay personas en la lista
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => _navigateAndAddPerson(context, snapshot.data!),
              tooltip: 'Añadir Persona',
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink(); // No muestra nada si no hay datos
        },
      ),
    );
  }
}