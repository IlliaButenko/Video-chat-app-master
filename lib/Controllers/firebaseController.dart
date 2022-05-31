import 'package:OCWA/enum/user_state.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/utils/functions.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseController {
  static FirebaseController get instance => FirebaseController();

  // Save Image to Storage
  Future<String> saveUserImageToFirebaseStorage(
      userId, userName, userIntro, userImageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(ID, userId);
      await prefs.setString(FULL_NAME, userName);
      await prefs.setString(ABOUT_ME, userIntro);

      String filePath = 'userImages/$userId';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask =
          storageReference.putFile(userImageFile);

      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String imageURL = await storageTaskSnapshot.ref
          .getDownloadURL(); // Image URL from firebase's image file
      String result = await saveUserDataToFirebaseDatabase(
          userId, userName, userIntro, imageURL);
      return result;
    } catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<String> sendImageToUserInChatRoom(croppedFile, chatID) async {
    try {
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'chatrooms/$chatID/$imageTimeStamp';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask =
          storageReference.putFile(croppedFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String result = await storageTaskSnapshot.ref.getDownloadURL();
      return result;
    } catch (e) {
      print(e.message);
    }
  }

  // About Firebase Database
  Future<String> saveUserDataToFirebaseDatabase(
      userId, userName, userIntro, downloadUrl) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(USERS)
          .where('FCMToken', isEqualTo: prefs.get('FCMToken'))
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      String myID = userId;
      if (documents.length == 0) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          ID: userId,
          FULL_NAME: userName,
          ABOUT_ME: userIntro,
          PHOTO_URL: downloadUrl,
          CREATED: DateTime.now().millisecondsSinceEpoch,
          'FCMToken': prefs.get('FCMToken') ?? 'NOToken',
        });
      } else {
        String userID = documents[0].data()[ID];
        myID = userID;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(ID, myID);
        await FirebaseFirestore.instance.collection(USERS).doc(userID).update({
          FULL_NAME: userName,
          ABOUT_ME: userIntro,
          PHOTO_URL: downloadUrl,
          CREATED: DateTime.now().millisecondsSinceEpoch,
          'FCMToken': prefs.get('FCMToken') ?? 'NOToken',
        });
      }
      return myID;
    } catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<void> updateUserToken(userID, token) async {
    await FirebaseFirestore.instance.collection('users').doc(userID).set({
      'FCMToken': token,
    }, SetOptions(merge: true));
  }

  Future<List<DocumentSnapshot>> takeUserInformationFromFBDB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(USERS)
        .where('FCMToken', isEqualTo: prefs.get('FCMToken') ?? 'None')
        .get();
    return result.docs;
  }

  Future<int> getUnreadMSGCount([String peerUserID]) async {
    try {
      int unReadMSGCount = 0;
      String targetID = '';
      SharedPreferences prefs = await SharedPreferences.getInstance();

      peerUserID == null
          ? targetID = (prefs.get(ID) ?? 'NoId')
          : targetID = peerUserID;
      final QuerySnapshot chatListResult = await FirebaseFirestore.instance
          .collection(USERS)
          .doc(targetID)
          .collection('chatlist')
          .get();
      final List<DocumentSnapshot> chatListDocuments = chatListResult.docs;
      for (var data in chatListDocuments) {
        final QuerySnapshot unReadMSGDocument = await FirebaseFirestore.instance
            .collection('chatroom')
            .doc(data.data()['chatID'])
            .collection(data.data()['chatID'])
            .where('idTo', isEqualTo: targetID)
            .where('isRead', isEqualTo: false)
            .get();

        final List<DocumentSnapshot> unReadMSGDocuments =
            unReadMSGDocument.docs;
        unReadMSGCount = unReadMSGCount + unReadMSGDocuments.length;
      }

      print('unread MSG count is $unReadMSGCount');

      if (peerUserID != null && peerUserID != G.loggedInId.toString()) {
        return unReadMSGCount;
      } else {
        if (peerUserID == G.loggedInId.toString()) {
          FlutterAppBadger.updateBadgeCount(unReadMSGCount);
        }
        return unReadMSGCount;
      }
    } catch (e) {
      print(e.message);
    }
  }

  Future updateChatRequestField(String documentID, String lastMessage, chatID,
      myID, selectedUserID, type, me) async {
    await FirebaseFirestore.instance
        .collection(USERS)
        .doc(documentID)
        .collection('chatlist')
        .doc(chatID)
        .set({
      'chatID': chatID,
      'chatWith': me ? selectedUserID : myID,
      'lastChat': lastMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': type
    });
  }

  Future<int> sendMessageToChatRoom(
      chatID, myID, selectedUserID, content, messageType, thumbnail) async {
    var id = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatID)
        .collection(chatID)
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set({
      'idFrom': myID,
      'idTo': selectedUserID,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'content': content,
      'thumbnail': thumbnail,
      'type': messageType,
      'isRead': false,
      'isDeliver': false,
      'isSend': false,
      'transferStatus': messageType == 'transfer' ? 'sent' : ''
    });
    return id;
  }

  Future updateChatRoomStatus(
      chatID, messageID, status) async {
    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatID)
        .collection(chatID)
        .doc(messageID)
        .set({
      'isDeliver': status,
    }, SetOptions(merge: true));
  }

  Future updateChatRoomTransferStatus(
      chatID, messageID, status, transactionID, transactionDate) async {
    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatID)
        .collection(chatID)
        .doc(messageID)
        .set({
      'transferStatus': status,
      'transactionID': transactionID,
      'transactionDate': transactionDate
    }, SetOptions(merge: true));
  }

  Future updateUserProfile(
      id, firstName, lastName, email) async {
    await FirebaseFirestore.instance
        .collection(USERS)
        .doc(Global.firePhone(G.loggedInUser.phone))
        .set({
      FIRST_NAME: firstName,
      LAST_NAME: lastName,
      FULL_NAME: getFullName(firstName, lastName),
      EMAIL_APP: email
    }, SetOptions(merge: true));
  }

  Future updateUserAvatar(avatar) async {
    await FirebaseFirestore.instance
        .collection(USERS)
        .doc(Global.firePhone(G.loggedInUser.phone))
        .set({
      PHOTO_URL: avatar
    }, SetOptions(merge: true));
  }

  Future cancelChatRoomTransferStatus(
      chatID, messageID, status, transactionDate) async {
    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatID)
        .collection(chatID)
        .doc(messageID)
        .set({
      'transferStatus': status,
      'transactionDate': transactionDate
    }, SetOptions(merge: true));
  }

  Future<String> getUserToken(String phone) async {
    phone = "+" + Global.getPhone(phone);
    final DocumentSnapshot user = await FirebaseFirestore.instance
        .collection(USERS)
        .doc(phone)
        .get();
    if (user.exists) {
      return user.data()['FCMToken'];
    }
    return null;
  }

  Future<bool> deleteChat() {

  }

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    FirebaseFirestore.instance.collection(USERS).doc(userId).update({
      "state": stateNum,
    });
  }
}
