import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class TaskData{
  final int id;
  final String content;
  final int xp;
  int status;

  TaskData({required this.id, required this.content, required this.xp, required this.status});

  Map<String, Object?> toMap(){
    return {'id' : id, 'content' : content, 'xp' : xp, 'status' : status};
  }

  @override
  String toString()
  {
    return 'Task{id: $id, content: $content, xp: $xp, status: $status}';
  }  

}

class TaskItem extends StatelessWidget {
  final String name;
  final int xp;
  final int id;
  final int isChecked;
  final Function(int) onToggle;
  final Function(int) onDelete;


  const TaskItem({
    super.key,
    required this.id,
    required this.name,
    required this.xp,
    required this.isChecked,
    required this.onToggle,
    required this.onDelete,
  });

  //late bool isChecked;

  

  /*@override
  void initState()
  {
    super.initState();
    isChecked = (widget.isChecked == 0 ? false : true);
  }
  */
  void playClickSound() async{
    await AudioPlayer().play(AssetSource('sounds/click2.mp3'));
  }

  @override
  Widget build(BuildContext context) {


    return Container(
    //TODO: Make this sized after screen
    width: 573,
    height: 76,
    margin: EdgeInsets.all(10),
    //padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                offset: Offset(0, 0),
                blurRadius: 7,
                spreadRadius: 5
              )]),
      child: 
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Checkbox(
              value: (isChecked == 1 ? true : false),
              activeColor: Colors.green,
              onChanged: (newBool){
                if(newBool == true)
                {

                  //TODO: Different click sounds for each operation
                  playClickSound();
                }
                
                onToggle(newBool == true ? 1 : 0);
              },
            ),

            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: false,
              ),
            ),
        




            Text("$xp r", style: TextStyle(color: Colors.green),),



            IconButton(onPressed: () => {
                onDelete(id),  
            }, 

            //TODO: Make sized after screen
            icon: Icon(
              Icons.delete,
              size: 20,
              ))
        ],),
      ),
    );
  }
}