// lib/models/historical_event_model.dart

// Enum para definir los niveles de prioridad
enum Priority { alta, media, baja }

class HistoricalEvent {
  final String id;
  final String eventType; // El tipo de evento, ej: "Nuevo Trabajo"
  final String description;
  final DateTime date;
  final Priority priority;
  final String? relatedPersonId; // Opcional: ID de un familiar relacionado

  HistoricalEvent({
    required this.id,
    required this.eventType,
    required this.description,
    required this.date,
    required this.priority,
    this.relatedPersonId,
  });

  // Convierte un objeto a un mapa para guardarlo en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventType': eventType,
      'description': description,
      'date': date.toIso8601String(),
      'priority': priority.name, // Guardamos el enum como texto
      'relatedPersonId': relatedPersonId,
    };
  }

  // Crea un objeto desde un mapa leído de la base de datos
  factory HistoricalEvent.fromMap(Map<String, dynamic> map) {
    return HistoricalEvent(
      id: map['id'],
      eventType: map['eventType'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      priority: Priority.values.byName(map['priority']),
      relatedPersonId: map['relatedPersonId'],
    );
  }
}