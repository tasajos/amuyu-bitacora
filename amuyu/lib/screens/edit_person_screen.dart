// lib/screens/edit_person_screen.dart

import 'package:flutter/material.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/helpers/database_helper.dart'; // Necesitaremos esto más adelante

class EditPersonScreen extends StatefulWidget {
  final Person personToEdit;
  final List<Person> allPeople;

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
  
  // Controladores para los campos del formulario
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _identityCardController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  DateTime? _selectedBirthDate;
  
  // Lista temporal para manejar las relaciones en el formulario
  late List<Relationship> _tempRelationships;
  String? _selectedPersonId;
  RelationshipType? _selectedRelationshipType;

  @override
  void initState() {
    super.initState();
    // --- AQUÍ ESTÁ LA MAGIA ---
    // Inicializamos los controladores con los datos de la persona a editar
    _nameController = TextEditingController(text: widget.personToEdit.name);
    _notesController = TextEditingController(text: widget.personToEdit.notes);
    _identityCardController = TextEditingController(text: widget.personToEdit.identityCard);
    _countryController = TextEditingController(text: widget.personToEdit.country);
    _cityController = TextEditingController(text: widget.personToEdit.city);
    _selectedBirthDate = widget.personToEdit.birthDate;
    
    // Creamos una copia de la lista de relaciones para poder editarla
    _tempRelationships = List.of(widget.personToEdit.relationships);
  }

  @override
  void dispose() {
    // Es buena práctica limpiar los controladores cuando el widget se destruye
    _nameController.dispose();
    _notesController.dispose();
    _identityCardController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // Lógica para añadir una nueva relación a la lista temporal
  void _addRelationship() {
    // Evitar añadir una relación con uno mismo o una que ya existe
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

  // Lógica para guardar todos los cambios
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Creamos un nuevo objeto Person con los datos actualizados del formulario
      final updatedPerson = Person(
        id: widget.personToEdit.id, // Mantenemos el mismo ID
        name: _nameController.text,
        notes: _notesController.text,
        relationships: _tempRelationships,
        birthDate: _selectedBirthDate,
        identityCard: _identityCardController.text,
        country: _countryController.text,
        city: _cityController.text,
      );
      // Devolvemos la persona actualizada a la pantalla anterior
      Navigator.of(context).pop(updatedPerson);
    }
  }

  // La UI es casi idéntica a AddPersonScreen
  @override
  Widget build(BuildContext context) {
    // Filtramos la lista de personas para no poder seleccionarse a sí mismo
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
            // El contenido del ListView es el mismo que el de AddPersonScreen,
            // usando los controladores que ya hemos inicializado.
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
              }).toList(),
              const SizedBox(height: 24),
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notas Biográficas', border: OutlineInputBorder(), alignLabelWithHint: true), maxLines: 4),
            ],
          ),
        ),
      ),
    );
  }
}