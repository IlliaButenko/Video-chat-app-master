import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/topup/card/card_completed.dart';
import 'package:OCWA/pages/transfer/transfer.dart';
import 'package:OCWA/pages/transfer/transfer_completed.dart';
import 'package:OCWA/ui/dialog/loading.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Services services = new StorageServiceSharedPreferences();
class CardConfirm extends StatefulWidget {
  String cardNumber;
  CardConfirm({Key key, this.cardNumber}) : super(key: key);
  @override
  _CardConfirmState createState() => new _CardConfirmState();
}

class _CardConfirmState extends State<CardConfirm> {

  final formatter = new NumberFormat("#,###");
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
          title: const Text('ຢືນຢັນ', style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w200,
          ),),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView(
            children: <Widget>[
              Container(
                height: 100,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                decoration: BoxDecoration(
                    color: UIHelper.SPOTIFY_COLOR,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 10,),
                        Column(
                          children: <Widget>[
                            Text(
                              'ຢືນຢັນການເຕີມເງິນເຂົ້າກະເປົາ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
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
              Container(
                height: 80,
                margin: EdgeInsets.only(bottom: 1, top: 10),
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
                    widget.cardNumber,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.w200),
                  ),
                ),
              ),
              Container(
                height: 80,
                margin: EdgeInsets.only(bottom: 1),
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                    borderRadius: BorderRadius.circular(0)),
                child: ListTile(
                  title: Text(
                    'ມູນຄ່າບັດ',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black45,
                        fontWeight: FontWeight.normal),
                  ),
                  subtitle: Text(
                    formatter.format(200000),
                    style: TextStyle(
                        color: UIHelper.SPOTIFY_COLOR,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
      ),
      persistentFooterButtons: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: FlatButton(
                onPressed: () async {
                  navigator(context, CardCompleted());
//                  confirm(context);
                },
                color: UIHelper.SPOTIFY_COLOR,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Text("ຢືນຢັນ      ", style: TextStyle(fontSize: 20),),
                    Icon(Icons.check_circle_outline)
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  confirm(BuildContext context) async {
    final String personalCode = await _asyncInputDialog(context);

  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    String teamName = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ກະລຸນາປ້ອນລະຫັດສ່ວນຕົວຂອງທ່ານເພື່ອຢືນຢັນການເຕີມເງິນກະເປົາ', style: TextStyle(fontSize: 14),),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: 'ລະຫັດສ່ວນຕົວ', hintText: '****'),
                    onChanged: (value) {
                      teamName = value;
                    },
                  ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('ຢືນຢັນ'),
              onPressed: () {
                Navigator.of(context).pop(teamName);
              },
            ),
            FlatButton(
              child: Text('ຍົກເລີກ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context, String title, String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
