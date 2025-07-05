// lib/screens/add_entry_screen.dart

import 'package:flutter/material.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      // Mostrar un error si los campos están vacíos
      return;
    }
    // Aquí, en el futuro, guardaremos la entrada y la devolveremos
    // a la pantalla anterior.
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nueva Entrada'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: null, // Permite múltiples líneas
                expands: true, // Se expande para llenar el espacio
              ),
            ),
          ],
        ),
      ),
    );
  }
}