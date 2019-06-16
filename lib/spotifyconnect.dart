import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_hundred_sips/bloc/timer_bloc.dart';
import 'bloc/CounterBLoC.dart';
import 'bloc/CounterEvent.dart';
import 'bloc/timer_event.dart';
import 'bloc/timer_state.dart';
import 'credentials.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotify_playback/spotify_playback.dart';
import 'package:flutter/services.dart';
import 'ticker.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:volume/volume.dart';

class SpotifyConnectState extends State<SpotifyConnect> {
  bool _connectedToSpotify = false;
  static const MethodChannel _channel = const MethodChannel('spotify_playback');
  Uint8List image = null;
  String id;
  final TimerBloc _timerBloc = TimerBloc(ticker: Ticker());
  AudioPlayer audioPlayer = new AudioPlayer();
  AudioManager audioManager = AudioManager.STREAM_MUSIC;
  int maxVolume;
  int duration;

  SpotifyConnectState(int duration){
    this.duration = duration;
  }

  @override
  void initState() {
    super.initState();
    initConnector();
    Volume.controlVolume(audioManager);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: new FutureBuilder(
        future: spotifyBuilder(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // RUN IF CONNECTED TO SPOTIFY!
          if (snapshot.data != null) {
            print('CONNECTED!!');
            return connectedToSpotifyWidget();
          } else {
            // NOT CONNECTED TO SPOTIFY!
            print('NOT CONNECTED');
            return LinearProgressIndicator();
          }
        },
      ),
    );
  }

  /// Widget when connected to spotify the first time.
  Widget connectedToSpotifyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        BlocProvider(
          bloc: _timerBloc,
          child: TimerClass(duration),
        ),
      ],
    );
  }

  String cutPlaylistLink(String link) {
    String localId = link.substring(34, 56);

    return "spotify:playlist:" + localId;
  }

  /// Appbar method.
  Widget appBar() {
    return AppBar(
      title: Text('100sips'),
      centerTitle: true,
    );
  }

  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  /// Initialize the spotify playback sdk, by calling spotifyConnect
  Future<void> initConnector() async {
    try {
      await SpotifyPlayback.spotifyConnect(
              clientId: Credentials.clientId,
              redirectUrl: Credentials.redirectUrl)
          .then((connected) {
        if (!mounted) return;
        // If the method call is successful, update the state to reflect this change
        setState(() {
          _connectedToSpotify = connected;
        });
      }, onError: (error) {
        // If the method call trows an error, print the error to see what went wrong
        print(error);
      });
    } on PlatformException {
      print('Failed to connect.');
    }
  }

  Future<bool> spotifyBuilder() async {
    if (_connectedToSpotify) {
      return true;
    } else {
      return null;
    }
  }

  /// Play an song by spotify track/album/playlist id
  Future<void> play(String id) async {
    try {
      await SpotifyPlayback.play(id).then((success) {
        seekTo();
        print(this.toString());
        print(success);
      }, onError: (error) {
        print('Error happened in playing:' + error);
      });
    } on PlatformException {
      print('Failed to play.');
    }
  }

  ///Play the next song
  Future<void> skipNext() async {
    try {
      await SpotifyPlayback.skipNext().then((success) {
        seekTo();
        print(this.toString());
        print(success);
      }, onError: (error) {
        print(error);
      });
    } on PlatformException {
      print('Failed to play next song.');
    }
  }

  Future playLocal(localFileName) async {
    pause();
    final dir = await getApplicationDocumentsDirectory();
    final file = new File("${dir.path}/$localFileName");
    if (!(await file.exists())) {
      final soundData = await rootBundle.load("assets/$localFileName");
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    await audioPlayer.play(file.path, isLocal: true).then((onValue) {
      new Timer(const Duration(milliseconds: 1100), ()=> skipNextAndDownVolume());
    });
  }

  void skipNextAndDownVolume() async {
   Volume.setVol(0);
    skipNext();
    //pause();
  }

  /// Toggle shuffle
  Future<void> toggleShuffle() async {
    try {
      await SpotifyPlayback.toggleShuffle().then((success) {
        print(success);
      }, onError: (error) {
        print(error);
      });
    } on PlatformException {
      print('Failed to toggle shuffle.');
    }
  }

  /// Toggle repeat
  Future<void> toggleRepeat() async {
    try {
      await SpotifyPlayback.toggleRepeat().then((success) {
        print(success);
      }, onError: (error) {
        print(error);
      });
    } on PlatformException {
      print('Failed to toggle repeat.');
    }
  }

  /// The pause method is used to pause the current playing song
  static Future<bool> pause() async {
    final bool paused = await _channel.invokeMethod("pauseSpotify");
    return paused;
  }

  /// The resume method resumes the currently paused song
  static Future<bool> resume() async {
    final bool resumed = await _channel.invokeMethod("resumeSpotify");
    return resumed;
  }

  /// Seek to a a defined time relative to the current time
  Future<void> seekToRelativePosition() async {
    try {
      await SpotifyPlayback.seekToRelativePosition(5000).then((success) {
        print(success);
      }, onError: (error) {
        print(error);
      });
    } on PlatformException {
      print('Failed to play.');
    }
  }

  /// Seek to a defined time in a song
  Future<void> seekTo() async {
    Random random = new Random();
    try {
      await SpotifyPlayback.seekTo(random.nextInt(30000) + 20000).then(
          (success) {
            new Timer(const Duration(milliseconds: 500), ()=> Volume.setVol(100));
        print(success);
      }, onError: (error) {
        print(error);
      });
    } on PlatformException {
      print('Failed to play.');
    }
  }
}

