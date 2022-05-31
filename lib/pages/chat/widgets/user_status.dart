import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/utils/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserStatus extends StatelessWidget  {
  String phone;

  UserStatus({
   @required this.phone
});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection(USERS).doc(phone).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data.data()['state'] == 1) {
              return Text(
                'online',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 10.0, color: Colors.white),
              );
            } else if (snapshot.data.data()['state'] == 0) {
              return Text(
                'offline',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 10.0, color: Colors.white),
              );
            } else {
              if (snapshot.data.data()[LAST_SEEN] == true) {
                return Text(
                  'online',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 10.0, color: Colors.white),
                );
              } else {
                return Text(
                  getPeerStatus(snapshot.data.data()[LAST_SEEN]),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 10.0, color: Colors.white),
                );
              }
            }
          }
          return Text(
            'ກຳລັງກວດສອບ',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 10.0, color: Colors.white),
          );
    });
  }

  getPeerStatus(val) {
    if (val is bool && val == true) {
      return 'online';
    } else if (val is int) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
      String at = DateFormat.jm().format(date), when = getWhen(date);
      return 'ອອນລາຍ $when ເວລາ $at';
    } else if (val is String) {
      if (val == Global.firePhone(G.loggedInUser.phone)) return 'typing…';
      return 'online';
    }
    return 'loading…';
  }

  getWhen(date) {
    DateTime now = DateTime.now();
    String when;
    if (date.day == now.day)
      when = 'ມື້ນີ້';
    else if (date.day == now.subtract(Duration(days: 1)).day)
      when = 'ມື້ວານນີ້';
    else
      when = DateFormat.MMMd().format(date);
    return when;
  }
}
