import 'package:flutter/material.dart';
import 'package:OCWA/constants/strings.dart';
import 'package:OCWA/models/call.dart';
import 'package:OCWA/models/log.dart';
import 'package:OCWA/resources/call_methods.dart';
import 'package:OCWA/resources/local_db/repository/log_repository.dart';
import 'package:OCWA/pages/callscreens/call_screen.dart';
import 'package:OCWA/pages/chat/widgets/cached_image.dart';
import 'package:OCWA/utils/permissions.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    @required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  bool isCallMissed = true;

  addToLocalStorage({@required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    LogRepository.addLogs(log);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterRingtonePlayer.play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.voicemail,
      looping: true, // Android only - API >= 28
      volume: 0.1, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
  }

  @override
  void dispose() {
    if (isCallMissed) {
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
    }
    FlutterRingtonePlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "ສາຍໂທເຂົ້າ...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            CachedImage(
              (widget.call.hasDialled)
                  ? widget.call.receiverPic
                  : widget.call.callerPic,
              isRound: false,
              radius: 100,
              width: 200,
              height: 200,
            ),
            SizedBox(height: 15),
            Text(
              widget.call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 36),
                  child: FloatingActionButton(
                    heroTag: "RejectCall",
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.red,
                    onPressed: () async {
                      isCallMissed = false;
                      FlutterRingtonePlayer.stop();
                      addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                      await callMethods.endCall(call: widget.call);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 36),
                  child: FloatingActionButton(
                      heroTag: "AcceptCall",
                      child: Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        FlutterRingtonePlayer.stop();
                        isCallMissed = false;
                        addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                        await Permissions
                                .cameraAndMicrophonePermissionsGranted()
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CallScreen(call: widget.call),
                                ),
                              )
                            : {};
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
