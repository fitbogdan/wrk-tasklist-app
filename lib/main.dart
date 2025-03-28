//import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'widgets/taskitem.dart';
import 'package:wrk/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'dart:math';
import 'package:wrk/services/sound_service.dart';
//import 'package:shared_preferences_windows/shared_preferences_windows.dart';
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
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(183, 48, 48, 48)),
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
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

  
  
  int reps = 0;
  int last = 8;
  int repsTemp = -1;
  String? _task;
  int? _xp;
  int xpTemp = -1;
  int repsTotal = 0;

  List<TaskData> tasks = [];
  List<TaskData> tasksDone = [];

  int tasksDoneCount = 0;
  int? toBeat;
  int toBeatCopy = 0;

  @override
  void initState() {
    super.initState();
    loadTasks();
    getLast();

  }

  Future<void> addTask(String content, int xp,  int orderIndex) async{
    //PROBLEM, whenever you add, the indexes do not update, so, if you have a bunch of tasks, and the last 2 ones
    //are checked only, and then delete a lot of the upper tasks, whenever you generate in new tasks,
    //they will generate either above, under or in between the last tasks, because I am updating it based on length


    _databaseService.addTask(content, xp, orderIndex);
    //loadTasks();
      for(int i = orderIndex-1; i<tasks.length; i++){
        tasks[i].orderIndex++;
        _databaseService.updateTask(tasks[i]);
      }  
    loadTasks();
    
  }

  void refreshOrder(List<TaskData> tasks){
    for(int i = 0; i< tasks.length; i++){
      tasks[i].orderIndex = i+1;
      _databaseService.updateTask(tasks[i]);
    }
  }

  Future<void> onToggle(TaskData task, int isChecked) async{
    if(isChecked == 0){
        tasksDoneCount--;
        repsTotal = (repsTotal - task.xp >= 0 ? repsTotal - task.xp : 0);
        if(task.status == 1){
          TaskData aux = tasks.removeAt(task.orderIndex-1);
          aux.orderIndex = tasks.length-tasksDoneCount+1;
          tasks.insert(aux.orderIndex-1, aux);

          refreshOrder(tasks);
        }

        }
        else{
          tasksDoneCount++;
          if(repsTotal+task.xp >= toBeatCopy && repsTotal < toBeatCopy){
            playWinSound();
          }
          repsTotal = repsTotal + task.xp;
          
          TaskData aux = tasks.removeAt(task.orderIndex-1);
          aux.orderIndex = tasks.length;
          tasks.insert(tasks.length, aux);
          refreshOrder(tasks);
        }
        task.status = isChecked;  
      await _databaseService.updateTask(task);
      loadTasks();
      updateReps();
  }

  Future<void> onDelete(int id, TaskData task, int index) async{

      
      setState(() {
          if(task.status == 1){
            tasksDoneCount--;
            repsTotal = (repsTotal - task.xp >= 0 ? repsTotal - task.xp : 0);
          }
          tasks.removeAt(index);
          refreshOrder(tasks);
      });

      await _databaseService.deleteTask(task);
      await loadTasks();
      updateReps();
  }

  Future<void> onEdit(TaskData newTask, TaskData task, int index) async{
    
    //TaskData newTask, TaskData task
    setState(() {
      if(newTask.status == 1){
        repsTotal -= task.xp;
        repsTotal = repsTotal + newTask.xp;
      }

      task = newTask;
      tasks[index] = newTask;
    });
    await _databaseService.updateTask(newTask);
    await loadTasks();
    updateReps();
  }

  Future<void> loadTasks() async{
    final dbTasks = await DatabaseService.instance.getTasks();
    setState(() {
      tasks = dbTasks;

      /*tasks.clear();
      tasksDone.clear();
      int i1 = 0, i2 = 0;
      for(int i = 0; i<dbTasks.length; i++){
          TaskData task = dbTasks[i];

          if(task.status == 1){
            tasksDone.insert(i1++, task);
          }
          else{
            tasks.insert(i2++, task);
          }
      } */
      //tasks = dbTasks;
    });

    //OLD
    //Counts all checked tasks, to give number of reps completed today, without having to save
    //updateReps();
  }


  //Gets last values out of the shared prefs path
  Future<void> getLast() async{
    Preferences user = await Preferences.create();
    //Get prefs!
    int? repsTotalTemp = user.prefs.getInt('repsTotal');
    int? tasksDoneCountTemp = user.prefs.getInt('tasksDoneCount');
    setState(() {
      toBeat = user.prefs.getInt('to_beat');  
      toBeatCopy = toBeat ?? 0;
      repsTotal = repsTotalTemp ?? 0;
      tasksDoneCount = tasksDoneCountTemp ?? 0;
    });
    
  }
  //ONLY FOR DEV REASONS, REMOVE FOR PRODUCTION!!!
  Future<void> genTask() async{
    String name = WordPair.random().toString();
    int xp = Random.secure().nextInt(20);

    addTask(name, xp, (tasksDoneCount == 0 ? tasks.length+1 : tasks.length-tasksDoneCount+1));
    loadTasks();
  }

  //Adds to the total number of reps, for today.
  //Pushes to prefs number of tasks done, so we can
  //add tasks at the correct indexes
  void updateReps() async
  {
    Preferences user = await Preferences.create();
    user.prefs.setInt('repsTotal', repsTotal);
    user.prefs.setInt('tasksDoneCount', tasksDoneCount);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          FloatingActionButton(
            backgroundColor: Colors.yellow,
            child: Icon(Icons.bolt),
            onPressed: () async {
              _databaseService.addTask("", 0, tasks.length-tasksDoneCount);
              loadTasks();
              playPopSound();
            }),

          SizedBox(width: 10),

          _addTaskButton(),
//------------------DEV MODE ONLY:----------------------------------------------
          SizedBox(width: 10),
          Text(
            "Dev tools:",
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(width: 10),
          printButton(), SizedBox(width: 10), randomTaskButton(), SizedBox(width: 10),
          FloatingActionButton(onPressed:() {
            // ignore: avoid_print
            print("Width: $width;  Height: $height; ");
          },
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.laptop),
          )
//----------------------------Dev end----------------------------------------------
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
                  
                  "Reps Today: $repsTotal", 
                  style: (toBeatCopy > repsTotal ? repsBad : repsGood),

                  )
                  ),
                  SizedBox(width: 5),
                  editRepsButton(context),

                  
                  SizedBox(width: (width*0.14 < 500 ? 300 : width*0.14)),


                  Opacity(
                  opacity: 1,  
                  child: MaterialButton(
                    onPressed: () {
                      showDialog(context: context, builder: (context) => StatefulBuilder( //This is a stateful builder, so I can set actively update the reps in the window
                        builder: (context, setDialogState){
                            return AlertDialog(
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          ),
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        title: Text("Reps to beat: $toBeat"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [ 
                              SizedBox(
                                    width: 250,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      onChanged:(value) {
                                          int? nr = int.tryParse(value);
                                          if(nr != null){
                                            xpTemp = nr;
                                          }
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        hintText: "Enter a number",
                                      ),
                                    ),
                                  ),
                              SizedBox(height: 10),

                              MaterialButton(
                                
                                color: Colors.green,
                                child: Text(
                                  "Done",
                                  style: TextStyle(color: Colors.white),
                                  ),
                                onPressed: () async {
                                  if(xpTemp <= -1){
                                    errorMessage(context, "Enter a (positive) number!");
                                    xpTemp = -1;
                                  }
                                  else{

                                    //Push to prefs
                                    Preferences user = await Preferences.create();
                                    user.prefs.setInt('to_beat', xpTemp);
                                    getLast();
                                  }
                                  playClickSound();
                                  if(context.mounted){
                                    Navigator.pop(context);
                                  }
                                  
                              }
                              )
                            ],

                          ),
                        );
                      }
                        
                      ));
                    },
                    child: Text("To beat: $toBeat", style: smallwords)
                    )
                  ),
                ]),
            ),
            
            SizedBox(height: 10,),
  
            Flexible(
              flex: 3,
              child: SizedBox(
                width: (width*0.23 < 500 ? 500+25 : width * 0.23+25),
                child: ReorderableListView.builder(
                  proxyDecorator: selectDecorator,
                  buildDefaultDragHandles: false,
                  itemCount: tasks.length, 
                  itemBuilder:(context, index) {
                    var task = tasks[index];
                    return Row(
                      key: ValueKey(task.id),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TaskItem(
                          orderIndex: index,
                          id: task.id,
                          name: task.content, 
                          xp: task.xp, 
                          isChecked: task.status,
                          onToggle:(isChecked) {
                            onToggle(task, isChecked);
                          },
                          onDelete:(id) {
                            onDelete(id, task, index);
                          },
                          onEdit: (newTask) async {
                            onEdit(newTask, task, index);
                          }
                      ),
                    ],);
                  }, 
                
                  onReorder:(oldIndex, newIndex) async {
                    if(oldIndex < newIndex){
                        newIndex--;
                      }                
                      final TaskData item = tasks[oldIndex];
                      tasks.removeAt(oldIndex);
                      tasks.insert(newIndex, item);                      
                      for(int i = 0; i < tasks.length; i++){
                        tasks[i].orderIndex = i+1;
                        _databaseService.updateTask(tasks[i]);
                      }

                    setState(() {
                    });
                  },
                  ),
              )
            ),


            /*Flexible(
              flex: 1,
              child: Text("Archive")
              ),*/

            //SizedBox(height: 50),
          ],)
      )
    );
  }

  Widget selectDecorator(child, index, animation) {
      return Material(
              child: child,
            );
        /*AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: 1.05,
            child: Material(
              //elevation: 2,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: child,
            ),
            );*/
        //},
       // child: child,
      //);
  }


