import 'dart:async';

import 'package:OCWA/models/call.dart';
import 'package:OCWA/pages/callscreens/timer_text.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/chat/widgets/cached_image.dart';
import 'package:OCWA/pages/configs/configs.dart';
import 'package:OCWA/resources/call_methods.dart';
import 'package:OCWA/utils/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wakelock/wakelock.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  CallScreen({
    @required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();
  RtcEngine _engine;
  StreamSubscription callStreamSubscription;
  bool _joined = false;
  int _remoteUid = null;
  bool _switch = false;
  Stopwatch stopwatch = new Stopwatch();
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool video;
  bool speaker = false;
  bool running = false;
  DateTime runningTime;
  FlutterSoundPlayer myPlayer = FlutterSoundPlayer();
  StreamSubscription _playerSubscription;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    if (widget.call.type == 'video') {
      setState(() {
        video = true;
      });
    } else if (widget.call.type == 'voice') {
      setState(() {
        video = false;
      });
    } else {
      setState(() {
        video = true;
      });
    }

    addPostFrameCallback();
    initializeAgora();
    initializeAudio(false);
  }

  @override
  void dispose() {
    Wakelock.disable();
    cancelPlayerSubscriptions();
    releaseFlauto();
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> initializeAudio(bool withUI) async {
    await myPlayer.closeAudioSession();
    await myPlayer.openAudioSession(
        withUI: withUI,
        focus: AudioFocus.requestFocusAndKeepOthers,
        category: SessionCategory.playback,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await myPlayer.setSubscriptionDuration(Duration(milliseconds: 10));
    initializeDateFormatting('lo', null);
  }

  Future<void> initializeAgora() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
  }

  addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callStreamSubscription = callMethods
          .callStream(uid: Global.firePhone(G.loggedInUser.phone))
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data()) {
          case null:
            // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;

          default:
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    if (widget.call.type == 'video') {
      await _engine.enableVideo();
      await _engine.setEnableSpeakerphone(true);
      setState(() {
        video = true;
      });
    } else if (widget.call.type == 'voice') {
      await _engine.enableVideo();
      await _engine.enableLocalVideo(false);
      await _engine.setEnableSpeakerphone(false);
      setState(() {
        video = false;
      });
    } else {
      await _engine.enableVideo();
      await _engine.setEnableSpeakerphone(true);
      setState(() {
        video = true;
      });
    }

    await _engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await _engine.joinChannel(null, widget.call.channelId, null, 0);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) async {
        setState(() {
          _joined = true;
        });
        if (widget.call.type == 'video') {
          setState(() {
            speaker = true;
          });
          await _engine.setEnableSpeakerphone(true);
        } else if (widget.call.type == 'voice') {
          setState(() {
            speaker = false;
          });
          await _engine.setEnableSpeakerphone(false);
        } else {
          setState(() {
            speaker = true;
          });
          await _engine.setEnableSpeakerphone(true);
        }
        startPlaySound();
    }, userJoined: (int uid, int elapsed) async {
        setState(() {
          _remoteUid = uid;
        });
        if (widget.call.type == 'video') {
          setState(() {
            speaker = true;
          });
          await _engine.setEnableSpeakerphone(true);
        } else if (widget.call.type == 'voice') {
          setState(() {
            speaker = false;
          });
          await _engine.setEnableSpeakerphone(false);
        } else {
          setState(() {
            speaker = true;
          });
          await _engine.setEnableSpeakerphone(true);
        }
        stopPlaySound();
        _startTimer();
    }, userOffline: (int uid, UserOfflineReason reason) {
      callMethods.endCall(call: widget.call);
      setState(() {
        _remoteUid = null;
      });
      _stopTimer();
    }, userInfoUpdated: (int uid, userInfo) {
      setState(() {});
    }));
  }

  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return Text(
        'ກຳລັງເຊື່ອມຕໍ່...',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Text(
        'ກຳລັງເຊື່ອມຕໍ່...',
        textAlign: TextAlign.center,
      );
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onDisableVideo() async {
    setState(() {
      video = !video;
    });
    if (video) {
      await _engine.enableVideo();
    }
    _engine.enableLocalVideo(video);
  }

  void _enableSpeaker() async {
    setState(() {
      speaker = !speaker;
    });
    await _engine.setEnableSpeakerphone(speaker);
  }

  void _startTimer() {
    setState(() {
      stopwatch.start();
      running = true;
      runningTime = DateTime.now();
    });
  }

  void _stopTimer() {
    setState(() {
      stopwatch.stop();
      running = false;
      runningTime = null;
    });
  }

  startPlaySound() async {
    final fileUri =
        "https://firebasestorage.googleapis.com/v0/b/ocwa-app.appspot.com/o/ringing_sound.mp3?alt=media&token=85ac8548-022b-4f71-873e-170e988ad0aa";

    Duration d = await myPlayer.startPlayer(
      fromURI: fileUri,
      codec: Codec.mp3,
      whenFinished: () {
        callMethods.endCall(
          call: widget.call,
        );
      },
    );
  }

  stopPlaySound() async {
    await myPlayer.stopPlayer();
    cancelPlayerSubscriptions();
    releaseFlauto();
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  Future<void> releaseFlauto() async {
    try {
      await myPlayer.closeAudioSession();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      margin: EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32)),
        child: Container(
          padding: const EdgeInsets.all(4),
          color: Colors.black26,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: "Mute",
                  child: Icon(
                    muted ? Icons.mic : Icons.mic_off,
                    color: muted ? Colors.grey : Colors.white,
                  ),
                  onPressed: _onToggleMute,
                  backgroundColor: Colors.black38,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: "ToggleSpeaker",
                  child: Icon(
                    speaker ? Icons.volume_up : Icons.volume_down,
                    color: speaker ? Colors.white : Colors.grey,
                  ),
                  onPressed: _enableSpeaker,
                  backgroundColor: Colors.black38,
                ),
              ),
//              RawMaterialButton(
//                onPressed: _onToggleMute,
//                child: Icon(
//                  muted ? Icons.mic : Icons.mic_off,
//                  color: muted ? Colors.white : Colors.blueAccent,
//                  size: 20.0,
//                ),
//                shape: CircleBorder(),
//                elevation: 2.0,
//                fillColor: muted ? Colors.blueAccent : Colors.white,
//                padding: const EdgeInsets.all(12.0),
//              ),

//                RawMaterialButton(
//                onPressed: _onDisableVideo,
//                child: Icon(
//                  video ? Icons.videocam : Icons.videocam_off,
//                  color: video ? Colors.blueAccent : Colors.grey[400],
//                  size: 20.0,
//                ),
//                shape: CircleBorder(),
//                elevation: 2.0,
//                fillColor: muted ? Colors.blueAccent : Colors.white,
//                padding: const EdgeInsets.all(12.0),
//              ),
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: "ToggleCamera",
                  child: Icon(
                    video ? Icons.videocam : Icons.videocam_off,
                    color: video ? Colors.white : Colors.grey,
                  ),
                  onPressed: _onDisableVideo,
                  backgroundColor: Colors.black38,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: "SwitchCamera",
                  child: Icon(
                    Icons.switch_camera,
                    color: video ? Colors.white : Colors.grey,
                  ),
                  onPressed: _onSwitchCamera,
                  backgroundColor: Colors.black38,
                ),
              ),
