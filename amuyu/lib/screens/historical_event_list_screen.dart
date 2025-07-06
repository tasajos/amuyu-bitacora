// lib/screens/historical_event_list_screen.dart
import 'package:flutter/material.dart';
import 'package:amuyu/models/historical_event_model.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/helpers/database_helper.dart';
import 'package:amuyu/screens/add_historical_event_screen.dart';
import 'package:amuyu/widgets/event_post_card.dart';

class HistoricalEventListScreen extends StatefulWidget {
  final String eventType;
  final IconData icon;

  const HistoricalEventListScreen({
    super.key,
    required this.eventType,
    required this.icon,
  });

  @override
  State<HistoricalEventListScreen> createState() => _HistoricalEventListScreenState();
}

class _HistoricalEventListScreenState extends State<HistoricalEventListScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Carga tanto los eventos como las personas de la BD
  void _loadEvents() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final events = await DatabaseHelper.instance.getHistoricalEvents();
    final people = await DatabaseHelper.instance.getPeople();
    // Filtramos los eventos para esta categoría específica
    final filteredEvents = events.where((event) => event.eventType == widget.eventType).toList();
    return {'events': filteredEvents, 'people': people};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventType),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || (snapshot.data!['events'] as List).isEmpty) {
            return const Center(
              child: Text('No hay eventos de este tipo registrados aún.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final List<HistoricalEvent> events = snapshot.data!['events'];
          final List<Person> people = snapshot.data!['people'];

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: events.length,
            itemBuilder: (ctx, index) {
              return EventPostCard(
              event: events[index],
              allPeople: people,
              icon: widget.icon,
              // --- Pasamos la función para refrescar la lista ---
              onEventUpdated: _loadEvents,
            );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddHistoricalEventScreen(eventType: widget.eventType),
            ),
          ).then((_) => _loadEvents()); // Refresca la lista al volver
        },
        label: const Text('Añadir Evento'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
