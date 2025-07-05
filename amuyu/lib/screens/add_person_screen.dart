// lib/screens/add_person_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:amuyu/models/person_model.dart';

class AddPersonScreen extends StatefulWidget {
  final List<Person> existingPeople;
  const AddPersonScreen({super.key, required this.existingPeople});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _identityCardController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  DateTime? _selectedBirthDate;

  final List<Relationship> _tempRelationships = [];
  String? _selectedPersonId;
  RelationshipType? _selectedRelationshipType;

  void _addRelationship() {
    if (_selectedPersonId != null && _selectedRelationshipType != null) {
      setState(() {
        _tempRelationships.add(Relationship(
          personId: _selectedPersonId!,
          type: _selectedRelationshipType!,
        ));
        _selectedPersonId = null;
        _selectedRelationshipType = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una persona y un tipo de relación.')),
      );
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      const uuid = Uuid();
      final newPerson = Person(
        id: uuid.v4(),
        name: _nameController.text,
        notes: _notesController.text,
        relationships: _tempRelationships,
        birthDate: _selectedBirthDate,
        identityCard: _identityCardController.text,
        country: _countryController.text,
        city: _cityController.text,
      );
      Navigator.of(context).pop(newPerson);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Persona'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                validator: (v) => v == null || v.isEmpty ? 'Introduce un nombre.' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _identityCardController,
                decoration: const InputDecoration(labelText: 'Carnet de Identidad'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'País'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de Nacimiento'),
                subtitle: Text(
                  _selectedBirthDate == null
                      ? 'No seleccionada'
                      : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() { _selectedBirthDate = pickedDate; });
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // --- SECCIÓN QUE FALTABA ---
              Text('Añadir Relaciones', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              if (widget.existingPeople.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedPersonId,
                  decoration: const InputDecoration(labelText: 'Persona Relacionada'),
                  items: widget.existingPeople.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setState(() => _selectedPersonId = v),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<RelationshipType>(
                  value: _selectedRelationshipType,
                  decoration: const InputDecoration(labelText: 'Esta nueva persona es su...'),
                  items: RelationshipType.values.map((type) => DropdownMenuItem(value: type, child: Text(relationshipTypeToString(type)))).toList(),
                  onChanged: (v) => setState(() => _selectedRelationshipType = v),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Relación'),
                  onPressed: _addRelationship,
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Añade a otra persona primero para poder crear relaciones.', style: TextStyle(color: Colors.grey)),
                )
              ],
              const SizedBox(height: 24),
              // --- FIN DE LA SECCIÓN QUE FALTABA ---

              Text('Relaciones a Guardar', style: Theme.of(context).textTheme.titleMedium),
              ..._tempRelationships.map((rel) {
                final relatedPerson = widget.existingPeople.firstWhere((p) => p.id == rel.personId);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Es ${relationshipTypeToString(rel.type)} de ${relatedPerson.name}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _tempRelationships.remove(rel)),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas Biográficas',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}