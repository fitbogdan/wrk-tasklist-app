import 'package:flutter/gestures.dart';
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

class textInfo{
  int day;
  int points;

  textInfo({
    required this.day,
    required this.points,
  });
}

class HistoryObject{
  int year = 2025;
  int month;
  int day;
  int weekday;
  int points;

  HistoryObject({
    this.year = 2025,
    required this.month,
    required this.day,
    required this.weekday,
    required this.points,
  });

  @override
  String toString(){
    return "HistoryObject{month: $month, day: $day, weekday: $weekday, points: $points}";
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
  List<textInfo> displayHistory = [];
  List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri","Sat","Sun",];
  int month = DateTime.now().month;


  @override
  void initState() {
    super.initState();
    //getDates();
    //print(m);
    showThisMonthProgress(DateTime.now().month);
    
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

  int totalPresentDays(int month){

      int total = 0;

      for(int i = 0; i<displayHistory.length; i++){
        if(displayHistory[i].points != 0){
          total++;
          }
      }

      return total;
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

  Future<void> showThisMonthProgress(int month) async{
    DateTime now = DateTime.now();
    int cYear = now.year;
    // int cMonth = now.month;
    List<HistoryObject> result = [];
    await getDates();

    //Calculating the number of days this month:
    DateTime firstDay = DateTime(cYear, month, 1);
    int nextMonth = month == 12 ? 1 : month+1;
    int count = 0;
    if(nextMonth != 1){
      count = DateTime(cYear, nextMonth, 1).subtract(Duration(days: 1)).day;
    }
    else{
      count = DateTime(cYear+1, 1, 1).subtract(Duration(days: 1)).day;
    }
      
      

    // print(count);
    if(firstDay.weekday != 1){
      while(firstDay.weekday > 1){
        firstDay = firstDay.subtract(Duration(days: 1));
        //Adjust ammount of shown days
        count++;
      }
    }
    
    for(int i = 0; i<count; i++){
      String timeString = timeBuildString(firstDay);
      if(m.containsKey(timeString)){
        result.insert(i, HistoryObject(month: firstDay.month, day: firstDay.day, weekday: firstDay.weekday, points: m[timeString])); 
      }

      else{
        result.insert(i, HistoryObject(month: firstDay.month, day: firstDay.day, weekday: firstDay.weekday, points: 0));
      }
      firstDay = firstDay.add(Duration(days: 1));
    }
    List<textInfo> output = [];
    for(int i = 0; i<count; i++){
      output.insert(i, textInfo(day: result[i].day, points: result[i].points));

      //textInfo(days: result[i].day, points: result[i].points)

      // Text("day: ${result[i].day}, points: ${result[i].points}")
    }


    print(result);
    
    setState(() {
      displayHistory = output;
    });
  }


  
  int totalRepsThisMonth(int month){

    //await List<textInfo> v = getThisMonthProgress(month);

    if(displayHistory.length > 1){
        int i = 0;
            while(displayHistory[i].day != 1){
              i++;
            }
            int s = 0;
            for(int j = i; j<displayHistory.length;j++){
              s+= displayHistory[j].points;
            }

            return s;
    }

    return 0;
    
  }


  @override
  Widget build(BuildContext context){
    // ignore: unused_local_variable
    double width = MediaQuery.sizeOf(context).width;
    // ignore: unused_local_variable
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [

            Container(
              //TODO: Make size variable
              width: 418,
              color: const Color.fromARGB(58, 90, 162, 255),
              child: Column(
                  children: [
                    Text("${readableTimeMonth(month)} ${DateTime.now().year}"),

                    SizedBox(height: 20,),

                    miniCalendar(),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total days worked this month: ${totalPresentDays(month)}"),
                        Text("Attendance rate: ${((totalPresentDays(month)/daysOfMonth(DateTime(DateTime.now().year, month, 1)))*100).toStringAsFixed(2)}%"),
                        Text("Total Reps: ${totalRepsThisMonth(month)}"),
                        // if(totalRepsThisMonth(month) - totalRepsThisMonth((month == 1 ? 12 : month-1)) > 0)
                          // Text("Progress over last month: ${totalRepsThisMonth(month) - totalRepsThisMonth((month == 1 ? 12 : month-1))}")
                      ],
                    ),
                    
                  ],
                ),
            ),

            Expanded(
              child: Column(
                children: [
                  Container( 
                    height: 50,
                    decoration: BoxDecoration(
                      //color: Colors.green,
                      border: Border(
                        // bottom: BorderSide(
                        //   color: Colors.black,
                        //   width: 0.5,
                        // )
                      )
                    ),
                    child: selectPeriodBar(),
                  ),

                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                        // bottom: BorderSide(
                        //   color: Colors.black,
                        //   width: 0.5,
                        // ),
                        right: BorderSide(
                          color: Colors.black,
                          width: 0.3,
                        ),
                        left: BorderSide(
                          color: Colors.black,
                          width: 0.3
                        )
                        
                      )
                    ),
                    //Weekdays
                    child: GridView.count(
                      crossAxisCount: 7,
                      children: [
                        for(int i = 0; i<7;i++)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(58, 90, 162, 255),
                              border: Border(
                                right: BorderSide(
                                  color: Colors.black,
                                  width: 0.5,
                                )
                              )
                            ),
                            child: Text(
                              weekDays[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                
                              ),
                              ),
                          )
                        
                      ],

                      ),
                  ),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 0.3,
                        )
                      ),
                      child: displayHistory.isEmpty ? 
                      Center(child: CircularProgressIndicator())
                      : GridView.count(
                        childAspectRatio: 1.3,
                        crossAxisCount: 7,
                        children: [
                          
                          for(int i = 0; i<displayHistory.length; i++)
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.transparent,//(displayHistory[i].points == 0 ? const Color.fromARGB(183, 158, 158, 158) : Colors.transparent), 
                                  BlendMode.srcATop
                                ),
                              child: dayItem(i)
                              ),
                        ],
                        ),
                    ),
                  )
                ],
              ),
            )
        ],
        ),
      ),
    );
  }

  Container miniCalendar() {
    return Container(
                    height: 350,
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                      BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      offset: Offset(0, 0),
                      blurRadius: 4,
                      spreadRadius: 3
                    )]),

                    child: GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(displayHistory.length, (i) {
                        //This function uses only the month
                        // int lastDay = daysOfMonth(DateTime(1999, month, 1));
                        bool isActive = displayHistory[i].points != 0;
                        bool isGrey = false;
                        
                        if(i < displayHistory.length-1){
                          if(displayHistory[i].day != displayHistory[i+1].day-1){
                              isGrey = true;
                          }
                          if(displayHistory[i].points == 0){
                            isGrey = true;
                          }
                            
                        }


                          
                              

                        
                        return Opacity(
                          opacity: isGrey ? 0.7 : 1,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: (isActive ? Color.fromARGB(255, 0, 166, 255) : Colors.transparent),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${displayHistory[i].day}",
                                  style: TextStyle(
                                    color: (isActive ? Colors.white : Colors.black),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal
                                  ),
                                  )
                                  
                              ),
                            ),
                          ),
                        );
                      }),  
                    ),
                  );
  }

  Container dayItem(int i) {
    return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.black,
                                  width: 0.3,
                                ),
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 0.6,
                                ),
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // if(i == 0 || i % 7 == 0)
                                    // ElevatedButton.icon(onPressed: (){}, label: Icon(Icons.info)),




                                      Opacity(
                                        opacity: (displayHistory[i].points == 0 ? 0.7 : 1),
                                        child: Text(displayHistory[i].day.toString())
                                        ),
                                  ],
                                ),
                                
                    
                                  SizedBox(
                                    height: 60,
                                  ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    
                                    if(displayHistory[i].points == 0)
                                    Opacity(
                                      opacity: 0.7,
                                      child: Text(
                                        "❌ Points - ${displayHistory[i].points}",
                                        style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                    ),
                                    if(displayHistory[i].points != 0)
                                      Text(
                                        "🏆Points - ${displayHistory[i].points}",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      )
                                  ],
                                )
                              ],
                            ),
                            );
  }

  Row selectPeriodBar() {
    return Row(
              children: [

                statsButton(),


                ElevatedButton(
                  onPressed: () async {

                    setState(() {
                      month = month-1;
                      displayHistory.clear();
                    });
                    await showThisMonthProgress(month);

                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10)
                  ),
                  child: Icon(Icons.arrow_left),
                ),
                //TODO: Make this not hardcoded bruh
                Text(readableTimeMonth(month)),
                
                ElevatedButton(

                  //TODO: Make this button calculate the ammount of days in this month/last month, and be able to change the for loop
                  //Of the gridview.
                  onPressed: ()  async {

                    setState(() {
                      month = month+1;
                      displayHistory.clear();
                    });
                    await showThisMonthProgress(month);

                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10)
                  ),
                  child: Icon(Icons.arrow_right),
                ),
              ],
            );
  }

  ElevatedButton statsButton() {
    return ElevatedButton.icon(
                onPressed: () {
                  List<int> w = [0,0,0,0,0,0];
                  bool ok = false;
                  // int j = 7;
                  for(int i = 0; i<7; i++){
                    if(displayHistory[i].day == 1){
                      ok = true;
                    }

                    if(ok == true){
                      w[0] += displayHistory[i].points;
                    }
                  }
                  for(int i = 7; i<14; i++){
                    w[1] += displayHistory[i].points;
                  }
                  for(int i = 14; i<21; i++){
                    w[2] += displayHistory[i].points;
                  }
                  for(int i = 21; i<28; i++){
                    w[3] += displayHistory[i].points;
                  }
                  if(displayHistory.length > 28){
                    for(int i = 28; i<displayHistory.length; i++){
                      w[4] += displayHistory[i].points;
                    }
                  }
                  

                  showDialog(context: context, builder: (context) 
                  => AlertDialog(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                      title: Text("${readableTimeMonth(month)}'s weeks:"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for(int i = 0; i<(w[4] == 0 ? 4 : 5);i++)
                            Text(
                              "Week ${i+1}: ${w[i]} reps",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400
                              ),
                              ),
                      
                          
                            Text("Total: ${w[0]+w[1]+w[2]+w[3]+w[4]}")
                            
                        ],
                      ),
                  ));
                },

                label: Icon(Icons.insights)
              );
  }

 
}