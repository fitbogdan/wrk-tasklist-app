String timeBuildString (DateTime time){
  String text = "${time.year} ${time.month} ${time.day}";
  return text;
}

DateTime getTimeObject (String text){
  List<String> parts = text.split(" ");
  int? year = int.tryParse(parts[0]); 
  int? month = int.tryParse(parts[1]);
  int?  day = int.tryParse(parts[2]);
  return DateTime(year!, month!, day!);
}