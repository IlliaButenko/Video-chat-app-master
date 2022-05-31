
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/models/response.dart';
import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/pages/recharge/recharge_confirm.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:async';

Services services = new StorageServiceSharedPreferences();

class Recharge extends StatefulWidget {
  @override
  _RechargeState createState() => _RechargeState();
}

class _RechargeState extends State<Recharge> {
  List _user = [];
  List _balance = [];

  final formatter = new NumberFormat("#,###");
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController _phone;
  TextEditingController _amount;
  TextEditingController _remark;
  FocusNode _phoneFocus;
  FocusNode _amountFocus;
  TransferHistoryModel selectedContact;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phone = new TextEditingController();
    _amount = new TextEditingController();
    _remark = new TextEditingController();
    _phoneFocus = new FocusNode();
    _amountFocus = new FocusNode();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _phoneFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
   
  }

  // run keep Alive for ETL Token

  void etlKeepAlive() async{
    ResponseModel etlLogin, etlKeepAlive;
  //  etlLogin = await NetworkUtil.post("/etl/auth", '');
 //   etlKeepAlive = await NetworkUtil.post("/app/etl/keep-alive-login", etlLogin.data);

    // const fourMinute = const Duration(minutes: 4);
    // Timer.periodic(fourMinute, (Timer t) => etlKeepAlive);
    print(etlKeepAlive);
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
          title: Text('ຈ່າຍຄ່າໂທລະສັບ'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 120,
              width: double.infinity,
              padding: EdgeInsets.only(top: 20),
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
                            'ປ້ອນເບີໂທ ແລະ ຈຳນວນເງິນ\nທີ່ທ່ານຕ້ອງການ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w300),
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
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    autocorrect: true,
                    obscureText: false,
                    focusNode: _phoneFocus,
                    style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                    decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: IconButton(
                            icon: Icon(Icons.list),
                            onPressed: () {
                              _openDialogHistory(context);
                            },
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: 'ເບີໂທລະສັບ',
                        hintText: '9XXXXXXX',
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
                              setAmount(5000);
                            },
                            child: Text('5,000'),
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(10000);
                            },
                            child: Text('10,000'),
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(20000);
                            },
                            child: Text('20,000'),
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
                              setAmount(25000);
                            },
                            child: Text('25,000'),
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 100.0,
                          height: 50.0,
                          child: FlatButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            textColor: UIHelper.WHITE,
                            onPressed: () {
                              setAmount(50000);
                            },
                            child: Text('50,000'),
                          ),
                        ),
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
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextFormField(
                    controller: _amount,
                    keyboardType: TextInputType.phone,
                    autocorrect: true,
                    obscureText: false,
                    focusNode: _amountFocus,
                    style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: 'ຈຳນວນເງິນ',
                        hintText: '2X,XXX',
                        hintStyle:
                            TextStyle(color: UIHelper.POMEGRANATE_TEXT_COLOR),
                        border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0))),
                  ),
                ),
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
                onPressed: () => {confirm(context)},
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

  setAmount(amount) {
    _amount.text = formatter.format(amount);
  }

  confirm(BuildContext context) {

    if (Global.getStartWith(Global.showPhone(_phone.text).substring(2)) == 9) {
      Alert.info(
          context, "ແຈ້ງເຕືອນ", "Unitel ຈະໄດ້ນຳໃຊບໍລິການ;້ໃນໄວໆນີ້", 'OK');
      _phoneFocus.requestFocus();
      return;
    }
    if (_phone.text.isEmpty) {
      Alert.warning(
          context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນເບີໂທລະສັບ', 'OK');
      _phoneFocus.requestFocus();
      return;
    }

    if (!Global.checkPhone(_phone.text)) {
      Alert.warning(
          context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນເບີໂທລະສັບ', 'OK');
      _phoneFocus.requestFocus();
      return;
    }

    if (_amount.text.isEmpty) {
      Alert.warning(
          context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນ ຫຼື ເລືອກຈຳນວນເງິນ', 'OK');
      _amountFocus.requestFocus();
      return;
    }

    Transaction transaction = new Transaction();
    transaction.phone = Global.showPhone(_phone.text);
    transaction.amount = Global.toNumber(_amount.text);

    navigator(
        context,
        RechargeConfirm(
          transaction: transaction,
        ));
  }

  Future _openDialogHistory(BuildContext context) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      List<TransferHistoryModel> result =
          await NetworkUtil.getTransferContact('/recharge-history');
      await pr.hide();
      var list = Set<SimpleItem>();
      print(result.length);
      for (var i = 0; i < result.length; i++) {
        list.add(SimpleItem(i + 1, result[i].mobile));
      }
      print(list);
      singleSelectDialog(context, "ເບີໂທລະສັບທີ່ເຄີຍຊຳລະ", list, (item) {
        _phone.text = item.toString();
      });
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), "OK");
    }
  }
}
