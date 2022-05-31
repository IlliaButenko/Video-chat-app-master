import 'dart:math';

import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// For Chatlist Functions
String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
    if (diff.inHours > 0) {
      time = diff.inHours.toString() + 'h ago';
    }else if (diff.inMinutes > 0) {
      time = diff.inMinutes.toString() + 'm ago';
    }else if (diff.inSeconds > 0) {
      time = 'now';
    }else if (diff.inMilliseconds > 0) {
      time = 'now';
    }else if (diff.inMicroseconds > 0) {
      time = 'now';
    }else {
      time = 'now';
    }
  } else if (diff.inDays > 0 && diff.inDays < 7) {
      time = diff.inDays.toString() + 'd ago';
  } else if (diff.inDays > 6){
      time = (diff.inDays / 7).floor().toString() + 'w ago';
  }else if (diff.inDays > 29) {
      time = (diff.inDays / 30).floor().toString() + 'm ago';
  }else if (diff.inDays > 365) {
    time = '${date.month}-${date.day}-${date.year}';
  }
  return time;
}

String makeChatId(myID,selectedUserID) {
  String chatID;
  if (myID.toString().hashCode > selectedUserID.toString().hashCode) {
    chatID = '$selectedUserID-$myID';
  }else {
    chatID = '$myID-$selectedUserID';
  }
  return chatID;
}

int countUsers(myID,snapshot) {
  int resultInt = snapshot.data.docs.length;
  for (var data in snapshot.data.docs) {
    if (data.data()[ID] == myID.toString()) {
      resultInt--;
    }
    if (data.data()[FULL_NAME] == null) {
      resultInt--;
    }
  }
  return resultInt;
}

int countChatList(myID,snapshot) {
  int resultInt = snapshot.data.docs.length;
  for (var data in snapshot.data.docs) {
    resultInt++;
  }
  return resultInt;
}

Future<int> countUnreadMessage(snapshot) async {
  int resultInt = 0;
  for (var data in snapshot.data.docs) {
    final QuerySnapshot unReadMSGDocument = await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(data.data()['chatID'])
        .collection(data.data()['chatID'])
        .where('idTo', isEqualTo: G.loggedInId.toString())
        .where('isRead', isEqualTo: false)
        .get();
    final List<DocumentSnapshot> unReadMSGDocuments =
        unReadMSGDocument.docs;
    resultInt = resultInt + unReadMSGDocuments.length;
  }
  return resultInt;
}

// For ChatRoom Functions

String returnTimeStamp(int messageTimeStamp) {
  String resultString = '';
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(messageTimeStamp);
  resultString = format.format(date);
  return resultString;
}

void setCurrentChatRoomID(value) async { // To know where I am in chat room. Avoid local notification.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('currentChatRoom', value);
}

// For main view Functions
String checkValidUserData(userImageFile,userImageUrlFromFB,name,intro) {
  String returnString = '';
  if(userImageFile.path == '' && userImageUrlFromFB == '') {
    returnString = returnString + 'Please select a image.';
  }

  if(name.trim() == '') {
    if(returnString.trim() != '') {
      returnString = returnString + '\n\n';
    }
    returnString = returnString + 'Please type your name';
  }

  if(intro.trim() == '') {
    if(returnString.trim() != '') {
      returnString = returnString + '\n\n';
    }
    returnString = returnString + 'Please type your intro';
  }
  return returnString;
}

String randomIdWithName(userName){
  int randomNumber = Random().nextInt(100000);
  return '$userName$randomNumber';
}