import 'package:flutter_application_notes/model/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotesDatabase {

  //champ global de notre instance fait appel au constructeur
  static final NotesDatabase instance = NotesDatabase._init();

  //variable de notre base de données 
  //Database :to send sql commands, created during [openDatabase]
  //Database : importer directement à partir de package sqflite package

  static Database? _database;

  //constructeur privée
  NotesDatabase._init();

  //open connexion to Database
  Future<Database> get database async {
    //retourner notre Database si existe
    if (_database != null) return _database!;

    //sinon creation d'une nouvelle database avac le nom : notes.db
    //notes.db:fichier de stockage de notre Database
    _database = await _initDB('notes.db');
    return _database!;
  }

  //renvoyer notre BD pour l'utiliser
  //stocker notre BD dans notre systeme de stockage de fichiers
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    //version 1 : par defaut
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //create notre table
  Future _createDB(Database db, int version) async {
    //les types de données
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableNotes ( 
  ${NoteFields.id} $idType, 
  ${NoteFields.isImportant} $boolType,
  ${NoteFields.number} $integerType,
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.time} $textType
  )
''');
  }

  Future<Note> create(Note note) async {
    //reference de note BD
    final db = await instance.database;
    //appel de la methode insert
    //tablenotes : la table ou je vais inserer mes données
    final id = await db.insert(tableNotes, note.toJson());
    //recuperer l'identifiant unique et le transfert vers notre note object
    return note.copy(id: id);
  }

  //readnote : methode pour lire les données
  Future<Note> readNote(int id) async {
    //definir notre BD
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      //les columns que je vais recuperer à partir de notre table
      columns: NoteFields.values,
      //preciser le note que je vais le lire
      //ne passe pas ici la valeur de id car il cause les attaques par sql injection
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
    //recuperer la note t convertir en objet note
    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }
  //methode : lire tous les données
  //return a list of note
  Future<List<Note>> readAllNotes() async {
    //definir notre BD
    final db = await instance.database;

    //ajouter l'ordre à partir de time avec l'ordre croissant
    final orderBy = '${NoteFields.time} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  //methode pour modifier les notes 
  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      //definir la note dont laquelle on va la modifier
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  //methode pour fermer notre DB
  Future close() async {
    //acces à notre BD que nous avons la crée avant 
    final db = await instance.database;
    db.close();
  }
}
