import 'dart:async';
import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/transfer/transfer.dart';
import 'package:OCWA/pages/transfer/transfer_completed.dart';
import 'package:OCWA/ui/dialog/loading.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

Services services = new StorageServiceSharedPreferences();

class TransferConfirm extends StatefulWidget {
  Transaction selectedContact;
  TransferConfirm({Key key, @required this.selectedContact}) : super(key: key);
  @override
  _TransferConfirmItemState createState() => new _TransferConfirmItemState();
}

class _TransferConfirmItemState extends State<TransferConfirm> {
  final formatter = new NumberFormat("#,###");
  TextEditingController textEditingController = TextEditingController();
  String pinCode = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
          title: const Text(
            'ຢືນຢັນ',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w200,
            ),
          ),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView(children: <Widget>[
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            decoration: BoxDecoration(
                color: UIHelper.SPOTIFY_COLOR,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          'ຢືນຢັນການໂອນເງິນ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w200),
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
                'ຊື້ ແລະ ນາມນະກຸນ',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black45,
                    fontWeight: FontWeight.normal),
              ),
              subtitle: Text(
                widget.selectedContact.name,
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
                'ໄອດີ',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.normal),
              ),
              subtitle: Text(
                widget.selectedContact.toAccountId,
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
                'ຈຳນວນເງິນ',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black45,
                    fontWeight: FontWeight.normal),
              ),
              subtitle: Text(
                formatter.format(widget.selectedContact.amount),
                style: TextStyle(
                    color: UIHelper.SPOTIFY_COLOR,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
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
                'ຈຸດປະສົງ',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black45,
                    fontWeight: FontWeight.normal),
              ),
              subtitle: Text(
                widget.selectedContact.remark,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w200),
              ),
            ),
          )
        ]),
      ),
      persistentFooterButtons: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: FlatButton(
                onPressed: () async {
                  //navigator(context, TransferCompleted())
                  confirm(context);
                },
                color: UIHelper.SPOTIFY_COLOR,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Text(
                      "ຢືນຢັນ      ",
                      style: TextStyle(fontSize: 20),
                    ),
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
    final String personalCode = await confirmDialog(context);

    if (personalCode != null && personalCode != "") {
      final data = jsonEncode({
        "sourceId": await services.getValue("id"),
        "remark": widget.selectedContact.remark,
        "amount": widget.selectedContact.amount,
        "destinationId": widget.selectedContact.destinationId,
        "fromId": await services.getValue(ACCOUNT_ID),
        "toId": widget.selectedContact.toAccountId
      });
      final ProgressDialog pr = ProgressDialog(
          context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: true);
      try {
        await pr.show();
        pr.update(message: 'ກຳລັງດຳເນີນ...');
        final result2 = await NetworkUtil.post(
            '/validate-wallet',
            jsonEncode(
                {
                  "id": await services.getValue("id"),
                  "passcode": personalCode
                }));
        await pr.hide();
        if (result2.status == 'success') {
          if (result2.data == "1") {
            await pr.show();
            pr.update(message: 'ກຳລັງດຳເນີນ...');
            final result = await NetworkUtil.post('/transfer', data);
            await pr.hide();
            if (result.status == "success") {
              final tmp = result.data.toString().split("|");
              widget.selectedContact.id = tmp[0];
              widget.selectedContact.created = tmp[1];
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TransferCompleted(
                              transaction: widget.selectedContact)));
            } else {
              Alert.error(context, result.status, result.message, "OK");
            }
          } else {
            Alert.error(context, 'ແຈ້ງເຕືອນ', 'ລະຫັດສ່ວນຕົວບໍ່ຖືກຕ້ອງ', "OK");
          }
        }
      } catch (e) {
        await pr.hide();
        Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), "OK");
      }
    }
  }

  Future<String> confirmDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: _dialogContent(context),
        );
      },
    );
  }

  _dialogContent(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            width: _screenWidth >= 600 ? 500 : _screenWidth,
            padding: EdgeInsets.only(
              top: 45.0 + 16.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            margin: EdgeInsets.only(top: 55.0),
            decoration: new BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(
                  'ຢືນຢັນ',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Text(
                      'ກະລຸນາປ້ອນລະຫັດສ່ວນຕົວຂອງທ່ານເພື່ອຢືນຢັນ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: PinEntryTextField(
                    isTextObscure: true,
                    showFieldAsBox: true,
                    onSubmit: (String pin) {
                      pinCode = pin; //end showDialog()
                    }, // end onSubmit
                  ),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text('ຢືນຢັນ'),
                        color: UIHelper.SPOTIFY_COLOR,
                        onPressed: () {
                          if (pinCode.isEmpty) {
                            Alert.info(context, 'ແຈ້ງເຕືອນ',
                                'ກະລຸນາປ້ອນລະຫັດຢືນຢັນ', 'OK');
                            return;
                          } else {
                            Navigator.of(context).pop(pinCode);
                          }
                        },
                      ),
                      FlatButton(
                        child: Text('ຍົກເລີກ'),
                        color: UIHelper.AVOCADOS_SECONDARY_COLOR,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            child: CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 55.0,
              child: Icon(
                Icons.help_outline,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
