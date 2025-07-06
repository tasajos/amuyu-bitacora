// lib/screens/daily_log_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:amuyu/helpers/database_helper.dart';
import 'package:amuyu/models/daily_activity_model.dart';
import 'package:intl/intl.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  late Future<List<DailyActivity>> _loggedActivitiesFuture;

  final List<Map<String, dynamic>> predefinedActivities = [
    {'name': 'Despertar', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Ejercicio', 'icon': Icons.fitness_center},
    {'name': 'Meditar', 'icon': Icons.self_improvement},
    {'name': 'Comida Saludable', 'icon': Icons.restaurant_menu},
    {'name': 'Beber Agua', 'icon': Icons.local_drink},
    {'name': 'Dormir', 'icon': Icons.bedtime_outlined},
    {'name': 'Trabajo Enfocado', 'icon': Icons.work_outline},
    {'name': 'Reunión', 'icon': Icons.groups_outlined},
    {'name': 'Estudiar', 'icon': Icons.book_outlined},
    {'name': 'Planificar Día', 'icon': Icons.edit_calendar_outlined},
    {'name': 'Leer', 'icon': Icons.menu_book},
    {'name': 'Ver Película/Serie', 'icon': Icons.theaters},
    {'name': 'Escuchar Música', 'icon': Icons.music_note_outlined},
    {'name': 'Videojuegos', 'icon': Icons.sports_esports_outlined},
    {'name': 'Pintar/Dibujar', 'icon': Icons.palette_outlined},
    {'name': 'Tocar Instrumento', 'icon': Icons.music_video_outlined},
    {'name': 'Tiempo en Familia', 'icon': Icons.family_restroom},
    {'name': 'Salir con Amigos', 'icon': Icons.people_outline},
    {'name': 'Llamada/Video', 'icon': Icons.phone_in_talk_outlined},
    {'name': 'Cita Romántica', 'icon': Icons.favorite_border},
    {'name': 'Limpiar', 'icon': Icons.cleaning_services_outlined},
    {'name': 'Cocinar', 'icon': Icons.soup_kitchen_outlined},
    {'name': 'Compras', 'icon': Icons.shopping_cart_outlined},
    {'name': 'Jardinería', 'icon': Icons.local_florist_outlined},
    {'name': 'Viajar', 'icon': Icons.flight_takeoff},
    {'name': 'Pasear Mascota', 'icon': Icons.pets},
    {'name': 'Conducir', 'icon': Icons.drive_eta_outlined},
    {'name': 'Relajarse', 'icon': Icons.beach_access},
    {'name': 'Ir de Fiesta', 'icon': Icons.celebration_outlined},
    {'name': 'Voluntariado', 'icon': Icons.volunteer_activism_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _refreshLoggedActivities();
  }

  void _refreshLoggedActivities() {
    setState(() {
      _loggedActivitiesFuture = DatabaseHelper.instance.getDailyActivities();
    });
  }

  // --- MÉTODO _showAddNotesSheet ACTUALIZADO CON SELECTOR DE FECHA Y HORA ---
  void _showAddNotesSheet(BuildContext context, Map<String, dynamic> activity) {
    final notesController = TextEditingController();
    var selectedDateTime = DateTime.now(); // Variable para guardar la fecha y hora

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder( // Usamos StatefulBuilder para manejar el estado de la fecha
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                  child: Icon(activity['icon'], size: 32, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Registrar "${activity['name']}"',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // --- NUEVO WIDGET PARA SELECCIONAR FECHA Y HORA ---
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Fecha y Hora del Registro'),
                  subtitle: Text(DateFormat('dd/MM/yyyy, HH:mm').format(selectedDateTime)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (date == null) return;

                    if (!context.mounted) return;

                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (time == null) return;

                    setModalState(() {
                      selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Añade un detalle o pensamiento...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Registrar Actividad'),
                    onPressed: () async {
                      final newActivity = DailyActivity(
                        id: const Uuid().v4(),
                        activityName: activity['name'],
                        icon: activity['icon'],
                        notes: notesController.text,
                        date: selectedDateTime, // Usamos la fecha seleccionada
                      );
                      await DatabaseHelper.instance.insertDailyActivity(newActivity);
                      if (mounted) Navigator.of(ctx).pop();
                      _refreshLoggedActivities();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _deleteActivity(String id) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres eliminar esta actividad?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteDailyActivity(id);
      _refreshLoggedActivities();
    }
  }


// --- NUEVA FUNCIÓN PARA MOSTRAR EL DIÁLOGO DE DETALLES ---
  void _showActivityDetailsDialog(DailyActivity activity) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                child: Icon(activity.icon, size: 38, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                activity.activityName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, dd MMMM yyyy, HH:mm').format(activity.date),
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  activity.notes!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Diarias'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '¿Qué has hecho hoy?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: predefinedActivities.length,
              itemBuilder: (ctx, index) {
                final activity = predefinedActivities[index];
                return _buildActivityChip(activity);
              },
            ),
          ),
          const Divider(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Tu Historial',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DailyActivity>>(
              future: _loggedActivitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Aún no has registrado ninguna actividad.\n¡Toca una de las opciones de arriba para empezar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                final loggedActivities = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: loggedActivities.length,
                  itemBuilder: (ctx, index) {
                    final activity = loggedActivities[index];
                    return _buildLoggedActivityCard(activity);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChip(Map<String, dynamic> activity) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () => _showAddNotesSheet(context, activity),
        borderRadius: BorderRadius.circular(15),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(activity['icon'], size: 30, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                activity['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET DEL HISTORIAL ACTUALIZADO CON onTap ---
  Widget _buildLoggedActivityCard(DailyActivity activity) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final activityDate = DateTime(activity.date.year, activity.date.month, activity.date.day);

    String dateString;
    if (activityDate == today) {
      dateString = 'Hoy, ${DateFormat('HH:mm').format(activity.date)}';
    } else if (activityDate == yesterday) {
      dateString = 'Ayer, ${DateFormat('HH:mm').format(activity.date)}';
    } else {
      dateString = DateFormat('dd/MM/yyyy, HH:mm').format(activity.date);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      clipBehavior: Clip.antiAlias, // Para que el InkWell respete los bordes
      child: ListTile(
        // --- AÑADIMOS EL onTap AQUÍ ---
        onTap: () => _showActivityDetailsDialog(activity),
        leading: Icon(activity.icon, color: Theme.of(context).primaryColor),
        title: Text(activity.activityName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: (activity.notes != null && activity.notes!.isNotEmpty)
            ? Text(activity.notes!, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dateString,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              onPressed: () => _deleteActivity(activity.id),
            ),
          ],
        ),
      ),
    );
  }
}
