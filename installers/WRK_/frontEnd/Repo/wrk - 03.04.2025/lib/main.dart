import 'package:flutter/material.dart';
import 'widgets/taskitem.dart';
import 'package:wrk/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
//import 'package:audioplayers/audioplayers.dart';
//import 'package:flutter/services.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';





void main() {
  if(Platform.isWindows || Platform.isMacOS || Platform.isLinux)
    {
      //Only for desktop
      sqfliteFfiInit();
      //Only for desktop
      databaseFactory = databaseFactoryFfi;
    }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(183, 48, 48, 48)),
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.black,
          selectionHandleColor: Colors.black,
        )
      ),
      /*theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),*/
      home: const MyHomePage(),
    );
  }
}




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = ''});
  final String title;
 

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static TextStyle heading = TextStyle(fontSize: 40, fontWeight: FontWeight.bold);
  static TextStyle smallwords = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static TextStyle repsBad = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red);
  static TextStyle repsGood = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green);

  // ignore: unused_field
  final DatabaseService _databaseService = DatabaseService.instance;

  

  //TODO: GLOBALIZE
  int reps = 0;
  int last = 8;
  // ignore: unused_field
  String? _task;
  int? _xp;

  static List<TaskData> tasks = [];

  

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async{
    final dbTasks = await DatabaseService.instance.getTasks();
    setState(() {
      tasks = dbTasks;
    });
  }

  void updateReps(int repsDelta)
  {
    setState(() {
      reps+=repsDelta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _addTaskButton(),
      body: Center(
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
            "WRK",
            style: heading
            ),

            SizedBox(height: 20),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                  opacity: 0.7,  
                  child: Text(
                  
                  "Reps Today: $reps", 
                  style: (last > reps ? repsBad : repsGood),

                  )
                  ),
                    
                    
                    SizedBox(width: 400),

                  FloatingActionButton(onPressed:() => print(tasks)),


                  Opacity(
                  opacity: 0.7,  
                  child: Text("To beat: $last", style: smallwords)
                  ),
                ]),
            ),
            

            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                    for(final task in tasks)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TaskItem(
                          id: task.id,
                          name: task.name, 
                          xp: task.xp, 
                          isChecked: task.status,
                          onToggle:(repsDelta, isChecked) {
                            updateReps(repsDelta);
                            task.status = isChecked;
                          },


                          //TODO: Sterge din vector dupa stergere din DB
                          //TODO: FIX BUG!!!! Can ambele task-uri sunt apasate, se reseteaza aiurea
                          onDelete:(id) async {
                            _databaseService.deleteTask(id);
                            setState(() {
                              int index = tasks.indexWhere((task) => task.id == id);
                              if(index!=-1)
                              {
                                tasks.removeAt(index);
                              }
                            });
                            
                            //loadTasks();
                          },
                          ),
                        ],
                      )
                ],
              ),
            ),

            
            

          ],)
      )
    );
  }


  Widget _addTaskButton()
  {
    return 
      FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          showDialog(
            
            barrierColor: Color.fromRGBO(0, 0, 0, 0.5),
            context: context, 
            builder: (_) => AlertDialog(
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              title: const Text("Add Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                                setState(() {
                                    _task = value;
                                });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              hintText: "Name of task...",
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),

                        SizedBox(
                          width: 60,
                          //height: 30,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged:(value) {
                              
                                int? number = int.tryParse(value);

                                if(number!=null) 
                                {
                                  setState(() {
                                    _xp = number;  
                                  });
                                }
                                else
                                {
                                  //TODO: Decorate the ERROR message dialog for when entering a wrong input
                                  showDialog(context: context, builder: (_) => AlertDialog(content: Text("Enter a number!")));
                                }
                              
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              hintText: "XP",
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    
                    SizedBox(height: 30,),

                    MaterialButton(
                      color: Colors.green,
                      onPressed:() {
                        if(_task == null || _task ==""){
                          return;
                        }
                          
                        _databaseService.addTask(_task!, _xp!);

                        setState(() {
                          _task = null;
                          Navigator.pop(context);
                          loadTasks();
                        });
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(color: Colors.white)
                        ),
                      ),
                ],
              ),
            ),
            );
        },
        child: Icon(
          Icons.add
        ),
    );
  }

}
