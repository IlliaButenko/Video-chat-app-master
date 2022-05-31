import 'dart:async';

import 'package:audio/audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

@immutable
class AudioPlayers extends StatefulWidget
{
  final String url;
  final bool fromMe;

  AudioPlayers(this.url, {this.fromMe});

  @override
  State<StatefulWidget> createState() => AudioPlayersState();
}

class AudioPlayersState extends State<AudioPlayers>
{
  Audio audioPlayer = new Audio(single: true);
  AudioPlayerState state = AudioPlayerState.STOPPED;
  double position = 0;
  int buffering = 0;
  StreamSubscription<AudioPlayerState> _playerStateSubscription;
  StreamSubscription<double> _playerPositionController;
  StreamSubscription<int> _playerBufferingSubscription;
  StreamSubscription<AudioPlayerError> _playerErrorSubscription;

  @override
  void initState()
  {

    _playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state)
    {
      print("onPlayerStateChanged: ${audioPlayer.uid} $state");

      if (mounted)
        setState(() => this.state = state);
    });

    _playerPositionController = audioPlayer.onPlayerPositionChanged.listen((double position)
    {
      print("onPlayerPositionChanged: ${audioPlayer.uid} $position ${audioPlayer.duration}");

      if (mounted)
        setState(() => this.position = position);
    });

    _playerBufferingSubscription = audioPlayer.onPlayerBufferingChanged.listen((int percent)
    {
      print("onPlayerBufferingChanged: ${audioPlayer.uid} $percent");

      if (mounted && buffering != percent)
        setState(() => buffering = percent);
    });

    _playerErrorSubscription = audioPlayer.onPlayerError.listen((AudioPlayerError error)
    {
      throw("onPlayerError: ${error.code} ${error.message}");
    });

    audioPlayer.preload(widget.url);

    super.initState();
  }

  init() async {
    var file = await DefaultCacheManager().getSingleFile(widget.url);
  }

  @override
  Widget build(BuildContext context)
  {
    Widget status = Container();
    switch (state)
    {
      case AudioPlayerState.LOADING:
        {
          status = Container(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 24.0,
                height: 24.0,
                child: Center(
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        CircularProgressIndicator(strokeWidth: 2.0),
                        Text("${buffering}%", style: TextStyle(fontSize: 8.0), textAlign: TextAlign.center)
                      ],
                    )),
              )
          );
          break;
        }

      case AudioPlayerState.PLAYING:
        {
          status = IconButton(padding: EdgeInsets.all(0), icon: Icon(Icons.pause, size: 28.0), onPressed: onPause);
          break;
        }

      case AudioPlayerState.READY:
      case AudioPlayerState.PAUSED:
      case AudioPlayerState.STOPPED:
        {
          status = IconButton(padding: EdgeInsets.all(0), icon: Icon(Icons.play_arrow, size: 28.0), onPressed: onPlay);
          if (state == AudioPlayerState.STOPPED)
            audioPlayer.seek(0.0);
          break;
        }
    }

    return Container(
//      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        children: <Widget>[
//          Text(audioPlayer.uid),
          Row(
            children: <Widget>[
              status,
              Text("${_printDuration(Duration(milliseconds: audioPlayer.duration.toInt()))}"),
              Slider(
                max: audioPlayer.duration.toDouble(),
                value: position.toDouble(),
                onChanged: onSeek,
              ),
            ],
          ),

        ],
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose()
  {
    _playerStateSubscription.cancel();
    _playerPositionController.cancel();
    _playerBufferingSubscription.cancel();
    _playerErrorSubscription.cancel();
    audioPlayer.release();
    super.dispose();
  }

  onPlay()
  {
    audioPlayer.play(widget.url);
  }

  onPause()
  {
    audioPlayer.pause();
  }

  onSeek(double value)
  {
    // Note: We can only seek if the audio is ready
    audioPlayer.seek(value);
  }
}