//--------------------OLD----------------------- last is not toBeat
  MaterialButton plusButton(StateSetter setDialogState) {
    return MaterialButton(
      color: Colors.green,
      child: Icon(
        Icons.add,
        size: 20.0,
        color: Colors.white,
        ),
      onPressed:() {
      playClickSound();
      setDialogState(() {
        last = last+1;
      });
      setState(() {
        last = last;
      });
    },);
  }
//---------------------------------------------------------------------
//--------------------OLD----------------------- last is not toBeat
  MaterialButton minusButton(StateSetter setDialogState) {
    return MaterialButton(
      color: Colors.red,
      child: Icon(
        Icons.remove,
        size: 20.0,
        color: Colors.white,
        ),
      onPressed:() {
      playClickSound();
      setDialogState(() {
        last = last-1;
      });
      setState(() {
        last = last;
      });
    },);
  }
//---------------------------------------------------------------------

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
                              repsTotal = repsTemp;
                              //OLD:
                              reps = repsTemp;
                              repsTemp = -1;
                              });
                          }
                          else{
                            setState(() {
                              repsTotal = 0;
                              //OLD:
                              reps = 0;
                            });
                            //OR, could just leave the error
                            //errorMessage(context, "Enter a number!"); 
                          }
                          playClickSound();
                          Navigator.pop(context);
                        },)
                        ],
                      ),
                  ));
                },
                backgroundColor: (toBeatCopy > repsTotal ? Colors.red : Colors.green),
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
                  onPressed:() {
                    genTask();
                    playPopSound();
                    },
                  child: Icon(Icons.add),
                );
  }

  FloatingActionButton printButton() {
    return FloatingActionButton(
                  // ignore: avoid_print
                  onPressed:() {
                    //ignore: avoid_print
                    print("$tasks \n\n");


                    for(int i=0; i < tasks.length; i++){
                      print("${tasks[i].content} ${tasks[i].orderIndex}");
                    }

                    print("\n $tasksDoneCount");
                    //print("\nTASKS: $tasks");
                    //print("\nTASKS DONE: $tasksDone");
                    //ignore: avoid_print
                    
                  },
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

                          
                          _databaseService.addTask(_task!, _xp!, tasks.length-tasksDoneCount);
                          setState(() {
                            _task = null;
                            Navigator.pop(context);
                            loadTasks();
                          });
                          
                          playPopSound();
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
