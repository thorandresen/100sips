import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_hundred_sips/spotifyconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';

class HomePageState extends State<HomePage> {
  AudioPlayer audioPlayer = new AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Velkommen!',
                style: TextStyle(fontSize: 50),
              ),
              Text(''),
              Text(''),
              Text(
                'Vælg spil...',
                style: TextStyle(fontSize: 30),
              ),
              Text(''),
              FlatButton(
                  onPressed: () => playLocal('sessøer.mp3', 60),
                  child: Text(
                    'Normal (60 sek.)',
                    style: TextStyle(fontSize: 15),
                  )),
              FlatButton(
                  onPressed: () => playLocal('sessøer.mp3', 20),
                  child: Text(
                    'Lyn (20 sek.)',
                    style: TextStyle(fontSize: 15),
                  )),
              Text(''),
              Text(
                'Husk at være logget ind på Spotify...',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future playLocal(localFileName, int duration) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = new File("${dir.path}/$localFileName");
    if (!(await file.exists())) {
      final soundData = await rootBundle.load("assets/$localFileName");
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    await audioPlayer.play(file.path, isLocal: true).then((onValue) {
      new Timer(const Duration(milliseconds: 9500), ()=> Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext _context) =>
                  SpotifyConnect(duration))));
    });
  }

}

/// Appbar method.
Widget appBar() {
  return AppBar(
    title: Text('100 sips'),
    centerTitle: true,
  );
}

class HomePage extends StatefulWidget {
  HomePageState createState() => new HomePageState();
}
