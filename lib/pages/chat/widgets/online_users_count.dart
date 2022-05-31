import 'package:OCWA/Controllers/utils.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OnlineUsersCount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(USERS)
            .where('state', isEqualTo: 1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container();
          if (snapshot.hasData && snapshot.data.docs.length > 0) {
            if (countUsers(G.loggedInUser.id, snapshot) > 0) {
              return Container(
                margin: const EdgeInsets.only(
                    left: 4.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                        Radius.circular(10.0))),
                alignment: Alignment.center,
                height: 18.0,
                width: 18.0,
                child: Text(
                  '${countUsers(G.loggedInUser.id, snapshot)}',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: UIHelper.SPOTIFY_COLOR,
                  ),
                ),
              );
            } else {
              return Container();
            }
          }
          return Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        });
  }
}
