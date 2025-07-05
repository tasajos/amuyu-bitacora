// lib/screens/person_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:amuyu/models/person_model.dart';

class PersonDetailScreen extends StatelessWidget {
  final Person person;
  final List<Person> allPeople; // Necesitamos la lista completa para buscar a los familiares

  const PersonDetailScreen({
    super.key,
    required this.person,
    required this.allPeople,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Tarjeta de Información Básica
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Información Básica', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Nombre'),
                    subtitle: Text(person.name),
                  ),
                  if (person.notes != null && person.notes!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.notes),
                      title: const Text('Notas'),
                      subtitle: Text(person.notes!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tarjeta de Relaciones Familiares
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Relaciones Familiares', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  if (person.relationships.isEmpty)
                    const ListTile(title: Text('No tiene relaciones registradas.'))
                  else
                    // Construimos la lista de relaciones
                    ...person.relationships.map((rel) {
                      // Buscamos a la persona relacionada en nuestra lista completa
                      final relatedPerson = allPeople.firstWhere(
                        (p) => p.id == rel.personId,
                        // orElse es importante por si la persona fue borrada
                        orElse: () => Person(id: '?', name: 'Desconocido'), 
                      );

                      return ListTile(
                        title: Text('${relationshipTypeToString(rel.type)} de ${relatedPerson.name}'),
                        leading: const Icon(Icons.family_restroom_outlined),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // ¡Permite navegar de un perfil a otro!
                          if (relatedPerson.id != '?') {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => PersonDetailScreen(
                                person: relatedPerson,
                                allPeople: allPeople,
                              ),
                            ));
                          }
                        },
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}