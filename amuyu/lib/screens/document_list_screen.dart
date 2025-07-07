// lib/screens/document_list_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:amuyu/helpers/database_helper.dart';
import 'package:amuyu/models/family_document_model.dart';
import 'package:amuyu/models/person_model.dart';

class DocumentListScreen extends StatefulWidget {
  final String documentType;
  final IconData icon;

  const DocumentListScreen({
    super.key,
    required this.documentType,
    required this.icon,
  });

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  late Future<Map<String, dynamic>> _dataFuture;
  // --- 1. Añadimos una variable de estado para la carga ---
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _refreshDocuments();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final documents = await DatabaseHelper.instance.getFamilyDocuments(widget.documentType);
    final people = await DatabaseHelper.instance.getPeople();
    return {'documents': documents, 'people': people};
  }

  void _refreshDocuments() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  void _showUploadForm() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String? selectedPersonId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 20, left: 20, right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                    child: Icon(widget.icon, size: 32, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Subir a "${widget.documentType}"',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre o descripción del documento',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, introduce un nombre para el documento.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Person>>(
                    future: DatabaseHelper.instance.getPeople(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      return DropdownButtonFormField<String>(
                        value: selectedPersonId,
                        decoration: InputDecoration(
                          labelText: 'Relacionar con (Opcional)',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Ninguno')),
                          ...snapshot.data!.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                        ],
                        onChanged: (value) => setModalState(() => selectedPersonId = value),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Seleccionar y Subir Archivo'),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(ctx).pop();
                          _pickAndSaveFile(nameController.text, selectedPersonId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- FUNCIÓN DE SUBIDA ACTUALIZADA CON INDICADOR DE CARGA ---
  Future<void> _pickAndSaveFile(String displayName, String? personId) async {
    setState(() => _isUploading = true); // <-- Mostramos el indicador
    
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) {
        setState(() => _isUploading = false); // <-- Ocultamos si el usuario cancela
        return;
      }

      final pickedFile = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = const Uuid().v4() + p.extension(pickedFile.path);
      final savedFile = await pickedFile.copy(p.join(appDir.path, fileName));

      final newDoc = FamilyDocument(
        id: const Uuid().v4(),
        documentType: widget.documentType,
        displayName: displayName,
        filePath: savedFile.path,
        relatedPersonId: personId,
        createdAt: DateTime.now(),
      );

      await DatabaseHelper.instance.insertFamilyDocument(newDoc);
      _refreshDocuments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el archivo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false); // <-- Ocultamos al final
      }
    }
  }

  Future<void> _deleteDocument(FamilyDocument doc) async { /*...código sin cambios...*/ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.documentType)),
      // --- 2. ENVOLVEMOS EL BODY EN UN STACK ---
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || (snapshot.data!['documents'] as List).isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No hay documentos en esta categoría.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                );
              }
              final List<FamilyDocument> documents = snapshot.data!['documents'];
              final List<Person> people = snapshot.data!['people'];

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: documents.length,
                itemBuilder: (ctx, index) {
                  final doc = documents[index];
                  String? personName;
                  if (doc.relatedPersonId != null) {
                    try {
                      personName = people.firstWhere((p) => p.id == doc.relatedPersonId).name;
                    } catch (e) { /* No se encontró la persona */ }
                  }
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(widget.icon)),
                      title: Text(doc.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(personName ?? 'Sin familiar asociado'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                        onPressed: () => _deleteDocument(doc),
                      ),
                      onTap: () => OpenFile.open(doc.filePath),
                    ),
                  );
                },
              );
            },
          ),
          // --- 3. WIDGET DE CARGA CONDICIONAL ---
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Guardando documento...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadForm,
        label: const Text('Subir Documento'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
