import 'package:OCWA/Controllers/utils.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/chat/message.dart';
import 'package:OCWA/pages/chat/widgets/quiet_box.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'cached_image.dart';
import 'online_dot_indicator.dart';

class OnlineUsers extends StatefulWidget {
  String phone;

  OnlineUsers({this.phone});

  @override
  _OnlineUsersState createState() => _OnlineUsersState();
}

class _OnlineUsersState extends State<OnlineUsers> {

  Future<void> _moveTochatRoom(selectedUserToken, selectedUserID,
      selectedUserName, selectedUserThumbnail, selectedPhone) async {
    try {
      String chatID = makeChatId(G.loggedInId, selectedUserID);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Messages(
                  G.loggedInId,
                  G.loggedInUser.name,
                  selectedUserToken,
                  int.parse(selectedUserID),
                  chatID,
                  selectedUserName,
                  selectedUserThumbnail,
                  selectedPhone)));
    } catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(USERS)
            .where('state', isEqualTo: 1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
              color: Colors.white.withOpacity(0.7),
            );
          return (snapshot.hasData && snapshot.data.docs.length > 0)
              ? ListView(
                  children: snapshot.data.docs.map((data) {
                  if (data.data()[ID] == G.loggedInId.toString() || data.data()[FULL_NAME] == null) {
                    return Container();
                  } else {
                    return GestureDetector(
                      onTap: () {
                        _moveTochatRoom(
                            data.data()['FCMToken'],
                            data.data()[ID],
                            data.data()[FULL_NAME],
                            data.data()[PHOTO_URL],
                            data.data()[PHONE]);
                      },
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.only(left: 10.0),
                        decoration: BoxDecoration(
                            color: UIHelper.WHITE,
                            borderRadius: BorderRadius.circular(0)),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CachedImage(
                                      data.data()[PHOTO_URL],
                                    radius: 60,
                                    isRound: true,
                                  ),
                                  OnlineDotIndicator(
                                    phone: data.data()[PHONE],
                                  )
                                ]
                              ),
                            ),
                            SizedBox(width: 6.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.data()[FULL_NAME] != null ? data.data()[FULL_NAME] : '',
                                  style: TextStyle(
                                    color: UIHelper.THEME_PRIMARY,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text("@",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: UIHelper.SPOTIFY_COLOR)),
                              ],
                            )

                          ],
                        ),
                      ),
                    );
                  }
                }).toList())
              : QuietBox(
                  heading: "ບໍ່ມີເພື່ອນອອນລາຍ",
                  subtitle: "",
                );
        });
  }
}
