import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'firebaseController.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    print('myBackgroundMessageHandler data');
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    print('myBackgroundMessageHandler notification');
    final dynamic notification = message['notification'];
  }
  // Or do other work.
}

class NotificationController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static NotificationController get instance => NotificationController();

  Future takeFCMTokenWhenAppLaunch() async {
    try {
      if (Platform.isIOS) {
        _firebaseMessaging.requestNotificationPermissions(
            IosNotificationSettings(sound: true, badge: true, alert: true));
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userToken = prefs.get('FCMToken');
      if (userToken == null) {
        _firebaseMessaging.getToken().then((val) async {
          prefs.setString('FCMToken', val);
          String userID = prefs.get(PHONE);
          if (userID != null) {
            FirebaseController.instance.updateUserToken(userID, val);
          }
        });
      }

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          String msg = 'notibody';
          String name = 'chatapp';
          if (Platform.isIOS) {
            msg = message['aps']['alert']['body'];
            name = message['aps']['alert']['title'];
          } else {
            msg = message['notification']['body'];
            name = message['notification']['title'];
          }

          String currentChatRoom = (prefs.get('currentChatRoom') ?? 'None');

          if (Platform.isIOS) {
            if (message['chatroomid'] != currentChatRoom) {
              sendLocalNotification(name, msg, message);
            }
          } else {
            if (message['data']['chatroomid'] != currentChatRoom) {
              sendLocalNotification(name, msg, message);
            }
          }

          FirebaseController.instance.getUnreadMSGCount();
        },
        onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );
    } catch (e) {
      print(e.message);
    }
  }

  Future initLocalNotification() async {
    if (Platform.isIOS) {
      // set iOS Local notification.
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    } else {
      // set Android Local notification.
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    }
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  Future _selectNotification(String payload) async {
    FlutterRingtonePlayer.stop();
    print("Payload: $payload");
    var data = jsonDecode(payload);
  }

  sendLocalNotification(name, msg, data) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin
        .show(0, name, msg, platformChannelSpecifics, payload: data,);
  }

  // Send a notification message

  Future<void> sendNotificationMessageToPeerUser(unReadMSGCount, messageType,
      textFromTextField, myName, chatID, peerUserToken, msgId) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$firebaseCloudserverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
//          'notification': <String, dynamic>{
//            'body': getType(messageType, textFromTextField),
//            'title': '$myName',
//            'badge':'$unReadMSGCount',//'$unReadMSGCount'
//            "sound" : "default",
//            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'chatroomid': chatID,
            'msg_id': msgId,
            'msg_type': messageType,
            'body': getType(messageType, textFromTextField),
            'title': '$myName',
            'user_id': G.loggedInUser.id,
            'username': G.loggedInUser.name,
            'token': peerUserToken,
            'avatar': G.loggedInUser.avatar,
            'badge': '$unReadMSGCount', //'$unReadMSGCount'
            "sound": "default",
          },
          'to': peerUserToken,
          'android': {
            'notification': {
              'channel_id': 'fcm_default_channel',
            },
          },
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }

  String getType(type, text) {
    switch (type) {
      case 'image':
        type = '(ຮູບພາບ)';
        break;
      case 'video':
        type = '(ວິດີໂອ)';
        break;
      case 'transfer':
        type = '(ເງິນໂອນ)';
        break;
      case 'voice':
        type = '(ຂໍ້ຄວາມສຽງ)';
        break;
      case 'call':
        type = 'ສາຍໂທເຂົ້າ';
        break;
      case 'text':
        type = text;
        break;
      default:
        type = text;
        break;
    }
    return type;
  }
}
