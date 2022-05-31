import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/transfer/transfer_confirm.dart';
import 'package:OCWA/ui/dialog/transfer_history.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

Services services = new StorageServiceSharedPreferences();

class Transfer extends StatefulWidget {
  TransferHistoryModel transferHistoryModel;
  Transfer({Key key, this.transferHistoryModel}) : super(key: key);
  @override
  _TransferState createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  List _user = [];
  final formatter = new NumberFormat("#,###");
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController _id;
  TextEditingController _amount;
  TextEditingController _remark;
  TransferHistoryModel selectedContact;
  FocusNode _idFocus;
  FocusNode _amountFocus;
  FocusNode _remarkFocus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _id = new TextEditingController();
    _amount = new TextEditingController();
    _remark = new TextEditingController();
    _idFocus = new FocusNode();
    _amountFocus = new FocusNode();
    _remarkFocus = new FocusNode();
    if (widget.transferHistoryModel != null) {
      _id.text = widget.transferHistoryModel.accountId;
    }
  }


  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _idFocus.dispose();
    _amountFocus.dispose();
    _remarkFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    return Scaffold(
      backgroundColor: UIHelper.MUZ_BACKGROUND_COLOR,
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text(
            'ໂອນເງິນ',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w200,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
                            'ປ້ອນຂໍ້ມູນການໂອນ',
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
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextFormField(
                      controller: _id,
                      autofocus: true,
                      focusNode: _idFocus,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      obscureText: false,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: IconButton(
                              icon: Icon(Icons.list),
                              onPressed: () {
                                _openDialogHistory();
                              },
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ໄອດີປາຍທາງ',
                          hintText: '',
                          hintStyle:
                              TextStyle(color: UIHelper.POMEGRANATE_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    height: 50.00,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(100000);
                            },
                            child: Text('100,000'),
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(200000);
                            },
                            child: Text('200,000'),
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(300000);
                            },
                            child: Text('300,000'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    height: 50.00,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(400000);
                            },
                            child: Text('400,000'),
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(500000);
                            },
                            child: Text('500,000'),
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(1000000);
                            },
                            child: Text('1,000,000'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextFormField(
                      controller: _amount,
                      focusNode: _amountFocus,
                      keyboardType: TextInputType.phone,
                      autocorrect: true,
                      obscureText: false,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ຈຳນວນເງິນ',
                          hintText: '2,XXX,XXX',
                          hintStyle:
                              TextStyle(color: UIHelper.POMEGRANATE_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextFormField(
                      controller: _remark,
                      focusNode: _remarkFocus,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      obscureText: false,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      maxLines: 2,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ຈຸດປະສົງ',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: FlatButton(
                onPressed: () => {
//                  navigator(context, TransferConfirm(selectedContact: selectedContact))
                  next(context, selectedContact)
                },
                color: UIHelper.SPOTIFY_COLOR,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Text("ຖັດໄປ      ", style: TextStyle(fontSize: 20)),
                    Icon(Icons.arrow_forward)
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  next(BuildContext context, TransferHistoryModel model) async {

    if (_id.text.trim() == "") {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນໄອດີປາຍທາງ', 'OK');
      _idFocus.requestFocus();
      return;
    }

    if (_amount.text.trim() == "") {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນ ຫຼື ເລືອກຈຳນວນເງິນ', "OK");
      _amountFocus.requestFocus();
      return;
    }

    if (_remark.text.trim() == "") {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນຈຸດປະສົງ', "OK");
      _remarkFocus.requestFocus();
      return;
    }

    final data = jsonEncode({
      "account_id": _id.text,
      "amount": _amount.text,
      "id": await services.getValue("id"),
      "source_account_id": await services.getValue(ACCOUNT_ID)
    });
    final ProgressDialog pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/customer/account-id', data);
      await pr.hide();
      if (result.status == "success") {
        Transaction transaction = new Transaction(name: result.data[0]["firstName"] + ' ' + result.data[0]["lastName"],
            destinationId: result.data[0]["id"], toAccountId: _id.text,
            amount: Global.toNumber(_amount.text), remark: _remark.text);
        navigator(context, TransferConfirm(selectedContact: transaction));
      } else {
        Alert.warning(context, result.status, result.message, "OK");
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }

  }

  setAmount(amount) {
    _amount.text = formatter.format(amount);
  }

  Future _openDialogHistory() async {
    selectedContact = await Navigator.of(context)
        .push(new MaterialPageRoute<TransferHistoryModel>(
            builder: (BuildContext context) {
              return new TransferHistory();
            },
            fullscreenDialog: true));
    print(selectedContact.accountId);
    setState(() {
      _user.add(selectedContact);
      _id.text = selectedContact.accountId;
    });
  }
}
