// lib/screens/person_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/helpers/database_helper.dart';
import 'package:amuyu/screens/edit_person_screen.dart';

class PersonDetailScreen extends StatefulWidget {
  final Person person;
  final List<Person> allPeople;

  const PersonDetailScreen({
    super.key,
    required this.person,
    required this.allPeople,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Person _currentPerson;

  @override
  void initState() {
    super.initState();
    _currentPerson = widget.person;
  }

  void _navigateToEditScreen() async {
    final updatedPerson = await Navigator.of(context).push<Person>(
      MaterialPageRoute(
        builder: (_) => EditPersonScreen(
          personToEdit: _currentPerson,
          allPeople: widget.allPeople,
        ),
      ),
    );

    if (updatedPerson != null) {
      await DatabaseHelper.instance.updatePerson(updatedPerson);
      setState(() {
        _currentPerson = updatedPerson;
      });
    }
  }
  
  void _deleteRelationship(Relationship rel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta relación?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteRelationship(_currentPerson.id, rel);
      final peopleList = await DatabaseHelper.instance.getPeople();
      setState(() {
        _currentPerson = peopleList.firstWhere((p) => p.id == _currentPerson.id);
      });
    }
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPerson.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditScreen,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Información Básica', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  ListTile(leading: const Icon(Icons.person), title: const Text('Nombre'), subtitle: Text(_currentPerson.name)),
                  if (_currentPerson.notes != null && _currentPerson.notes!.isNotEmpty)
                    ListTile(leading: const Icon(Icons.notes), title: const Text('Notas'), subtitle: Text(_currentPerson.notes!)),
                  if (_currentPerson.birthDate != null)
                    ListTile(leading: const Icon(Icons.cake), title: const Text('Fecha de Nacimiento'), subtitle: Text('${_currentPerson.birthDate!.day}/${_currentPerson.birthDate!.month}/${_currentPerson.birthDate!.year}')),
                  if (_currentPerson.identityCard != null && _currentPerson.identityCard!.isNotEmpty)
                    ListTile(leading: const Icon(Icons.badge), title: const Text('Carnet de Identidad'), subtitle: Text(_currentPerson.identityCard!)),
                  if (_currentPerson.country != null && _currentPerson.country!.isNotEmpty)
                    ListTile(leading: const Icon(Icons.public), title: const Text('País / Ciudad'), subtitle: Text('${_currentPerson.country ?? ''}, ${_currentPerson.city ?? ''}')),
                  
                  // --- CORRECCIÓN AQUÍ ---
                  // Este es el widget correcto para esta pantalla. Muestra el estado, no lo edita.
                  ListTile(
                    leading: Icon(
                      _currentPerson.isAlive ? Icons.favorite : Icons.heart_broken,
                      color: _currentPerson.isAlive ? Colors.green.shade600 : Colors.grey.shade600,
                    ),
                    title: const Text('Estado'),
                    subtitle: Text(_currentPerson.isAlive ? 'Vivo/a' : 'Fallecido/a'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Relaciones Familiares', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  if (_currentPerson.relationships.isEmpty)
                    const ListTile(title: Text('No tiene relaciones registradas.'))
                  else
                    ..._currentPerson.relationships.map((rel) {
                      final relatedPerson = widget.allPeople.firstWhere(
                        (p) => p.id == rel.personId,
                        orElse: () => Person(id: '?', name: 'Desconocido'),
                      );
                      return ListTile(
                        title: Text('${relationshipTypeToString(rel.type)} de ${relatedPerson.name}'),
                        leading: const Icon(Icons.family_restroom_outlined),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                          onPressed: () => _deleteRelationship(rel),
                        ),
                        onTap: () {
                          if (relatedPerson.id != '?') {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (_) => PersonDetailScreen(person: relatedPerson, allPeople: widget.allPeople),
                            ));
                          }
                        },
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}