//              RawMaterialButton(
//                onPressed: _onSwitchCamera,
//                child: Icon(
//                  Icons.switch_camera,
//                  color: Colors.blueAccent,
//                  size: 20.0,
//                ),
//                shape: CircleBorder(),
//                elevation: 2.0,
//                fillColor: Colors.white,
//                padding: const EdgeInsets.all(12.0),
//              ),
              Expanded(
                child: SizedBox(),
                flex: 1,
              ),
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: FloatingActionButton(
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.red,
                  onPressed: () {
                    callMethods.endCall(
                      call: widget.call,
                    );
                  },
                ),
              ),
//              RawMaterialButton(
//                onPressed: () {
//                  callMethods.endCall(
//                    call: widget.call,
//                  );
//                  Navigator.pop(context);
//                },
//                child: Icon(
//                  Icons.call_end,
//                  color: Colors.white,
//                  size: 35.0,
//                ),
//                shape: CircleBorder(),
//                elevation: 2.0,
//                fillColor: Colors.redAccent,
//                padding: const EdgeInsets.all(15.0),
//              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          if (!video)
            Scaffold(
                body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CachedImage(
                    (widget.call.hasDialled)
                        ? widget.call.receiverPic
                        : widget.call.callerPic,
                    isRound: false,
                    radius: 100,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text(
                      "ໂທ",
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      (widget.call.hasDialled)
                          ? widget.call.receiverName
                          : widget.call.callerName,
                      style:
                          TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                    ),
                  ),
                  // TikTikTimer(
                  //   initialDate:
                  //       runningTime != null ? runningTime : DateTime.now(),
                  //   running: running,
                  //   height: 40,
                  //   backgroundColor: Colors.transparent,
                  //   timerTextStyle: TextStyle(fontSize: 20),
                  //   borderRadius: 0,
                  //   isRaised: false,
                  //   tracetime: (time) {
                  //     // print(time.getCurrentSecond);
                  //   },
                  //   width: 150,
                  // ),
                  if (_remoteUid != null)
                    new Container(
                        height: 40,
                        child: new Center(
                          child: new TimerText(stopwatch: stopwatch),
                        )),
                ],
              ),
            )),
          if (video)
            Center(
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
            ),
          if (video)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(top: 40),
                width: 150,
                height: 150,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _switch = !_switch;
                    });
                  },
                  child: Center(
                    child:
                        _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _toolbar(),
          ),
        ],
      ),
    );
  }
}
