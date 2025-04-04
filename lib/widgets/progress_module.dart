import 'package:flutter/material.dart';
import 'package:wrk/services/database_service.dart';
import 'package:wrk/services/time_service.dart';

class PointsData{
  int id;
  String date;
  int points;

  PointsData({
    required this.id,
    required this.date,
    required this.points,
  });

  @override
  String toString(){
      return "PointsData{id: $id, points: $points, date: $date}";
  }
}

class ProgressModule extends StatefulWidget{
  const ProgressModule({
    super.key
  });

  @override
  State<StatefulWidget> createState() => _ProgressModuleState();
}

class _ProgressModuleState extends State<ProgressModule>{

  final DatabaseService _databaseService = DatabaseService.instance;

  List<PointsData> history = [];

  //Gives dates from today, back in time for NR days.
  Future<void> getDates() async {
    List<PointsData> times = [];
    times = await _databaseService.getPointsHistory();

    Map<String, dynamic> m = {};

    for(int i = 0; i<times.length; i++){
      final date = times[i].date;
      final points = times[i].points;

      if(m.containsKey(date)){
        m[date] = m[date]! + points;
      }
      else{
        m[date] = points;
      }

    }

    times.clear();

    
    int j = 0;
    for(var i in m.entries){
      times.insert(j, PointsData(date: i.key, points: i.value, id: 0));

      j++; 
    }
    setState(() {
      history = times;
    });
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("DO NOT PRESS THIS BUTTON!"),
            
                
              ],
              ),
              MaterialButton(
                  color: Colors.red,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.dangerous,
                        color: Colors.white,
                        ),
                      Text(
                        "Atomic Bomb",
                        style: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  onPressed: () async {
                    DateTime now = DateTime.now();

                    print("Current date time: ${now.year}-${now.month}-${now.day}");

                    for(int i = 1; i<=5; i++){
                      Duration days = Duration(days: i);
                      DateTime daysAgo = now.subtract(days);
                      String dateText = timeBuildString(daysAgo);
                      //_databaseService.addXp(5, dateText, i);

                      print("Date and time $i days ago: $daysAgo");
                    }


                    getDates();
                    print(history);
                    //List<PointsData> times = getDates();
                    

                  }
                ),
          ],
        ),
      ),
    );
  }
}