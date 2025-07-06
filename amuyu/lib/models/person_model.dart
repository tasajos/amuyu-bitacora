// lib/models/person_model.dart

enum RelationshipType {
  // Originales
  padre,
  madre,
  hijo,
  hija,
  conyuge,
  tio,
  tia,
  sobrino,
  sobrina,
  abuelo,
  abuela,
  // --- NUEVOS TIPOS ---
  nieto,
  nieta,
  bisabuelo,
  bisabuela,
  bisnieto,
  bisnieta,
  primo,
  prima,
  suegro,
  suegra,
  yerno,
  nuera,
  hermanopolitico,
  hermanapolitica
}

String relationshipTypeToString(RelationshipType type) {
  String name = type.name.replaceAll('_', ' ');
  return name[0].toUpperCase() + name.substring(1);
}

class Relationship {
  final String personId;
  final RelationshipType type;

  Relationship({required this.personId, required this.type});

  // Constructor para crear desde un mapa (base de datos)
  factory Relationship.fromMap(Map<String, dynamic> map) {
    return Relationship(
      personId: map['relatedToId'],
      type: RelationshipType.values.byName(map['type']),
    );
  }
}

class Person {
  final String id;
  final String name;
  final String? notes;
  final List<Relationship> relationships;
  // --- NUEVOS CAMPOS ---
  final DateTime? birthDate;
  final String? identityCard;
  final String? country;
  final String? city;
  final bool isAlive;

  Person({
    required this.id,
    required this.name,
    this.notes,
    this.relationships = const [],
     // --- NUEVOS CAMPOS ---
    this.birthDate,
    this.identityCard,
    this.country,
    this.city,
    this.isAlive = true, // Por defecto, una persona nueva está viva

  });

  // Nótese que no incluye las relaciones, ya que van en otra tabla.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      // --- NUEVOS CAMPOS ---
      'birthDate': birthDate?.toIso8601String(), // Guardamos la fecha como texto
      'identityCard': identityCard,
      'country': country,
      'city': city,
      'isAlive': isAlive ? 1 : 0,


    };
  }

  // Constructor para crear un objeto Person desde un mapa (BD)
  // Acepta las relaciones que se leyeron por separado.
 factory Person.fromMap(Map<String, dynamic> map, List<Relationship> relationships) {
    return Person(
      id: map['id'],
      name: map['name'],
      notes: map['notes'],
      relationships: relationships,
      // --- NUEVOS CAMPOS ---
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
      identityCard: map['identityCard'],
      country: map['country'],
      city: map['city'],
       // Leemos el entero y lo convertimos de nuevo a booleano
      isAlive: map['isAlive'] == 1,
    );
  }
}