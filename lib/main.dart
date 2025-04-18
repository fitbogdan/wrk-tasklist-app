import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:wrk/widgets/progress_module.dart';
import 'task_module/task_module_main.dart';
import 'package:wrk/services/database_service.dart';



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
          bodySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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


  static TextStyle headingNonBold = TextStyle(fontSize: 25, color: Colors.white);
  //final DatabaseService _databaseService = DatabaseService.instance;
  int currentView = 0;

  void saveTab() async{
    Preferences user = await Preferences.create();
    user.prefs.setInt('currentView', currentView);
  }

  void getPrefs() async{
    Preferences user = await Preferences.create();
    int? current = user.prefs.getInt('currentView');

    setState(() {
      currentView = (current ?? 0);
    });
    
  }
  
  @override
  void initState() {
    super.initState();
    getPrefs();
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> viewList = [
    TaskModuleMain(),
   ProgressModule()
  ];
  

  @override
  Widget build(BuildContext context) {
    //double width = MediaQuery.sizeOf(context).width;
    //double height = MediaQuery.sizeOf(context).height;
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
                  setState(() {
                    currentView = 0;
                    saveTab();
                  });
                },
                ),

              ListTile(
                leading: Icon(Icons.history),
                title: Text("Progression"),
                onTap: () {
                  setState(() {
                    currentView = 1;
                    saveTab();
                  });
                },
              )

              
              
          ],
        ),
      ),
      body: Center(
        child: viewList[currentView],
      )
    );
  }



}
