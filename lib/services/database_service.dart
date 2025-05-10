import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:wrk/services/time_service.dart';
import '../task_module/taskitem.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wrk/progress_module/progress_module.dart';
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
  static Database? _pointsDb;
  static final DatabaseService instance = DatabaseService._constructor();

  //TASK DB NAMES:
  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";
  final String _tasksXpColumnName = "xp";
  final String _tasksIndexColumnName = "order_index";
  final String _tasksTimeColumnName = 'task_time';

  //POINTS DB NAMES:
  final String _pointsTableName = "points_table";
  final String _pointsIdColumnName = "id";
  final String _pointsDateColumnName = "date";
  final String _pointsXpColumnName = "xp";

  //STREAK DB NAMES:
  final String _streakTableName = "streak_table";
  // ignore: unused_field
  final String _streakIdColumnName = "id";
  // ignore: unused_field
  final String _streakDateColumnName = "date";
  

  DatabaseService._constructor();

  Future<Database> get database async {
    //If db exists, just give it back
    if(_db != null) return _db!;

    //If not, use the function that creates db
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> get pointsDatabase async{
    if(_pointsDb != null) return _pointsDb!;

    _pointsDb = await getPointsDatabase();
    return _pointsDb!;
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

    // print(databasePath);


    try {
      final database = await databaseFactory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 4, 
          singleInstance: true,
          onCreate: (db, version) async {
            try {
              await db.execute('''
                CREATE TABLE $_tasksTableName (
                  $_tasksIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
                  $_tasksContentColumnName TEXT NOT NULL,
                  $_tasksStatusColumnName INTEGER NOT NULL,
                  $_tasksXpColumnName INTEGER NOT NULL,
                  $_tasksIndexColumnName INTEGER DEFAULT 0,
                  $_tasksTimeColumnName TEXT DEFAULT 'a'
                )
              ''');
            } catch (e) {
              // ignore: avoid_print
              print("ERROR in onCreate: $e"); 
            }
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 4) {
              try {
                await db.execute(
                  '''
                    ALTER TABLE $_tasksTableName 
                    ADD COLUMN $_tasksTimeColumnName TEXT DEFAULT 'a'
                  '''
                );
              } 
              
              catch (e) {
                // ignore: avoid_print
                print("ERROR in onUpgrade: $e"); 
              }
            }
          },
          onDowngrade: (db, oldVersion, newVersion) async{

            try{
                if(newVersion == 3){
                await db.execute('''
                CREATE TABLE ${_tasksTableName}_temp (
                    $_tasksIdColumnName INTEGER PRIMARY KEY,
                    $_tasksContentColumnName TEXT NOT NULL,
                    $_tasksStatusColumnName INTEGER NOT NULL,
                    $_tasksXpColumnName INTEGER NOT NULL,
                    $_tasksIndexColumnName INTEGER DEFAULT 0
                  )
                ''');

                await db.execute('''
                INSERT INTO ${_tasksTableName}_temp (
                $_tasksIdColumnName,
                $_tasksContentColumnName,
                $_tasksStatusColumnName,
                $_tasksXpColumnName,
                $_tasksIndexColumnName
                )
                SELECT
                  $_tasksIdColumnName,
                  $_tasksContentColumnName,
                  $_tasksStatusColumnName,
                  $_tasksXpColumnName,
                  $_tasksIndexColumnName
                FROM $_tasksTableName
                ''');

                await db.execute('DROP TABLE $_tasksTableName');

                await db.execute('ALTER TABLE ${_tasksTableName}_temp RENAME TO $_tasksTableName');

              }
            }
            catch(e){
              // ignore: avoid_print
              print("Error in DOWNGRADE");
            }
            
          }
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
Future<void> logToFile(String message) async{
  final dir = await getApplicationDocumentsDirectory();
  // print(dir);
  final file = File('${dir.path}/log.txt');
  final timestamp = timeBuildString(DateTime.now());
  await file.writeAsString("$timestamp: $message\n", mode: FileMode.append);
}

Future<Database> getPointsDatabase() async{

  if(Platform.isWindows || Platform.isMacOS || Platform.isLinux){
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final databaseDirPath = await getDatabasesPath();
  final pointsDatabasePath = join(databaseDirPath, "points_db.db");

  try{
    final pointsDatabase = await databaseFactory.openDatabase(
      pointsDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate:(db, version) {
          try{
            db.execute('''
            CREATE TABLE $_pointsTableName(
            $_pointsIdColumnName INTEGER PRIMARY KEY,
            $_pointsDateColumnName DATE NOT NULL,
            $_pointsXpColumnName INTEGER NOT NULL
            )
            ''');

            db.execute('''
            CREATE TABLE $_streakTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date DATE NOT NULL,
            streak_count INTEGER NOT NULL,
            is_completed BOOLEAN NOT NULL
            )
            ''');
          }
          catch(e){
            // print("ERROR: Creating points DB");
          }
          
        },

        onUpgrade: (db, oldVersion, newVersion) {

          if(oldVersion == 1 && newVersion==2){
            db.execute('''
            CREATE TABLE $_streakTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date DATE NOT NULL,
            streak_count INTEGER NOT NULL,
            is_completed BOOLEAN NOT NULL
            )
            ''');
          }
        },
      )
    );

    return pointsDatabase;
  }
  catch(e){

    //ignore: avoid_print
    print("Error in opening POINTS DB");
    rethrow;
  }

  
}
  Future<void> getStreak() async{
    

  }

  Future<void> addStreak() async{


  }


  Future<void> resetDatabase(String dbNameLocal) async{
    var databasePathLocal = await getDatabasesPath();
    String path = join(databasePathLocal, dbNameLocal);
    await deleteDatabase(path);
  }

  Future<void> addXp(int points, String date, int id, {Transaction? txn}) async{

    print("Using transaction: ${txn != null}");

    // final Database db;
    if(txn != null){
      await txn.insert(
      _pointsTableName, {
      _pointsIdColumnName: id,
      _pointsDateColumnName: date,
      _pointsXpColumnName: points
    });
    }

    else{
      final Database db = await pointsDatabase;
      await db.insert(
      _pointsTableName, {
      _pointsIdColumnName: id,
      _pointsDateColumnName: date,
      _pointsXpColumnName: points
    });
    }


    
  }

  Future<void> deletePointEntry(int id, {Transaction? txn}) async{
    final db = txn ?? await pointsDatabase;
    await db.delete(
      _pointsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> editPointEntry(PointsData obj) async{
    final db = await pointsDatabase;

    Map<String, dynamic> map = {};

    map[_pointsDateColumnName] = obj.date;
    map[_pointsIdColumnName] = obj.id;
    map[_pointsXpColumnName] = obj.points;

    await db.update(
      _pointsTableName,
      map,
      where: '$_pointsIdColumnName = ?',
      whereArgs: [obj.id],
    );
  }

  Future<List<PointsData>> getPointsHistory() async{
    final db = await pointsDatabase;

    final List<Map<String, dynamic>> points = await db.rawQuery('''
    SELECT $_pointsIdColumnName, $_pointsDateColumnName, SUM($_pointsXpColumnName) as total_points
    FROM $_pointsTableName
    GROUP BY $_pointsDateColumnName
    ''');


    //print(points);

  

    return points.map(
      (point) => PointsData(
        id: point[_pointsIdColumnName] as int, 
        date: point[_pointsDateColumnName] as String, 
        points: point['total_points'] as int,
      )).toList();
  } 

  Future<void> addTask(String content, int xp, int index, String time) async{
    final db = await database; //Getting a refference to the DB
    await db.insert(//Just an insert function!
      _tasksTableName, {
        _tasksContentColumnName: content, //The name of the task
        _tasksXpColumnName: xp,  //XP
        _tasksStatusColumnName: 0, //Status
        _tasksIndexColumnName: index,
        _tasksTimeColumnName: time,
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
      timeString: task[_tasksTimeColumnName] as String,
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
}

