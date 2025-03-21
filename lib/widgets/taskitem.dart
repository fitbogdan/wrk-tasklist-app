import 'package:flutter/material.dart';
import 'package:wrk/services/sound_service.dart';

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

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    //TODO: Return taskObject IF edit mode off, and editableTask if edit mode ON.
    return Container(
    width: (573/width) * width,
    height: (76/height) * height,
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
                  showDialog(context: context, builder: (_) => AlertDialog(
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
                                    //TODO - get this from parent widget
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    hintText: "Name of task...",
                                  ),
                              )
                            ),

                            SizedBox(width: 10),

                            SizedBox(
                              width: 60,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  //TODO - get this from parent widget
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

                        }
                        ),
                      ],
                    ),
                  ));
                },

                child: Row(
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: false,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                
                  
                  
                
                
                ),
                Expanded(

                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Text("$xp r", style: TextStyle(color: Colors.green),)
                    )
                  ),
              
                
            
            
            
                IconButton(onPressed: () => {
                    onDelete(id),
                    playPopSound(),
                }, 
                icon: Icon(
                  Icons.delete,
                  size: 20,
                  ))
            ],),
            
              
            
            
            
            
            

          ],
        ),
      ),
    );
  }
}