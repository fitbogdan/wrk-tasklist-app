import 'package:flutter/material.dart';
import 'package:wrk/services/sound_service.dart';
//import 'package:wrk/services/time_service.dart';
import 'package:wrk/widgets/strikethrough_container.dart';
//import 'dart:core';


class TaskData{
  final int id;
  String content;
  int xp;
  int status;
  int orderIndex;
  String timeString;

  TaskData({
    required this.id, 
    required this.content, 
    required this.xp, 
    required this.status,
    required this.orderIndex,
    required this.timeString,
    });

  Map<String, Object?> toMap(){
    return {'id' : id, 'content' : content, 'xp' : xp, 'status' : status, 'order_index' : orderIndex, 'task_time' : timeString};
  }

  @override
  String toString()
  {
    return 'Task{id: $id, content: $content, xp: $xp, status: $status, index: $orderIndex, time: $timeString}';
  }  

}

class TaskItem extends StatelessWidget {
  final String name;
  final int xp;
  final int id;
  final int isChecked;
  final int orderIndex;
  final String timeString;
  final Function(int) onToggle;
  final Function(int) onDelete;
  final Function(TaskData) onEdit;

  

  const TaskItem({
    super.key,
    required this.id,
    required this.name,
    required this.xp,
    required this.isChecked,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.orderIndex,
    required this.timeString,
  });

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    String newName = name;
    int newXp = xp;
    if(isChecked == 0){
      return taskBox(width, height, context, newName, newXp);
    }
    else{
      return Opacity(
        opacity: 0.6,
        child: StrikeThroughContainer(
          linecolor: const Color.fromARGB(255, 92, 92, 92),
          thickness: 1.6,
          widthFactor: 1,
          child: taskBox(width, height, context, newName, newXp),
        ),
      );
    }
  }

  Container taskBox(double width, double height, BuildContext context, String newName, int newXp) {
    return Container(
  width: (width*0.23 < 500 ? 500 : width * 0.23), //OLD: 576
  height: (height*0.06 < 76 ? 76 : height*0.06), //OLD: 76
  
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
              Checkbox(
                value: (isChecked == 1 ? true : false),
                activeColor: Colors.green,
                onChanged: (newBool){
                    playClickSound();
                  
                  onToggle(newBool == true ? 1 : 0);
                },
              ),
          
          
            MaterialButton(
              onPressed: () {
                editTaskDialog(context, newName, newXp);
              },
            
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: (width*0.15 < 300 ? 300 : width*0.15),
                    child: RichText(
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.clip,
                      maxLines: 2,
                      softWrap: true,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: "$name ",
                            style: TextStyle(
                              //decoration: (isChecked == 1 ? TextDecoration.lineThrough : TextDecoration.none)
                            )
                            ),
                          TextSpan(
                            text: "+$xp",
                            style: TextStyle(
                              color: Colors.green,
                              //decoration: (isChecked == 1 ? TextDecoration.lineThrough : TextDecoration.none)
                             // fontSize: 
                            )
                          )
                        ]
                      )
                      )
                  ),
                ],
              ),
            
              
                
                
              
              
              ),
              
              Flexible(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    showDialog(context: context, builder:(context) => AlertDialog(
                      title: Text(timeString),

                      //TODO: get task date
                    ),
                    );
                  }, 
                  icon: Icon(Icons.info)
                  )
                ),
          
              //DELETE
              Flexible(
                flex: 1,
                child: IconButton(onPressed: () {
                    onDelete(id);
                    playPopSound();
                }, 
                icon: Icon(
                  Icons.delete,
                  size: 20,
                  )),
              ),

                ReorderableDragStartListener(
                    index: orderIndex,
                    child: Padding(
                      padding: EdgeInsets.all(3),
                      child: Icon(Icons.drag_handle),
                      ),
                    )
          ],
          ),
          
            
          
          
          
          
          

        ],
      ),
    ),
  );
  }

  Set<void> get keepOrDeleteDialog {
    return {
            /*showDialog(context: context, builder: (_) => AlertDialog(
              title: Text("Do you want to keep the reps?"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  ),
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*

                  //TODO: Add remember my choice setting
                  Row(
                    children: [
                      Checkbox(
                      value: rememberSave, 
                      onChanged: (value) {
                        rememberSave = value!;
                      }
                      
                      )
                    ],
                  ),
                  */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          onDelete(id);
                          playPopSound();
                          Navigator.pop(context);
                        }, 

                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                          ),

                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.white),
                          ),
                        ),


                        SizedBox(width: 10),

                        ElevatedButton(
                          onPressed: () {
                            //TODO: Make this add to the rembered ammount of reps done
                            }, 

                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                          ),
                          
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.white),
                            ),
                          ),
                    ],
                  ),
                  
                  
                ],
              ),
            )),*/
                  
                  
              };
  }

  Future<dynamic> editTaskDialog(BuildContext context, String newName, int newXp) {
    return showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      title: Text("Edit Task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                    onChanged: (value){
                      //Task name
                      if(value!=''){
                        newName = value;
                      }
                    
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: "New name...",
                    ),
                )
              ),

              SizedBox(width: 10),

              SizedBox(
                width: 60,
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    //XP value
                    int? temp = int.tryParse(value);

                    if(temp!=null){
                      newXp = temp;
                    }

                    else{
                      //Error case
                      newXp = 0;
                    }

                  },

                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: "XP...",
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 30),
          MaterialButton(
            color: Colors.green,
            child: Text("Done", style: TextStyle(color: Colors.white),),
            onPressed: (){
              

              TaskData newTask = TaskData(id: id, content: newName, xp: newXp, status: isChecked, orderIndex: orderIndex, timeString: timeString);

              onEdit(newTask);


              if(context.mounted){
                Navigator.pop(context);
                playPopSound();
              }
          }
          ),

          SizedBox(height: 10),

          Text(
            "*You can edit one or more*",
            style: Theme.of(context).textTheme.bodySmall,            
            ),
        ],
      ),
    ));
  }
}