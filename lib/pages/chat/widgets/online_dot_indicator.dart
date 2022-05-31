import 'package:OCWA/pages/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:OCWA/enum/user_state.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/utils/utilities.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String phone;

  OnlineDotIndicator({
    @required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection(USERS).doc(phone).snapshots(),
        builder: (context, snapshot) {
          UserModel user;

          if (snapshot.hasData && snapshot.data.data() != null) {
            user = UserModel.fromJson(snapshot.data.data());
          }

          return Container(
            height: 10,
            width: 10,
            margin: EdgeInsets.only(right: 5, top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(user?.state),
            ),
          );
        },
      ),
    );
  }
}
