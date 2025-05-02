import 'package:flutter/material.dart';
import 'dart:io';
import 'package:wrk/services/database_service.dart';


class SettingsTab extends StatefulWidget{
    const SettingsTab({
        super.key
    });

    @override
  State<StatefulWidget> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>{
    
    //Variables parking lot:
    bool keepXp = true;

    @override
    void initState() {
        super.initState();
        getKeepXp();
    }

    //Functions parking lot:

    Future<void> saveKeepXp () async{
        Preferences user = await Preferences.create();
        user.prefs.setBool('keepXp', keepXp);
    }

    Future<void> getKeepXp () async{    
        Preferences user = await Preferences.create();
        bool? keepTmp = user.prefs.getBool('keepXp');

        setState(() {
          keepXp = keepTmp ?? true;
        });
    }


    @override
    Widget build(BuildContext context){
        return Scaffold(
            
            body: Row(
                mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 20),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        SizedBox(height: 10),
                        Text("It's kinda empty in here for now ..."),
                        SizedBox(height: 60),
                        Transform.scale(
                            scale: 0.8,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                Text(
                                    "Keep XP on delete",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                            
                                Transform.scale(
                                scale: 0.9,
                                child: Switch(
                                    value: keepXp, 
                                    onChanged:(value) {
                                    setState(() {
                                    keepXp = value;
                                    });

                                    saveKeepXp();
                                },),
                                ),
                                    
                                ],
                            ),
                            ),
                    ],
                    ),
              ],
            ),
        );
    }
}