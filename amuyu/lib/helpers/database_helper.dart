// lib/helpers/database_helper.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amuyu/models/person_model.dart';
import 'package:amuyu/models/historical_event_model.dart';
import 'package:amuyu/models/daily_activity_model.dart'; 
import 'package:amuyu/models/family_document_model.dart'; 
// Necesario para IconData

class DatabaseHelper {
  static const _databaseName = "Amuyu.db";
  static const _databaseVersion = 6;
  static const tableDailyActivities = 'daily_activities'; 
 static const tablePeople = 'people';
  static const tableRelationships = 'relationships';
  static const tableHistoricalEvents = 'historical_events';
   static const tableFamilyDocuments = 'family_documents'; // <-- Nuevo nombre de tabla
  

String getDatabaseName() {
  return _databaseName;
}
  // --- Singleton ---
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // --- Referencia a la Base de Datos ---
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // --- Inicialización de la BD ---
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

// Nueva función para cerrar la conexión de la BD
Future<void> closeDatabase() async {
  final db = await instance.database;
  await db.close();
  _database = null; // Importante para forzar la reapertura la próxima vez
}

  // --- Creación de Tablas (para una BD nueva) ---
  Future _onCreate(Database db, int version) async {
    // Tabla de Personas
    await db.execute('''
          CREATE TABLE $tablePeople (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            notes TEXT,
            birthDate TEXT,
            identityCard TEXT,
            country TEXT,
            city TEXT,
            isAlive INTEGER NOT NULL DEFAULT 1
          )
          ''');
    
    // Tabla de Relaciones
    await db.execute('''
          CREATE TABLE $tableRelationships (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            personId TEXT NOT NULL,
            relatedToId TEXT NOT NULL,
            type TEXT NOT NULL,
            FOREIGN KEY (personId) REFERENCES people (id) ON DELETE CASCADE,
            FOREIGN KEY (relatedToId) REFERENCES people (id) ON DELETE CASCADE
          )
          ''');
          
    // Tabla de Hechos Históricos
    await db.execute('''
      CREATE TABLE $tableHistoricalEvents (
        id TEXT PRIMARY KEY,
        eventType TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        priority TEXT NOT NULL,
        relatedPersonId TEXT
      )
    ''');

 // Actividades Diarias
    await db.execute('''
      CREATE TABLE $tableDailyActivities (
        id TEXT PRIMARY KEY,
        activityName TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        notes TEXT,
        date TEXT NOT NULL
      )
    ''');

// Documentos Familiares
    await db.execute('''
      CREATE TABLE $tableFamilyDocuments (
        id TEXT PRIMARY KEY,
        documentType TEXT NOT NULL,
        displayName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        relatedPersonId TEXT,
        createdAt TEXT NOT NULL
      )
    ''');



  }

  // --- Migración de la BD (para actualizar una BD existente) ---
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Lógica de migración incremental. Se ejecutan solo los cambios necesarios.
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE $tableHistoricalEvents (
          id TEXT PRIMARY KEY,
          eventType TEXT NOT NULL,
          description TEXT NOT NULL,
          date TEXT NOT NULL,
          priority TEXT NOT NULL,
          relatedPersonId TEXT
        )
      ''');
}
      if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE $tableDailyActivities (
          id TEXT PRIMARY KEY,
          activityName TEXT NOT NULL,
          iconCodePoint INTEGER NOT NULL,
          notes TEXT,
          date TEXT NOT NULL
        )
      ''');

    }