class SpotifyConnect extends StatefulWidget {
  int duration;
  SpotifyConnect(int duration) {
    this.duration = duration;
  }

  SpotifyConnectState createState() => new SpotifyConnectState(duration);

  void play(String id){
    createState().play(id);
  }

  void skipNext(){
    createState().skipNext();
  }

  void playLocal() {
    createState().playLocal('drikcultshaker.mp3');
  }
}

class TimerClass extends StatelessWidget {
  int duration;
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  TimerClass(int duration){
    this.duration = duration;
  }

  @override
  Widget build(BuildContext context) {
    final TimerBloc _timerBloc = BlocProvider.of<TimerBloc>(context);
    final _bloc = CounterBLoC();
    return Column(
      children: <Widget>[

        StreamBuilder(
            stream: _bloc.stream_counter,
            initialData: 0,
            builder: (context, snapshot) {
              return Center(
                child: Text(
                  'Sips: ' + snapshot.data.toString(),
                  style: timerTextStyle,
                ),
              );
            }),

        Padding(
          padding: EdgeInsets.symmetric(vertical: 100.0),
          child: Center(
            child: BlocBuilder(
              bloc: _timerBloc,
              builder: (context, state) {
                final String textStr = 'Time';
                final String minutesStr = ((state.duration / 60) % 60)
                    .floor()
                    .toString()
                    .padLeft(2, '0');
                final String secondsStr =
                    (state.duration % 60).floor().toString().padLeft(2, '0');
                return Column(
                  children: <Widget>[
                    Text(
                      '$textStr: $minutesStr:$secondsStr',
                      style: TimerClass.timerTextStyle,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        BlocBuilder(
          condition: (previousState, currentState) =>
              currentState.runtimeType != previousState.runtimeType,
          bloc: _timerBloc,
          builder: (context, state) => Actions(_bloc, duration),
        ),
      ],
    );
  }
}

class Actions extends StatelessWidget {
  CounterBLoC _bloc;
  int duration;
  SpotifyConnect spotifyConnect;

  Actions(CounterBLoC _bloc, int duration){
    this._bloc = _bloc;
    this.duration = duration;
    spotifyConnect = new SpotifyConnect(duration);
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
              hintText:
                  'https://open.spotify.com/playlist/7x1ebdezDivH4mXAhUdR2S?si=SZUWsdmAQCOMcoknU365Bw',
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _mapStateToActionButtons(
            timerBloc: BlocProvider.of<TimerBloc>(context),
          ),
        )
      ],
    );
  }

  List<Widget> _mapStateToActionButtons({
    TimerBloc timerBloc,
  }) {
    final TimerState state = timerBloc.currentState;

    Widget _start() {
      print('this is run');
      _bloc.counter_event_sink.add(IncrementEvent());
      new Timer(const Duration(milliseconds: 200), ()=> spotifyConnect.playLocal());
      timerBloc.dispatch(Reset());
      timerBloc.dispatch(Start(duration: duration));
      return Container();
    }

    void firstStart() {
      spotifyConnect.play(
          'https://open.spotify.com/playlist/7x1ebdezDivH4mXAhUdR2S?si=u0wHcKJiQamzOAD2jVt5YQ');
      timerBloc.dispatch(Start(duration: duration));
    }

    if (state is Ready) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => firstStart(),
        ),
      ];
    }
    if (state is Finished) {
      print('Finished');
      return [
        _start(),
      ];
    }
    return [];
  }
}
