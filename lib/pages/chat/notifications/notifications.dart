import 'dart:async' show Future;

import 'dart:io' show File;

import 'dart:typed_data' show Int64List;

import 'dart:ui' show Color, FontWeight, Radius, VoidCallback;

import 'package:OCWA/pages/chat/notifications/schedule_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

NotificationAppLaunchDetails notificationAppLaunchDetails;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  ScheduleNotifications notifications;

  @override
  void initState() {
    super.initState();

    notifications = ScheduleNotifications(
      'your channel id',
      'your other channel name',
      'your other channel description',
    );

    notifications.init(onSelectNotification: (String payload) async {
      if (payload == null || payload.trim().isEmpty) return null;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SecondScreen(payload)),
      );
      return;
    });

    notifications.getNotificationAppLaunchDetails().then((details) {
      notificationAppLaunchDetails = details;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                  child: Text(
                      'Tap on a notification when it appears to trigger navigation'),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Did notification launch app? ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              '${notificationAppLaunchDetails?.didNotificationLaunchApp ?? false}',
                        )
                      ],
                    ),
                  ),
                ),
                if (notificationAppLaunchDetails?.didNotificationLaunchApp ??
                    false)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Launch notification payload: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: notificationAppLaunchDetails.payload,
                          )
                        ],
                      ),
                    ),
                  ),
                _PaddedRaisedButton(
                  buttonText: 'Show plain notification with payload',
                  onPressed: () => notifications.show(
                    id: 0,
                    importance: Importance.Max,
                    priority: Priority.High,
                    ticker: 'ticker',
                    title: 'plain title',
                    body: 'plain body',
                    payload: 'item x',
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Show plain notification that has no body with payload',
                  onPressed: () => notifications.show(
                    id: 0,
                    importance: Importance.Max,
                    priority: Priority.High,
                    ticker: 'ticker',
                    title: 'no body title',
                    payload: 'item x',
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Show plain notification with payload and update channel description [Android]',
                  onPressed: () => notifications.show(
                    id: 0,
                    title: 'updated notification channel',
                    body: 'check settings to see updated channel description',
                    payload: 'item x',
                    importance: Importance.Max,
                    priority: Priority.High,
                    channelAction: AndroidNotificationChannelAction.Update,
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Show plain notification as public on every lockscreen [Android]',
                  onPressed: () => notifications.show(
                    id: 0,
                    title: 'public notification title',
                    body: 'public notification body',
                    payload: 'item x',
                    importance: Importance.Max,
                    priority: Priority.High,
                    ticker: 'ticker',
                    visibility: NotificationVisibility.Public,
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText: 'Cancel notification',
                  onPressed: () => notifications.cancel(0),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Schedule notification to appear in 5 seconds, custom sound, red colour, large icon, red LED',
                  onPressed: () async {
                    //
                    var vibrationPattern = Int64List(4);
                    vibrationPattern[0] = 0;
                    vibrationPattern[1] = 1000;
                    vibrationPattern[2] = 5000;
                    vibrationPattern[3] = 2000;

                    var id = notifications.schedule(
                      DateTime.now().add(Duration(seconds: 5)),
                      title: 'scheduled title',
                      body: 'scheduled body',
                      sound: RawResourceAndroidNotificationSound(
                          'slow_spring_board'),
                      largeIcon:
                          DrawableResourceAndroidBitmap('sample_large_icon'),
                      vibrationPattern: vibrationPattern,
                      enableLights: true,
                      color: const Color.fromARGB(255, 255, 0, 0),
                      ledColor: const Color.fromARGB(255, 255, 0, 0),
                      ledOnMs: 1000,
                      ledOffMs: 500,
                      soundFile: 'slow_spring_board.aiff',
                    );
                    return id;
                  },
                ),
                Text(
                    'NOTE: red colour, large icon and red LED are Android-specific'),
                _PaddedRaisedButton(
                  buttonText: 'Repeat notification every minute',
                  onPressed: () => notifications.periodicallyShow(
                    RepeatInterval.EveryMinute,
                    id: 0,
                    title: 'repeating title',
                    body: 'repeating body',
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Repeat notification every day at approximately 10:00:00 am',
                  onPressed: () => notifications.showDailyAtTime(
                    Time(15, 0, 0),
                    id: 0,
                    title: 'show daily title',
                    body:
                        'Daily notification shown at approximately ${Time(15, 0, 0).hour.toString().padLeft(2, '0')}:${Time(15, 0, 0).minute.toString().padLeft(2, '0')}:${Time(15, 0, 0).second.toString().padLeft(2, '0')}',
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Repeat notification weekly on Monday at approximately 10:00:00 am',
                  onPressed: () => notifications.showWeeklyAtDayAndTime(
                    Day.Monday,
                    Time(10, 0, 0),
                    id: 0,
                    title: 'show weekly title',
                    body:
                        'Weekly notification shown on Monday at approximately ${Time(10, 0, 0).hour.toString().padLeft(2, '0')}:${Time(10, 0, 0).minute.toString().padLeft(2, '0')}:${Time(10, 0, 0).second.toString().padLeft(2, '0')}',
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show notification with no sound',
                  onPressed: () => notifications.show(
                    title: '<b>silent</b> title',
                    body: '<b>silent</b> body',
                    playSound: false,
                    styleInformation: DefaultStyleInformation(true, true),
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Show notification that times out after 3 seconds [Android]',
                  onPressed: () => notifications.show(
                    timeoutAfter: 30000,
                    styleInformation: DefaultStyleInformation(true, true),
                    title: 'timeout notification',
                    body: 'Times out after 3 seconds',
                    payload: 'item x',
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show big picture notification [Android]',
                  onPressed: () async {
                    //
                    var largeIconPath = await _downloadAndSaveFile(
                        'http://via.placeholder.com/48x48', 'largeIcon');

                    var bigPicturePath = await _downloadAndSaveFile(
                        'http://via.placeholder.com/400x800', 'bigPicture');

                    var bigPictureStyleInformation = BigPictureStyleInformation(
                        FilePathAndroidBitmap(bigPicturePath),
                        largeIcon: FilePathAndroidBitmap(largeIconPath),
                        contentTitle: 'overridden <b>big</b> content title',
                        htmlFormatContentTitle: true,
                        summaryText: 'summary <i>text</i>',
                        htmlFormatSummaryText: true);

                    notifications.show(
                      id: 0,
                      title: 'big text title',
                      body: 'silent body',
                      styleInformation: bigPictureStyleInformation,
                    );
                  },
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Show big picture notification, hide large icon on expand [Android]',
                  onPressed: () async {
                    //
                    var largeIconPath = await _downloadAndSaveFile(
                        'http://via.placeholder.com/48x48', 'largeIcon');

                    var bigPicturePath = await _downloadAndSaveFile(
                        'http://via.placeholder.com/400x800', 'bigPicture');

                    var bigPictureStyleInformation = BigPictureStyleInformation(
                        FilePathAndroidBitmap(bigPicturePath),
                        hideExpandedLargeIcon: true,
                        contentTitle: 'overridden <b>big</b> content title',
                        htmlFormatContentTitle: true,
                        summaryText: 'summary <i>text</i>',
                        htmlFormatSummaryText: true);

                    notifications.show(
                      id: 0,
                      title: 'big text title',
                      body: 'silent body',
                      largeIcon: FilePathAndroidBitmap(largeIconPath),
                      styleInformation: bigPictureStyleInformation,
                    );
                  },
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show media notification [Android]',
                  onPressed: () async {
//
                    var largeIconPath = await _downloadAndSaveFile(
                        'http://via.placeholder.com/128x128/00FF00/000000',
                        'largeIcon');

                    notifications.show(
                      id: 0,
                      title: 'notification title',
                      body: 'notification body',
                      largeIcon: FilePathAndroidBitmap(largeIconPath),
                      styleInformation: MediaStyleInformation(),
                    );
                  },
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show big text notification [Android]',
                  onPressed: () async {
                    //
                    var bigTextStyleInformation = BigTextStyleInformation(
                        'Lorem <i>ipsum dolor sit</i> amet, consectetur <b>adipiscing elit</b>, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                        htmlFormatBigText: true,
                        contentTitle: 'overridden <b>big</b> content title',
                        htmlFormatContentTitle: true,
                        summaryText: 'summary <i>text</i>',
                        htmlFormatSummaryText: true);

                    notifications.show(
                      id: 0,
                      title: 'notification title',
                      body: 'notification body',
                      styleInformation: bigTextStyleInformation,
                    );
                  },
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show inbox notification [Android]',
                  onPressed: () async {
                    //
                    List<String> lines = [];

                    lines.add('line <b>1</b>');

                    lines.add('line <i>2</i>');

                    var inboxStyleInformation = InboxStyleInformation(lines,
                        htmlFormatLines: true,
                        contentTitle: 'overridden <b>inbox</b> context title',
                        htmlFormatContentTitle: true,
                        summaryText: 'summary <i>text</i>',
                        htmlFormatSummaryText: true);

                    notifications.show(
                      id: 0,
                      title: 'notification title',
                      body: 'notification body',
                      styleInformation: inboxStyleInformation,
                    );
                  },
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show grouped notifications [Android]',
                  onPressed: () async {
                    //
                    var groupKey = 'com.android.example.WORK_EMAIL';

                    // example based on https://developer.android.com/training/notify-user/group.html

                    notifications.show(
                      id: 1,
                      title: 'Alex Faarborg',
                      body: 'You will not believe...',
                      importance: Importance.Max,
                      priority: Priority.High,
                      groupKey: groupKey,
                    );

                    notifications.show(
                      id: 2,
                      title: 'Jeff Chang',
                      body: 'Please join us to celebrate the...',
                      importance: Importance.Max,
                      priority: Priority.High,
                      groupKey: groupKey,
                    );

                    // create the summary notification to support older devices that pre-date Android 7.0 (API level 24).
                    // this is required is regardless of which versions of Android your application is going to support
                    var lines = List<String>();

                    lines.add('Alex Faarborg  Check this out');

                    lines.add('Jeff Chang    Launch Party');

                    var inboxStyleInformation = InboxStyleInformation(lines,
                        contentTitle: '2 messages',
                        summaryText: 'janedoe@example.com');

                    notifications.show(
                      id: 0,
                      title: 'group notification title',
                      body: 'group notification body',
                      styleInformation: inboxStyleInformation,
                      groupKey: groupKey,
                      setAsGroupSummary: true,
                    );
                  },
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show ongoing notification [Android]',
                  onPressed: () => notifications.show(
                      id: 0,
                      title: 'ongoing notification title',
                      body: 'ongoing notification body',
                      importance: Importance.Max,
                      priority: Priority.High,
                      ongoing: true,
                      autoCancel: false),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Show notification with no badge, alert only once [Android]',
                  onPressed: () => notifications.show(
                    id: 0,
                    channelShowBadge: false,
                    importance: Importance.Max,
                    priority: Priority.High,
                    onlyAlertOnce: true,
                    title: 'no badge title',
                    body: 'no badge body',
                    payload: 'item x',
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText:
                      'Show progress notification - updates every second [Android]',
                  onPressed: () async {
                    var maxProgress = 5;

                    for (var i = 0; i <= maxProgress; i++) {
                      await Future.delayed(Duration(seconds: 1), () async {
                        notifications.show(
                            id: 0,
                            title: 'progress notification title',
                            body: 'progress notification body',
                            payload: 'item x',
                            channelShowBadge: false,
                            importance: Importance.Max,
                            priority: Priority.High,
                            onlyAlertOnce: true,
                            showProgress: true,
                            maxProgress: maxProgress,
                            progress: i);
                      });
                    }
                  },
                ),
                _PaddedRaisedButton(
                    buttonText:
                        'Show indeterminate progress notification [Android]',
                    onPressed: () => notifications.show(
                          id: 0,
                          title: 'indeterminate progress notification title',
                          body: 'indeterminate progress notification body',
                          payload: 'item x',
                          channelShowBadge: false,
                          importance: Importance.Max,
                          priority: Priority.High,
                          onlyAlertOnce: true,
                          showProgress: true,
                          indeterminate: true,
                        )),
                _PaddedRaisedButton(
                  buttonText: 'Check pending notifications',
                  onPressed: () async {
                    //
                    var pendingNotificationRequests =
                        await notifications.pendingNotificationRequests();

                    for (var pendingNotificationRequest
                        in pendingNotificationRequests) {
                      debugPrint(
                          'pending notification: [id: ${pendingNotificationRequest.id}, title: ${pendingNotificationRequest.title}, body: ${pendingNotificationRequest.body}, payload: ${pendingNotificationRequest.payload}]');
                    }

                    return showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                              '${pendingNotificationRequests.length} pending notification requests'),
                          actions: [
                            FlatButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                _PaddedRaisedButton(
                  buttonText: 'Cancel all notifications',
                  onPressed: () => notifications.cancelAll(),
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show notification with icon badge [iOS]',
                  onPressed: () => notifications.show(
                    id: 0,
                    title: 'icon badge title',
                    body: 'icon badge body',
                    payload: 'item x',
                    badgeNumber: 1,
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show notification without timestamp [Android]',
                  onPressed: () => notifications.show(
                    id: 0,
                    title: 'No Show When title',
                    body: 'No Show When body',
                    payload: 'item x',
                    importance: Importance.Max,
                    priority: Priority.High,
                    showWhen: false,
                  ),
                ),
                _PaddedRaisedButton(
                  buttonText: 'Show notification with attachment [iOS]',
                  onPressed: () async {
                    //
                    var bigPicturePath = await _downloadAndSaveFile(
                        'http://via.placeholder.com/600x200', 'bigPicture.jpg');

                    var bigPictureAndroidStyle = BigPictureStyleInformation(
                        FilePathAndroidBitmap(bigPicturePath));

                    notifications.show(
                      id: 0,
                      title: 'notification with attachment title',
                      body: 'notification with attachment body',
                      importance: Importance.High,
                      priority: Priority.High,
                      styleInformation: bigPictureAndroidStyle,
                      attachments: [IOSNotificationAttachment(bigPicturePath)],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

class _PaddedRaisedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const _PaddedRaisedButton({
    @required this.buttonText,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: RaisedButton(child: Text(buttonText), onPressed: onPressed),
    );
  }
}

class SecondScreen extends StatefulWidget {
  SecondScreen(this.payload);

  final String payload;

  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen with payload: ${(_payload ?? '')}'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
