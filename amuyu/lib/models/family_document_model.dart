// 1. Crea un nuevo archivo: lib/models/family_document_model.dart

class FamilyDocument {
  final String id;
  final String documentType; // Ej: "Certificados"
  final String displayName; // Nombre que le da el usuario
  final String filePath; // Ruta donde se guarda el archivo en la app
  final String? relatedPersonId;
  final DateTime createdAt;

  FamilyDocument({
    required this.id,
    required this.documentType,
    required this.displayName,
    required this.filePath,
    this.relatedPersonId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentType': documentType,
      'displayName': displayName,
      'filePath': filePath,
      'relatedPersonId': relatedPersonId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyDocument.fromMap(Map<String, dynamic> map) {
    return FamilyDocument(
      id: map['id'],
      documentType: map['documentType'],
      displayName: map['displayName'],
      filePath: map['filePath'],
      relatedPersonId: map['relatedPersonId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}