if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE $tableFamilyDocuments (
          id TEXT PRIMARY KEY,
          documentType TEXT NOT NULL,
          displayName TEXT NOT NULL,
          filePath TEXT NOT NULL,
          relatedPersonId TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
    }



    // En el futuro, si tuvieras una versión 5, añadirías:
    // if (oldVersion < 5) { /* Comandos para la versión 5 */ }
  }

  // --- Métodos para Personas y Relaciones ---

  Future<void> insertPerson(Person person) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert(tablePeople, person.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      
      for (final rel in person.relationships) {
        await txn.insert(tableRelationships, {
          'personId': person.id,
          'relatedToId': rel.personId,
          'type': rel.type.name,
        });
        final inverseType = _getInverseRelationshipType(rel.type);
        if (inverseType != null) {
          await txn.insert(tableRelationships, {
            'personId': rel.personId,
            'relatedToId': person.id,
            'type': inverseType.name,
          });
        }
      }
    });
  }

  Future<void> updatePerson(Person person) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.update(
        tablePeople,
        person.toMap(),
        where: 'id = ?',
        whereArgs: [person.id],
      );

      await txn.delete(tableRelationships, where: 'personId = ? OR relatedToId = ?', whereArgs: [person.id, person.id]);

      for (final rel in person.relationships) {
        await txn.insert(tableRelationships, {
          'personId': person.id,
          'relatedToId': rel.personId,
          'type': rel.type.name,
        });
        final inverseType = _getInverseRelationshipType(rel.type);
        if (inverseType != null) {
          await txn.insert(tableRelationships, {
            'personId': rel.personId,
            'relatedToId': person.id,
            'type': inverseType.name,
          });
        }
      }
    });
  }

  Future<void> deleteRelationship(String personId, Relationship relationship) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        tableRelationships,
        where: 'personId = ? AND relatedToId = ? AND type = ?',
        whereArgs: [personId, relationship.personId, relationship.type.name],
      );
      final inverseType = _getInverseRelationshipType(relationship.type);
      if (inverseType != null) {
        await txn.delete(
          tableRelationships,
          where: 'personId = ? AND relatedToId = ? AND type = ?',
          whereArgs: [relationship.personId, personId, inverseType.name],
        );
      }
    });
  }

  Future<List<Person>> getPeople() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> personMaps = await db.query(tablePeople);
    
    List<Person> people = [];
    for (var personMap in personMaps) {
      final List<Map<String, dynamic>> relationshipMaps = await db.query(
        tableRelationships,
        where: 'personId = ?',
        whereArgs: [personMap['id']],
      );
      
      List<Relationship> relationships = relationshipMaps.map((relMap) {
        return Relationship.fromMap(relMap);
      }).toList();

      people.add(Person.fromMap(personMap, relationships));
    }
    
    return people;
  }


  // --- Métodos para Actividades Diarias ---

  Future<void> insertDailyActivity(DailyActivity activity) async {
    final db = await instance.database;
    await db.insert(tableDailyActivities, activity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DailyActivity>> getDailyActivities() async {
    final db = await instance.database;
    // Ordenamos por fecha para que las más recientes aparezcan primero
    final List<Map<String, dynamic>> maps = await db.query(
      tableDailyActivities,
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return DailyActivity.fromMap(maps[i]);
    });
  }

  Future<void> deleteDailyActivity(String id) async {
  final db = await instance.database;
  await db.delete(
    tableDailyActivities,
    where: 'id = ?',
    whereArgs: [id],
  );
}


  RelationshipType? _getInverseRelationshipType(RelationshipType type) {
    const inverses = {
      RelationshipType.padre: RelationshipType.hijo,
      RelationshipType.madre: RelationshipType.hijo,
      RelationshipType.hijo: RelationshipType.padre,
      RelationshipType.hija: RelationshipType.padre,
      RelationshipType.abuelo: RelationshipType.sobrino,
      RelationshipType.abuela: RelationshipType.sobrino,
      RelationshipType.tio: RelationshipType.sobrino,
      RelationshipType.tia: RelationshipType.sobrino,
      RelationshipType.sobrino: RelationshipType.tio,
      RelationshipType.sobrina: RelationshipType.tio,
      RelationshipType.conyuge: RelationshipType.conyuge,
    // --- NUEVAS INVERSAS ---
    RelationshipType.nieto: RelationshipType.abuelo,
    RelationshipType.nieta: RelationshipType.abuelo,
    RelationshipType.bisabuelo: RelationshipType.bisnieto,
    RelationshipType.bisabuela: RelationshipType.bisnieto,
    RelationshipType.bisnieto: RelationshipType.bisabuelo,
    RelationshipType.bisnieta: RelationshipType.bisabuelo,
    RelationshipType.primo: RelationshipType.primo, // La inversa de primo/a es primo/a
    RelationshipType.prima: RelationshipType.primo,
    RelationshipType.suegro: RelationshipType.yerno, // Simplificado, podría ser nuera
    RelationshipType.suegra: RelationshipType.yerno,
    RelationshipType.yerno: RelationshipType.suegro,
    RelationshipType.nuera: RelationshipType.suegro,
    RelationshipType.hermanopolitico: RelationshipType.hermanopolitico, // La inversa de cuñado/a es cuñado/a
    RelationshipType.hermanapolitica: RelationshipType.hermanapolitica,
    RelationshipType.hermano: RelationshipType.hermano,
    RelationshipType.hermana: RelationshipType.hermana,
  };
  return inverses[type];
  }

 // --- Métodos para Hechos Históricos ---

  Future<void> insertHistoricalEvent(HistoricalEvent event) async {
    final db = await instance.database;
    await db.insert(tableHistoricalEvents, event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HistoricalEvent>> getHistoricalEvents() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableHistoricalEvents);
    return List.generate(maps.length, (i) => HistoricalEvent.fromMap(maps[i]));
  }



  // --- CORRECCIÓN AQUÍ: La función ahora está DENTRO de la clase ---
  Future<void> updateHistoricalEvent(HistoricalEvent event) async {
    final db = await instance.database;
    await db.update(
      tableHistoricalEvents,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }


  // --- Métodos para Documentos Familiares ---

  Future<void> insertFamilyDocument(FamilyDocument doc) async {
    final db = await instance.database;
    await db.insert(tableFamilyDocuments, doc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FamilyDocument>> getFamilyDocuments(String documentType) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableFamilyDocuments,
      where: 'documentType = ?',
      whereArgs: [documentType],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return FamilyDocument.fromMap(maps[i]);
    });
  }

  Future<void> deleteFamilyDocument(String id) async {
    final db = await instance.database;
    await db.delete(
      tableFamilyDocuments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  
}

