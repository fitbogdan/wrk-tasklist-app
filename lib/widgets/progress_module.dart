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
  late Map<String, dynamic> m = {};
  List<Text> displayHistory = [];


  @override
  void initState() {
    super.initState();
    getDates();
    //print(m);
    
  }




  //Gives dates from today, back in time for NR days.
  Future<void> getDates() async {
    m.clear();
    history.clear();
    List<PointsData> times = [];
    times = await _databaseService.getPointsHistory();

    

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

    setState(() {
      //print(m);
      m = m;
    });
    //print(m);
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

  int totalReps(int days){

    int len = history.length;
    int sum = 0;

    if(days < history.length){
      for(int i = len-1; i>=len-days;i--){
        sum += history[i].points;
      }
    }
    else{
      for(int i = len-1; i>=0;i--){
        sum += history[i].points;
      }
    }
     

    return sum;
  }
  
  List<Text> showThisWeek() {
    DateTime now = DateTime.now();
    DateTime ago = now.subtract(Duration(days: 7));
    List<Text> result = [];

    for(int i = 0; i<=7; i++){
      DateTime newAgo = ago.add(Duration(days: i));
      String newAgoString = timeBuildString(newAgo);
      String readableString = readableTime(newAgo);

      if(m.containsKey(newAgoString)){
        String str = "$readableString - ${m[newAgoString]} reps!";
        result.insert(i, Text(str));
        print(str);
      }

      else{
        String str = "$readableString - 0 reps!";
        result.insert(i, Text(str));
        print(str);
      }
    }

    return result;
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,        
          children: [
            SizedBox(height: 20),
            Text("This Week: ${totalReps(7)}"),
            SizedBox(height: 20,),
            
            Text("Weekly view:"),
            
            SizedBox(height: 10,),


            //This Week
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [
                    Column(
                      children: [
                        
                        for(int i = 0; i<displayHistory.length; i++)
                          displayHistory[i],

                        SizedBox(height: 20),
                        MaterialButton(onPressed: () async {
                          await getDates();
                          displayHistory = showThisWeek();
                        },
                        child: Text("Press"),
                        ),

                      
                      ],
                    )
                    
                  ],
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}