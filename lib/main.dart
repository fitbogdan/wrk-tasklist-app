//import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'widgets/taskitem.dart';
import 'package:wrk/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'dart:math';
//import 'package:audioplayers/audioplayers.dart';
//import 'package:flutter/services.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';





void main() {

  //ONLY for desktop.
  if(Platform.isWindows || Platform.isMacOS || Platform.isLinux)
    {
      sqfliteFfiInit();
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

      //TODO: Centralize all style information here.
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(183, 48, 48, 48)),
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
          //TODO: Make sized after screen
          headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.black,
          selectionHandleColor: Colors.black,
        )
      ),
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
  static TextStyle smallwords = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);
  static TextStyle repsBad = TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red);
  static TextStyle repsGood = TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green);
  static TextStyle dialogError = TextStyle(fontWeight: FontWeight.w700,fontSize: 20, color: Colors.black);

  // ignore: unused_field
  final DatabaseService _databaseService = DatabaseService.instance;

  

  //TODO: GLOBALIZE
  int reps = 0;
  int last = 8;
  int repsTemp = -1;
  // ignore: unused_field
  String? _task;
  int? _xp;
  int xpTemp = -1;

  List<TaskData> tasks = [];

  

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
  //ONLY FOR DEV REASONS, REMOVE FOR PRODUCTION!!!
  Future<void> genTask() async{
    String name = WordPair.random().toString();
    int xp = Random.secure().nextInt(20);
    _databaseService.addTask(name, xp);
    loadTasks();
  }

  //Adds to the total number of reps, for today.
  void updateReps()
  {
    int repsDelta = 0;
    for(final task in tasks){
      if(task.status == 1){
        repsDelta+=task.xp;
      }
    }
    setState(() {
      reps=repsDelta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _addTaskButton(),

          
          SizedBox(width: 10),
          //DEV MODE ONLY:
          printButton(),
          SizedBox(width: 10),
          //DEV MODE ONLY:
          randomTaskButton(),
          SizedBox(width: 10),
          //DEV MODE ONLY:
          FloatingActionButton(onPressed:() {
            double width = MediaQuery.sizeOf(context).width;
            double height = MediaQuery.sizeOf(context).height;

            print("Width: $width;  Height: $height; ");
          },
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.laptop),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Text("WRK", style: heading),

            SizedBox(height: 20),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                  opacity: 1,  
                  child: Text(
                  
                  "Reps Today: $reps", 
                  style: (last > reps ? repsBad : repsGood),

                  )
                  ),
                  SizedBox(width: 5),
                  editRepsButton(context),

                  //TODO: Make sized after screen
                  //It might be too big for a smaller display.
                  SizedBox(width: 400),


                  Opacity(
                  opacity: 1,  
                  child: Text("To beat: $last", style: smallwords)
                  ),
                ]),
            ),
            
            SizedBox(height: 10,),
  
            Flexible(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index){
                  var task = tasks[index];
                  return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TaskItem(
                      id: task.id,
                      name: task.content, 
                      xp: task.xp, 
                      isChecked: task.status,
                      onToggle:(isChecked) async {
                
                        setState(() {
                          task.status = isChecked;  
                        });
                        
                        _databaseService.updateTask(task);
                        loadTasks();
                        updateReps();},
                      onDelete:(id) async {
                        _databaseService.deleteTask(task);
                        setState(() {
                            tasks.removeAt(index);
                        });
                        updateReps();},
                      ),],
                  );
                }),
            ),
          ],)
      )
    );
  }

  FloatingActionButton editRepsButton(BuildContext context) {
    return FloatingActionButton.small(onPressed:() {
                  showDialog(context: context, builder:(_) => 
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      ),
                    title: const Text("Edit reps"),


                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                          onChanged: (value) {

                            int? nmbr = int.tryParse(value);
                            if(nmbr != null){
                              //setState(() {
                                  repsTemp = nmbr;
                              //});
                            }
                            else{
                              repsTemp = -1;
                            } 
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            hintText: "Rep ammount...",
                          ),
                        ),
                        SizedBox(height: 10),
                        MaterialButton(
                          color: Colors.green,
                          child: Text(
                            "Edit reps",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            ),
                          onPressed:() {
                          if(repsTemp!=-1){
                              setState(() {
                              reps = repsTemp;
                              repsTemp = -1;
                              });
                          }
                          else{
                            errorMessage(context, "Enter a number!"); 
                          }
                        },)
                        ],
                      ),
                  ));
                },
                backgroundColor: (last > reps ? Colors.red : Colors.green),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  ),
                );
  }

  Future<dynamic> errorMessage(BuildContext context, String message) {
    return showDialog(context: context, builder: (BuildContext dialogContext) {
      Future.delayed(Duration(seconds: 1), () {
        if(dialogContext.mounted){ //In case someone closes the window before the 1 second runs out
          Navigator.of(dialogContext).pop();
        }
      });
      return Opacity(
              opacity: 0.9,
              child: AlertDialog(
                contentTextStyle: dialogError,
                content: Text(
                  message,
                  textAlign: TextAlign.center,
                  ),
                shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        ),
                ),
      );
    });
  }

  FloatingActionButton randomTaskButton() {
    return FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed:() => genTask(),
                  child: Icon(Icons.add),
                );
  }

  FloatingActionButton printButton() {
    return FloatingActionButton(
                  // ignore: avoid_print
                  onPressed:() => print(tasks),
                  child: Icon(Icons.keyboard),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                ),
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
                          //TODO: Make sized after screen
                          width: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged:(value) {
                              
                                int? number = int.tryParse(value);

                                if(number!=null) {
                                    xpTemp = number;  
                                }
                                else{
                                  xpTemp = -1;
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

                        if(xpTemp == -1){
                          errorMessage(context, "Enter a number!");
                        }

                        else{
                          setState(() {
                            _xp = xpTemp;
                            xpTemp = -1;
                          });

                          _databaseService.addTask(_task!, _xp!);

                          setState(() {
                            _task = null;
                            Navigator.pop(context);
                            loadTasks();
                          });
                        }
                        
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
