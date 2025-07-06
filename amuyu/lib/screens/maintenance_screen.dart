// lib/screens/maintenance_screen.dart
import 'dart:io';
import 'dart:typed_data'; // Necesario para manejar los datos del archivo
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:amuyu/helpers/database_helper.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _isLoading = false;

  // --- FUNCIÓN DE EXPORTAR COMPLETAMENTE REESCRITA CON EL MÉTODO MODERNO ---
  Future<void> _exportDatabase() async {
    setState(() => _isLoading = true);

    try {
      // 1. Encontrar la ruta de la base de datos actual de la app
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, DatabaseHelper.instance.getDatabaseName());
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se encontró la base de datos para exportar.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // 2. Leer el contenido de la base de datos en memoria (como bytes)
      final Uint8List fileBytes = await dbFile.readAsBytes();
      
      // 3. Usar FilePicker para que el sistema operativo guarde el archivo
      // Este es el método correcto que funciona con Scoped Storage.
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Por favor, selecciona dónde guardar tu copia de seguridad:',
        fileName: 'Amuyu_Backup_${DateTime.now().toIso8601String()}.db',
        bytes: fileBytes,
      );

      if (outputFile != null) {
        // El sistema operativo guardó el archivo correctamente
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Base de datos exportada con éxito.')),
          );
        }
      } else {
        // El usuario canceló la operación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exportación cancelada.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error al exportar: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // La función de importar no necesita grandes cambios
  Future<void> _importDatabase() async {
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Advertencia!'),
        content: const Text('Importar una base de datos reemplazará permanentemente todos sus datos actuales. ¿Está seguro de que desea continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Continuar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        final dbFolder = await getApplicationDocumentsDirectory();
        final dbPath = p.join(dbFolder.path, DatabaseHelper.instance.getDatabaseName());

        await DatabaseHelper.instance.closeDatabase();
        await pickedFile.copy(dbPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Base de datos importada con éxito. Por favor, reinicie la aplicación.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se seleccionó ningún archivo.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error al importar: $e')),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // El método build no cambia
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimiento'),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Procesando...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMaintenanceButton(
                    context,
                    title: 'Exportar Base de Datos',
                    subtitle: 'Guarda una copia de seguridad de todos tus datos en la carpeta que elijas.',
                    icon: Icons.upload_file,
                    onTap: _exportDatabase,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 30),
                  _buildMaintenanceButton(
                    context,
                    title: 'Importar Base de Datos',
                    subtitle: 'Restaura tus datos desde un archivo de copia de seguridad. ¡Tus datos actuales se borrarán!',
                    icon: Icons.download_for_offline,
                    onTap: _importDatabase,
                    color: Colors.red.shade700,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMaintenanceButton(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap, required Color color}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      child: Row(
        children: [
          Icon(icon, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
