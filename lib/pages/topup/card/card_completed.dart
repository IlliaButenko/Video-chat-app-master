import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/dasboard/dasboard.dart';
import 'package:OCWA/pages/home.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardCompleted extends StatefulWidget {
  @override
  _CardCompletedState createState() => new _CardCompletedState();
}

class _CardCompletedState extends State<CardCompleted> {
  bool _canSave = false;
  final formatter = new NumberFormat("#,###");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 100,
                width: double.infinity,
                padding: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                    color: UIHelper.SPOTIFY_COLOR,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              'ເຕີມເງິນເຂົ້າກະເປົາສຳເລັດ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w200
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView(
                    padding: const EdgeInsets.only(top: 10.0),
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 8.00),
                            child: Text(Global.dateOnly('2020-06-20 12:20:00')),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 8.00),
                            child: Text(Global.timeAndSec('2020-06-20 12:20:00')),
                          )
                        ],
                      ),
                      Container(
                        height: 140,
                        alignment: AlignmentDirectional.center,
                        child: Image.asset("assets/images/check.png"),
                      ),
                      Container(
                        height: 75,
                        margin: EdgeInsets.only(bottom: 1, top: 10),
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: ListTile(
                          title: Text(
                            'ໝາຍເລກອ້າງອີງ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '39205830993',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: UIHelper.STRAWBERRY_SECONDARY_COLOR,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        height: 75,
                        margin: EdgeInsets.only(bottom: 1),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                            borderRadius: BorderRadius.circular(0)),
                        child: ListTile(
                          title: Text(
                            'ເລກບັດ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black45,
                                fontWeight: FontWeight.normal),
                          ),
                          subtitle: Text(
                            '9353905820395',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.w200),
                          ),
                        ),
                      ),
                      Container(
                        height: 75,
                        margin: EdgeInsets.only(bottom: 1),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                            borderRadius: BorderRadius.circular(0)),
                        child: ListTile(
                          title: Text(
                            'ເງິນເຂົ້າກະເປົາ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black45,
                                fontWeight: FontWeight.normal),
                          ),
                          subtitle: Text(
                            formatter.format(200000),
                            style: TextStyle(
                                color: UIHelper.SPOTIFY_COLOR,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          )),
      persistentFooterButtons: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: FlatButton(
                onPressed: () => {
                  navigator(context, Home(widget: Dashboard(), tab: 1,))
                },
                color: UIHelper.SPOTIFY_COLOR,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Icon(Icons.home),
                    Text("ສຳເລັດ", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
