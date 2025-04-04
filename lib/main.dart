//import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:wrk/task_module/taskitem.dart';
import 'package:wrk/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'dart:math';
import 'package:wrk/services/sound_service.dart';
import 'package:wrk/services/time_service.dart';
import 'task_module/task_module_main.dart';
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


  static TextStyle heading = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static TextStyle headingNonBold = TextStyle(fontSize: 25, color: Colors.white);
  static TextStyle smallwords = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);
  static TextStyle repsBad = TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red);
  static TextStyle repsGood = TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green);
  static TextStyle dialogError = TextStyle(fontWeight: FontWeight.w700,fontSize: 20, color: Colors.black);

  // ignore: unused_field
  
  @override
  void initState() {
    super.initState();
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> ViewList = [
    TaskModuleMain(),
    Text("Hello world 2")
  ];
  int currentView = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 59, 180, 236),//Theme.of(context).scaffoldBackgroundColor,
        title: Text("WRK", style: headingNonBold),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 30
        ),
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: EdgeInsets.only(left:16),
          child: IconButton(
             icon:  Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            ),
          ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue
                ),
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  ),
                )
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Tasks"),
                onTap: () {
                  //TODO: Make this switch the position in the list of views
                },
                ),

              ListTile(
                leading: Icon(Icons.history),
                title: Text("Progression"),
                onTap: () {
                  
                },
              )

              
              
          ],
        ),
      ),
      /*floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          quickAddTask(),

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
  ),*/
      body: Center(
        child: ViewList[currentView],
      )
    );
  }



}
