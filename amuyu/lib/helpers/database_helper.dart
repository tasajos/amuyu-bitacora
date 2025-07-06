// lib/helpers/database_helper.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amuyu/models/person_model.dart';

class DatabaseHelper {
  static const _databaseName = "Amuyu.db";
  static const _databaseVersion = 3;

  static const tablePeople = 'people';
  static const tableRelationships = 'relationships';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }


Future<void> updatePerson(Person person) async {
  final db = await instance.database;
  await db.transaction((txn) async {
    // 1. Actualiza los datos de la persona en la tabla 'people'
    await txn.update(
      tablePeople,
      person.toMap(),
      where: 'id = ?',
      whereArgs: [person.id],
    );

    // 2. Borra TODAS las relaciones antiguas de esta persona (tanto directas como inversas)
    // Esto simplifica la lógica enormemente.
    await txn.delete(tableRelationships, where: 'personId = ? OR relatedToId = ?', whereArgs: [person.id, person.id]);

    // 3. Vuelve a insertar todas las relaciones actualizadas y sus inversas
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

  
  // Se ha eliminado el CREATE TABLE duplicado. Ahora solo hay uno para cada tabla.
  Future _onCreate(Database db, int version) async {
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
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS $tableRelationships');
    await db.execute('DROP TABLE IF EXISTS $tablePeople');
    await _onCreate(db, newVersion);
  }

  // --- El resto de la clase no cambia ---

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
}