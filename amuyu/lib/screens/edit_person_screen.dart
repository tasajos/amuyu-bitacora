// lib/screens/edit_person_screen.dart

import 'package:flutter/material.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/helpers/database_helper.dart'; // Necesitaremos esto más adelante

class EditPersonScreen extends StatefulWidget {
  final Person personToEdit;
  final List<Person> allPeople;

  // El constructor ahora es válido porque todos los campos de esta clase son 'final'.
  const EditPersonScreen({
    super.key,
    required this.personToEdit,
    required this.allPeople,
  });

  @override
  State<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _identityCardController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  DateTime? _selectedBirthDate;
  
  // --- CORRECCIÓN AQUÍ ---
  // La variable de estado '_isAlive' ahora vive en la clase State, que es su lugar correcto.
  late bool _isAlive; 
  
  late List<Relationship> _tempRelationships;
  String? _selectedPersonId;
  RelationshipType? _selectedRelationshipType;


   @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.personToEdit.name);
    _notesController = TextEditingController(text: widget.personToEdit.notes);
    _identityCardController = TextEditingController(text: widget.personToEdit.identityCard);
    _countryController = TextEditingController(text: widget.personToEdit.country);
    _cityController = TextEditingController(text: widget.personToEdit.city);
    _selectedBirthDate = widget.personToEdit.birthDate;
    
    // Ahora podemos inicializar '_isAlive' aquí sin problemas.
    _isAlive = widget.personToEdit.isAlive;
    
    _tempRelationships = List.of(widget.personToEdit.relationships);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _identityCardController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // Lógica para añadir una nueva relación a la lista temporal
 void _addRelationship() {
    if (_selectedPersonId != null && _selectedRelationshipType != null) {
      if (_selectedPersonId == widget.personToEdit.id) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No puedes crear una relación contigo mismo.')));
        return;
      }
      if (_tempRelationships.any((rel) => rel.personId == _selectedPersonId && rel.type == _selectedRelationshipType)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esta relación ya existe.')));
        return;
      }
      setState(() {
        _tempRelationships.add(Relationship(personId: _selectedPersonId!, type: _selectedRelationshipType!));
        _selectedPersonId = null;
        _selectedRelationshipType = null;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final updatedPerson = Person(
        id: widget.personToEdit.id,
        name: _nameController.text,
        notes: _notesController.text,
        relationships: _tempRelationships,
        birthDate: _selectedBirthDate,
        identityCard: _identityCardController.text,
        country: _countryController.text,
        city: _cityController.text,
        // Ahora se puede acceder a '_isAlive' sin problemas.
        isAlive: _isAlive,
      );
      Navigator.of(context).pop(updatedPerson);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availablePeople = widget.allPeople.where((p) => p.id != widget.personToEdit.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar a ${widget.personToEdit.name}'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre Completo'), validator: (v) => v!.isEmpty ? 'Introduce un nombre.' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _identityCardController, decoration: const InputDecoration(labelText: 'Carnet de Identidad')),
              const SizedBox(height: 10),
              TextFormField(controller: _countryController, decoration: const InputDecoration(labelText: 'País')),
              const SizedBox(height: 10),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Ciudad')),
              const SizedBox(height: 20),
               ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de Nacimiento'),
                subtitle: Text(_selectedBirthDate == null ? 'No seleccionada' : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(context: context, initialDate: _selectedBirthDate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                  if (pickedDate != null) setState(() { _selectedBirthDate = pickedDate; });
                },
              ),
              const SizedBox(height: 10),
              // El widget de RadioListTile ahora puede acceder a '_isAlive' sin problemas.
              Text('Estado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Vivo/a'),
                      value: true,
                      groupValue: _isAlive,
                      onChanged: (value) => setState(() => _isAlive = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Fallecido/a'),
                      value: false,
                      groupValue: _isAlive,
                      onChanged: (value) => setState(() => _isAlive = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text('Editar Relaciones', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              if (availablePeople.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedPersonId,
                  decoration: const InputDecoration(labelText: 'Persona Relacionada'),
                  items: availablePeople.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setState(() => _selectedPersonId = v),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<RelationshipType>(
                  value: _selectedRelationshipType,
                  decoration: const InputDecoration(labelText: 'Esta persona es su...'),
                  items: RelationshipType.values.map((type) => DropdownMenuItem(value: type, child: Text(relationshipTypeToString(type)))).toList(),
                  onChanged: (v) => setState(() => _selectedRelationshipType = v),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Añadir Relación'), onPressed: _addRelationship),
              ],
              const SizedBox(height: 24),
              Text('Relaciones Actuales', style: Theme.of(context).textTheme.titleMedium),
              ..._tempRelationships.map((rel) {
                final relatedPerson = widget.allPeople.firstWhere((p) => p.id == rel.personId, orElse: () => Person(id: '?', name: 'Desconocido'));
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Es ${relationshipTypeToString(rel.type)} de ${relatedPerson.name}'),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _tempRelationships.remove(rel))),
                );
              }),
              const SizedBox(height: 24),
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notas Biográficas', border: OutlineInputBorder(), alignLabelWithHint: true), maxLines: 4),
            ],
          ),
        ),
      ),
    );
  }
}