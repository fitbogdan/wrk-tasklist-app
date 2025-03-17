import 'package:audioplayers/audioplayers.dart';

  void playWinSound() async{
    await AudioPlayer().play(AssetSource('sounds/win.mp3'));
  }

  void playClickSound() async{
    await AudioPlayer().play(AssetSource('sounds/click-5.mp3'));
  }

  void playPopSound() async{
    await AudioPlayer().play(AssetSource('sounds/pop-2.mp3'));
  }