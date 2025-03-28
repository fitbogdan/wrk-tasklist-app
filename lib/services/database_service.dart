import 'dart:io';
import '../widgets/taskitem.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:wrk/main.dart';
//import 'package:sqflite_common_ffi';



class Preferences{
  late final SharedPreferences prefs;

  Preferences._(this.prefs);

  static Future<Preferences> create() async{
    final prefs = await SharedPreferences.getInstance();
    return Preferences._(prefs);
  }
  
}

class DatabaseService{
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";
  final String _tasksXpColumnName = "xp";
  final String _tasksIndexColumnName = "order_index";

  DatabaseService._constructor();

  Future<Database> get database async {
    //If db exists, just give it back
    if(_db != null) return _db!;

    //If not, use the function that creates db
    _db = await getDatabase();
    return _db!;
  }


//DB creation function.
  Future<Database> getDatabase() async {
    // Desktop initialization
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");

    print(databasePath);


    try {
      final database = await databaseFactory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 3, 
          onCreate: (db, version) async {
            try {
              await db.execute('''
                CREATE TABLE $_tasksTableName (
                  $_tasksIdColumnName INTEGER PRIMARY KEY,
                  $_tasksContentColumnName TEXT NOT NULL,
                  $_tasksStatusColumnName INTEGER NOT NULL,
                  $_tasksXpColumnName INTEGER NOT NULL,
                  $_tasksIndexColumnName INTEGER DEFAULT 0
                )
              ''');
            } catch (e) {
              // ignore: avoid_print
              print("ERROR in onCreate: $e"); 
            }
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              try {
                await db.execute('ALTER TABLE $_tasksTableName ADD COLUMN $_tasksIndexColumnName INTEGER DEFAULT 0');
              } 
              
              catch (e) {
                // ignore: avoid_print
                print("ERROR in onUpgrade: $e"); 
              }
            }
          },
        ),
      );
      return database;
    } 
  
  
  catch (e) {
    // ignore: avoid_print
    print("Database Open Error: $e");
    rethrow;
  }
}
/*
  Future<Database> getDatabase() async{

    //Desktop initialization
    if(Platform.isWindows || Platform.isMacOS || Platform.isLinux)
    {
      //Only for desktop
      sqfliteFfiInit();
      //Only for desktop
      databaseFactory = databaseFactoryFfi;
    }
    
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    //print(databasePath);


    final database = await databaseFactory.openDatabase(
      databasePath,//Open a new db in this path
      options: OpenDatabaseOptions( //With these options
        onCreate: (db, version){
        //SQL comand to create db
        db.execute('''
        CREATE TABLE $_tasksTableName (
          $_tasksIdColumnName INTEGER PRIMARY KEY,
          $_tasksContentColumnName TEXT NOT NULL,
          $_tasksStatusColumnName INTEGER NOT NULL,
          $_tasksXpColumnName INTEGER NOT NULL,
          $_tasksIndexColumnName INTEGER DEFAULT 0
        )
        ''');
        },
        version: 2,
        onUpgrade: (db, oldVersion, newVersion) async {
          if(oldVersion < 2){
            await db.execute('ALTER TABLE $_tasksTableName ADD COLUMN $_tasksIndexColumnName INTEGER DEFAULT 0');
          }
        },
        ),
      );
    //Gives the db to the database getter function, to use everywhere in the project!
    return database; 
  }*/

  void addTask(String content, int xp, int index) async{
    final db = await database; //Getting a refference to the DB
    await db.insert(//Just an insert function!
      _tasksTableName, {
        _tasksContentColumnName: content, //The name of the task
        _tasksXpColumnName: xp,  //XP
        _tasksStatusColumnName: 0, //Status
        _tasksIndexColumnName: index,
      });
  }



  Future<List<TaskData>> getTasks() async{
    final db = await database;

    final List<Map<String, Object?>> taskMaps = await db.query(
      _tasksTableName,
      orderBy: '$_tasksIndexColumnName ASC',//Sortam crescator dupa index
      );
      

    //print("DEBUG: Fetched from DB => $taskMaps");

    return taskMaps.map((task) => TaskData(
      id: task[_tasksIdColumnName] as int,
      content: task[_tasksContentColumnName] as String,
      xp: task[_tasksXpColumnName] as int,
      status: task[_tasksStatusColumnName] as int,
      orderIndex: task["order_index"] as int,
    )).toList();
  }

  Future<void> deleteTask(TaskData task) async{
    final db = await database;

    await db.delete(
      _tasksTableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> updateTask(TaskData task) async{
    final db = await database;

    await db.update(
      _tasksTableName,
      task.toMap(),
      where: '$_tasksIdColumnName = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> updateTaskName(TaskData task) async{
    final db = await database;

    await db.update(
      _tasksTableName,
      task.toMap(),
      where: '$_tasksContentColumnName = ?',
      whereArgs: [task.content]
    );
  }

  Future<void> updateTaskXp (TaskData task) async{
    final db = await database;

    await db.update(_tasksTableName,
     task.toMap(),
     where: '$_tasksXpColumnName = ?',
     whereArgs: [task.xp]
     );
  }

}

