import 'package:OCWA/Controllers/utils.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UnReadCount extends StatefulWidget {
  @override
  _UnReadCountState createState() => _UnReadCountState();
}

class _UnReadCountState extends State<UnReadCount> with TickerProviderStateMixin {
  AnimationController unreadChatsBadgeAnimationController;

  Animation unreadChatsBadgeAnimation;

  @override
  void initState() {
    super.initState();
    unreadChatsBadgeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1),
    );
    unreadChatsBadgeAnimation = Tween(
      begin: 1.0,
      end: 0.7,
    ).animate(unreadChatsBadgeAnimationController);
  }

  @override
  void dispose() {
    super.dispose();
    unreadChatsBadgeAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(USERS)
          .doc(Global.firePhone(G.loggedInUser.phone))
          .collection('chatlist')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return FutureBuilder(
            future: countUnreadMessage(snapshot),
            builder: (context, countSnapshot) {
              if (!countSnapshot.hasData ||
                  countSnapshot.data == 0)
                return Container();
              return FadeTransition(
                opacity: unreadChatsBadgeAnimation,
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 4.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                          Radius.circular(9.0))),
                  alignment: Alignment.center,
                  height: 18.0,
                  width: 18.0,
                  child: Text(
                    '${countSnapshot.data}',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: UIHelper.SPOTIFY_COLOR,
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
