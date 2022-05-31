import 'package:OCWA/pages/transfer/transfer.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigator(context, Transfer());
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.0),
        alignment: Alignment.center,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: UIHelper.SPOTIFY_COLOR,
              ),
              onPressed: () {
                navigator(context, Transfer());
              },
              iconSize: 40.0,
            ),
//            Text(
//              "ເພີ່ມ",
//              style: TextStyle(
//                  inherit: true,
//                  fontWeight: FontWeight.bold,
//                  fontSize: 14.0,
//                  color: Colors.black45),
//              textAlign: TextAlign.center,
//            ),
          ],
        ),
      ),
    );
  }
}
