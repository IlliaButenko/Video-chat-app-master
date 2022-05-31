import 'dart:math';

import 'package:OCWA/Controllers/firebaseController.dart';
import 'package:OCWA/Controllers/notificationController.dart';
import 'package:flutter/material.dart';
import 'package:OCWA/constants/strings.dart';
import 'package:OCWA/models/call.dart';
import 'package:OCWA/models/log.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/resources/call_methods.dart';
import 'package:OCWA/resources/local_db/repository/log_repository.dart';
import 'package:OCWA/pages/callscreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserModel from, UserModel to, context, type, token}) async {
    Call call = Call(
      callerId: from.phone,
      callerName: from.name,
      callerPic: from.avatar,
      receiverId: to.phone,
      receiverName: to.name,
      receiverPic: to.avatar,
      type: type,
      token: token,
      channelId: Random().nextInt(1000).toString(),
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.avatar,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.avatar,
      type: type,
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // enter log
      LogRepository.addLogs(log);

      // Send notification
      sendNotification(call);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call),
        ),
      );
    }
  }

  static sendNotification(Call call) async {
    try {
      int unReadMSGCount = await FirebaseController.instance
          .getUnreadMSGCount(call.receiverId);
      await NotificationController.instance.sendNotificationMessageToPeerUser(
          unReadMSGCount,
          'call',
          'ສາຍໂທເຂົ້າ',
          call.callerName,
          call.channelId,
          call.token,
          null);
    } catch (e) {
      print(e.message);
    }
  }
}
