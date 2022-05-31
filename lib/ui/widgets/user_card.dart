import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/pages/transfer/transfer.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:OCWA/models/user_model.dart';

class UserCardWidget extends StatelessWidget {
  final TransferHistoryModel user;
  const UserCardWidget({Key key, this.user})
      : assert(user != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Transfer(transferHistoryModel: user,), fullscreenDialog: true));
      },
      child: Container(
        alignment: Alignment.center,
        width: 100.0,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.lightBlue.shade50,
              blurRadius: 8.0,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.avatar),
              radius: 25,
              backgroundColor: Color(0xfff1f3f5),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                user.firstName,
                style: TextStyle(
                    inherit: true,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0,
                    color: Colors.grey),
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
