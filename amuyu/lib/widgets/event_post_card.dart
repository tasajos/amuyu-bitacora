// lib/widgets/event_post_card.dart
import 'package:flutter/material.dart';
import 'package:amuyu/models/historical_event_model.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/screens/edit_historical_event_screen.dart';

class EventPostCard extends StatelessWidget {
  final HistoricalEvent event;
  final List<Person> allPeople;
  final IconData icon;
  final VoidCallback onEventUpdated;

  const EventPostCard({
    super.key,
    required this.event,
    required this.allPeople,
    required this.icon,
      required this.onEventUpdated,
  });

  // Helper para obtener el color de la prioridad
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.alta:
        return Colors.red.shade400;
      case Priority.media:
        return Colors.amber.shade700;
      case Priority.baja:
        return Colors.blue.shade400;
    }
  }

  // Helper para obtener el nombre de la persona relacionada
  String? _getRelatedPersonName() {
    if (event.relatedPersonId == null) return null;
    try {
      return allPeople.firstWhere((p) => p.id == event.relatedPersonId).name;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final relatedPersonName = _getRelatedPersonName();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: InkWell(
        onTap: () {
          Navigator.of(context).push<HistoricalEvent>(
            MaterialPageRoute(
              builder: (_) => EditHistoricalEventScreen(eventToEdit: event),
            ),
          ).then((updatedEvent) {
            // Si se devolvió un evento actualizado, llamamos al callback
            if (updatedEvent != null) {
              onEventUpdated();
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Cabecera del Post ---
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              title: Text(event.eventType, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${event.date.day}/${event.date.month}/${event.date.year}'),
            ),
            const Divider(),
            // --- Contenido Principal ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Text(
                event.description,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            const Divider(),
            // --- Pie de Post (Metadata) ---
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  Chip(
                    avatar: Icon(Icons.label_important, color: _getPriorityColor(event.priority), size: 18),
                    label: Text(
                      'Prioridad ${event.priority.name}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getPriorityColor(event.priority).withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                  if (relatedPersonName != null)
                    Chip(
                      avatar: const Icon(Icons.person, size: 18),
                      label: Text(relatedPersonName, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey.shade200,
                      side: BorderSide.none,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
          ),
    );
        
  }
}