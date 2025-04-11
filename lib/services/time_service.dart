String timeBuildString (DateTime time){
  String text = "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
  return text;
}

DateTime getTimeObject (String text){
  List<String> parts = text.split("-");
  int? year = int.tryParse(parts[0]); 
  int? month = int.tryParse(parts[1]);
  int?  day = int.tryParse(parts[2]);
  return DateTime(year!, month!, day!);
}

String readableTime (DateTime time){
  String result = "";
  List<String> months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  List<String> daySufixes = ["st", "nd", "rd", "th"];

  String month = months[time.month-1];
  String sufix = "th";
  if(time.day <= 3){
    sufix = daySufixes[time.day-1];
  }

  result = "${time.day}$sufix of $month";
  return result;
} 