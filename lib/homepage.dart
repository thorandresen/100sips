import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_hundred_sips/spotifyconnect.dart';

class HomePageState extends State<HomePage> {
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
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext _context) =>
                              SpotifyConnect(60))),
                  child: Text(
                    'Normal (60 sek.)',
                    style: TextStyle(fontSize: 15),
                  )),
              FlatButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext _context) =>
                              SpotifyConnect(20))),
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
