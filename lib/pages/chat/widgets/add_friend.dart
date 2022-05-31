import 'package:OCWA/pages/chat/all_user.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:flutter/material.dart';

class AddFriend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox.fromSize(
                  size: Size(80, 80),
                  // button width and height
                  child: ClipOval(
                    child: Material(
                      color: UIHelper.SPOTIFY_COLOR,
                      // button color
                      child: InkWell(
                        splashColor: Colors.green,
                        // splash color
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AllUser()));
                        },
                        // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.people,
                              color: UIHelper.WHITE,
                            ),
                            // icon
                            Text(
                              "ເພີ່ມເພື່ອນ",
                              style: TextStyle(color: UIHelper.WHITE),
                            ),
                            // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  'ທ່ານຍັງບໍ່ມີເພື່ອນ',
                  style: TextStyle(color: UIHelper.SPOTIFY_COLOR),
                )
              ])),
    );
  }
}
