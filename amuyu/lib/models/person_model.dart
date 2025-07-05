// lib/models/person_model.dart

// Define los tipos de relación que se pueden tener
enum RelationshipType {
  padre, madre, hijo, hija, conyuge, tio, tia, sobrino, sobrina, abuelo, abuela
}

class Relationship {
  final String personId; // ID de la persona con la que se relaciona
  final RelationshipType type; // El tipo de relación (ej. es el HIJO de personId)

  Relationship({required this.personId, required this.type});
}

class Person {
  final String id;
  final String name;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? notes;
  
  // La nueva lista de relaciones
  final List<Relationship> relationships;

  Person({
    required this.id,
    required this.name,
    this.birthDate,
    this.deathDate,
    this.notes,
    this.relationships = const [], // Por defecto, una lista vacía
  });
}

// lib/models/person_model.dart

// ... (el código de las clases Person y Relationship y el enum) ...

// FUNCIÓN GLOBAL PARA CONVERTIR ENUM A TEXTO
String relationshipTypeToString(RelationshipType type) {
  // Reemplaza '_' por ' ' y pone la primera letra en mayúscula
  String name = type.name.replaceAll('_', ' ');
  return name[0].toUpperCase() + name.substring(1);
}