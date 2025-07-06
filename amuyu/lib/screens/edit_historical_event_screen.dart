// lib/screens/edit_historical_event_screen.dart
import 'package:flutter/material.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/models/historical_event_model.dart';
import 'package:amuyu/helpers/database_helper.dart';

class EditHistoricalEventScreen extends StatefulWidget {
  final HistoricalEvent eventToEdit;

  const EditHistoricalEventScreen({super.key, required this.eventToEdit});

  @override
  State<EditHistoricalEventScreen> createState() => _EditHistoricalEventScreenState();
}

class _EditHistoricalEventScreenState extends State<EditHistoricalEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late Priority _selectedPriority;
  String? _selectedPersonId;
  
  late Future<List<Person>> _peopleFuture;

  @override
  void initState() {
    super.initState();
    // Cargamos el formulario con los datos del evento a editar
    _descriptionController = TextEditingController(text: widget.eventToEdit.description);
    _selectedDate = widget.eventToEdit.date;
    _selectedPriority = widget.eventToEdit.priority;
    _selectedPersonId = widget.eventToEdit.relatedPersonId;
    _peopleFuture = DatabaseHelper.instance.getPeople();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedEvent = HistoricalEvent(
        id: widget.eventToEdit.id,
        eventType: widget.eventToEdit.eventType,
        description: _descriptionController.text,
        date: _selectedDate,
        priority: _selectedPriority,
        relatedPersonId: _selectedPersonId,
      );

      await DatabaseHelper.instance.updateHistoricalEvent(updatedEvent);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hecho histórico actualizado.')),
        );
        Navigator.of(context).pop(updatedEvent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Editar: ${widget.eventToEdit.eventType}'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        // --- CORRECCIÓN AQUÍ: Se ha añadido todo el contenido del formulario ---
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Describe este momento',
                    hintText: '¿Qué sucedió? ¿Cómo te sentiste?',
                    prefixIcon: Icon(Icons.edit_note, color: Theme.of(context).primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Por favor, añade una descripción.' : null,
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.calendar_month, color: Theme.of(context).primaryColor),
                    title: const Text('Fecha del Evento'),
                    subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: FutureBuilder<List<Person>>(
                      future: _peopleFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final people = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: _selectedPersonId,
                          decoration: InputDecoration(
                            labelText: 'Relacionar con Familiar',
                            prefixIcon: Icon(Icons.family_restroom_outlined, color: Theme.of(context).primaryColor),
                            border: InputBorder.none,
                          ),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Ninguno')),
                            ...people.map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Flexible(
                                child: Text(p.name, overflow: TextOverflow.ellipsis),
                              ),
                            )),
                          ],
                          onChanged: (value) => setState(() => _selectedPersonId = value),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Nivel de Importancia',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<Priority>(
              segments: const <ButtonSegment<Priority>>[
                ButtonSegment<Priority>(value: Priority.baja, label: Text('Baja'), icon: Icon(Icons.arrow_downward)),
                ButtonSegment<Priority>(value: Priority.media, label: Text('Media'), icon: Icon(Icons.horizontal_rule)),
                ButtonSegment<Priority>(value: Priority.alta, label: Text('Alta'), icon: Icon(Icons.arrow_upward)),
              ],
              selected: {_selectedPriority},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedPriority = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text('Guardar Cambios'),
              onPressed: _saveForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}