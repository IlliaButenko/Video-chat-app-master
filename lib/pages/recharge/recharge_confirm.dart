import 'dart:convert';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/response.dart';
import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/dasboard/dasboard.dart';
import 'package:OCWA/pages/home.dart';
import 'package:OCWA/ui/dialog/loading.dart';
import 'package:OCWA/ui/dialog/transfer_history.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:OCWA/utils/global.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:intl/intl.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

Services services = new StorageServiceSharedPreferences();

class RechargeConfirm extends StatefulWidget {
  Transaction transaction;

  RechargeConfirm({Key key, this.transaction}) : super(key: key);

  @override
  _RechargeConfirmState createState() => _RechargeConfirmState();
}

class _RechargeConfirmState extends State<RechargeConfirm> {
  Transaction _data = new Transaction();
  final formatter = new NumberFormat("#,###");
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final GlobalKey<State> _keyLoader2 = new GlobalKey<State>();
  bool loading;
  String pinCode = '';
  String simNetwork = '';

  @override
  void initState() {
    super.initState();
    init();
    loading = true;
  }

  init() async {
    try {
      String phone;

      phone = widget.transaction.phone;

      /********
       *
       * Unitel Show Balance and Sim Type
       *
       *********/
      if (Global.getStartWith(Global.showPhone(phone).substring(2)) == 9) {
        //

      }
      /********
       *
       * TPLUS Show Balance and Sim Type
       *
       *********/
      if (Global.getStartWith(Global.showPhone(phone).substring(2)) == 7) {
        simNetwork = 'tplus';
        ResponseModel simInfo, balance;
        balance = await NetworkUtil.post(
            '/tplus/check-balance', jsonEncode({'phone': phone, 'balance': 0}));
        simInfo = await NetworkUtil.post('/tplus/check-msisdn-type',
            jsonEncode({'phone': phone, 'balance': 0}));
        int tplusType;

        setState(() {
          if (simInfo.status == 'success' && balance.status == 'success') {
            setState(() {
              if (simInfo.data == "G") {
                tplusType = 0;
              } else if (simInfo.data == "T") {
                tplusType = 3;
              } else if (simInfo.data == "H") {
                tplusType = 1;
              }
              _data = (Transaction(
                  type: Global.getPhoneType(tplusType),
                  phone: phone,
                  amountAvailable: int.parse(balance.data) + .0,
                  amount: widget.transaction.amount));
            });
            loading = false;
          } else {
            Alert.warning(context, balance.status, balance.data, "OK",
                action: () {
              Navigator.of(context).pop();
            });
          }
        });
      }
      /********
       *
       * LTC Show Balance and Sim Type
       *
       *********/
      if (Global.getStartWith(Global.showPhone(phone).substring(2)) == 5) {
        simNetwork = 'ltc';
        ResponseModel info, balance;
        info = await NetworkUtil.post(
            '/check-all-information', jsonEncode({"phone": phone}));
        balance = await NetworkUtil.post(
            '/check-balance', jsonEncode({"phone": phone}));

        setState(() {
          if (info.status == 'success' && balance.status == 'success') {
            setState(() {
              _data = (Transaction(
                  name: info.data["name"],
                  type:
                      Global.getPhoneType(int.parse(info.data["productType"])),
                  phone: phone,
                  amountAvailable: balance.data["balance"] + .0,
                  amount: widget.transaction.amount));
            });
            loading = false;
          } else {
            Alert.warning(
                context, balance.status, balance.data['resultDesc'], "OK",
                action: () {
              Navigator.of(context).pop();
            });
          }
        });
      }

      /*****
       *
       *    Show ETL sim Type
       *
       *****/

      if (Global.getStartWith(Global.showPhone(phone).substring(2)) == 2) {
        simNetwork = 'etl';
        ResponseModel etlLogin, etlKeepAlive, etlSimType;
        // etlLogin = await NetworkUtil.post('/etl/auth', '');
        etlKeepAlive = await NetworkUtil.post('/etl/keep-alive-login', '');

        if (etlKeepAlive.status != 'success') {
          etlLogin = await NetworkUtil.post('/etl/auth', '');
          if (etlLogin.status == "success") {
            etlKeepAlive = await NetworkUtil.post('/etl/keep-alive-login', '');
            etlSimType = await NetworkUtil.post(
                '/etl/query-subscriber-type', jsonEncode({"phone": phone}));
            etlTopup(etlSimType, etlKeepAlive, phone);
          }
        } else {
          etlSimType = await NetworkUtil.post(
              '/etl/query-subscriber-type', jsonEncode({"phone": phone}));
          etlTopup(etlSimType, etlKeepAlive, phone);
        }
      }
    } catch (e) {
      Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), 'OK');
    }
  }

  void etlTopup(
      ResponseModel etlSimType, ResponseModel etlKeepAlive, String phone) {
    int simType;
    print(etlSimType.data);
    if (int.parse(etlSimType.data) == 0) {
      simType = 3;
    } else if (int.parse(etlSimType.data) == 1) {
      simType = 0;
    }
    setState(() {
      // print(etlLogin.data);

      if (etlSimType.status == 'success') {
        setState(() {
          _data = (Transaction(
              type: Global.getPhoneType(simType),
              phone: phone,
              amountAvailable: 0,
              amount: widget.transaction.amount));
        });
        loading = false;
      } else {
        Alert.warning(context, etlSimType.status, etlSimType.data, "OK",
            action: () {
          Navigator.of(context).pop();
        });
      }
    });
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
          title: Text('ຢືນຢັນ'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: (loading == true)
          ? Center(
              child: Text('ກຳລັງໂຫລດ...'),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  showLogo(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30.0) //(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                          ),
                      color: UIHelper.THEME_PRIMARY,
                      elevation: 10,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Center(
                              child: Container(
                                child: Text(
                                  'ຂໍ້ມູນເບີໂທລະສັບ',
                                  style: TextStyle(
                                      fontSize: 20.0, color: UIHelper.WHITE),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
//                            Container(
//                              height: 70,
//                              margin: EdgeInsets.only(bottom: 1),
//                              alignment: Alignment.center,
//                              width: double.infinity,
//                              decoration: BoxDecoration(
//                                  color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
//                                  borderRadius: BorderRadius.circular(5.0)),
//                              child: ListTile(
//                                title: Text(
//                                  'ຊື່ ແລະ ນາມສະກຸນ',
//                                  style: TextStyle(
//                                      fontSize: 18,
//                                      color: Colors.black54,
//                                      fontWeight: FontWeight.w200),
//                                ),
//                                subtitle: Text(
//                                  _data.name,
//                                  style: TextStyle(
//                                      color: UIHelper.SPOTIFY_COLOR,
//                                      fontSize: 20,
//                                      fontWeight: FontWeight.w400),
//                                ),
//                              ),
//                            ),
                            Container(
                              height: 70,
                              margin: EdgeInsets.only(bottom: 1),
                              alignment: Alignment.center,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: ListTile(
                                title: Text(
                                  'ເບີໂທລະສັບ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w200),
                                ),
                                subtitle: Text(
                                  Global.showPhone(_data.phone),
                                  style: TextStyle(
                                      color: UIHelper.SPOTIFY_COLOR,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                                trailing: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'ປະເພດເບີ:',
                                        style: TextStyle(
                                            color: UIHelper.THEME_PRIMARY,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w200),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        _data.type,
                                        style: TextStyle(
                                            color: UIHelper.SPOTIFY_COLOR,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Show default

                            //ETL Hide Balance
                            if (simNetwork != 'etl')
                              Container(
                                height: 70,
                                margin: EdgeInsets.only(bottom: 10),
                                alignment: Alignment.center,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: ListTile(
                                  title: Text(
                                    'ຍອດເງິນຍັງເຫຼືອ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w200),
                                  ),
                                  subtitle: Text(
                                    formatter.format(_data.amountAvailable),
                                    style: TextStyle(
                                        color: UIHelper.SPOTIFY_COLOR,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                          color: kColorFontMoney,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    height: 90,
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                        borderRadius: BorderRadius.circular(0)),
                    child: ListTile(
                      title: Text(
                        'ຍອດເງິນ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.w200),
                      ),
                      subtitle: Text(
                        formatter.format(_data.amount),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: UIHelper.SPOTIFY_COLOR,
                            fontSize: 45,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          '',
                          style: TextStyle(
                              color: kColorFontMoney,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
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
                    Text("ຢືນຢັນ      ", style: TextStyle(fontSize: 20)),
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
    if (_data.phone == null) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ບໍ່ມີເບີໂທລະສັບທີ່ຈະຈ່າຍ', 'OK');
      return;
    }

    if (_data.amount == null) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ບໍ່ມີຈຳນວນເງິນທີ່ຈະຈ່າຍ', 'OK');
      return;
    }

    final String personalCode = await confirmDialog(context);
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      if (personalCode != null && personalCode != "") {
        await pr.show();
        pr.update(message: 'ກຳລັງດຳເນີນ...');
        final result2 = await NetworkUtil.post(
            '/validate-wallet',
            jsonEncode({
              "id": await services.getValue("id"),
              "passcode": personalCode
            }));
        await pr.hide();
        if (result2.status == 'success') {
          if (result2.data == "1") {
            final data = jsonEncode({
              "sourceId": await services.getValue("id"),
              "id": await services.getValue('id'),
              "phone": Global.showPhone(widget.transaction.phone),
              "amount": widget.transaction.amount,
              "account_id": await services.getValue(ACCOUNT_ID),
            });
            await pr.show();
            pr.update(message: 'ກຳລັງດຳເນີນ...');
            final result = await NetworkUtil.post('/recharge', data);
            await pr.hide();
            if (result.status == "success") {
              print(result.data);
              Transaction transaction = new Transaction(
                  name: _data.name, phone: _data.phone, amount: _data.amount);
              _showDialog(context, 'ສຳເລັດ',
                  'ເບີ: ${_data.phone} \nຈຳນວນເງິນ: ${formatter.format(_data.amount)}');
            } else {
              Alert.error(context, result.status, result.message, 'OK');
            }
          } else {
            Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ລະຫັດສ່ວນຕົວບໍ່ຖືກຕ້ອງ', "OK");
          }
        }
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), "OK");
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
                      pinCode = pin;
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
                          print(pinCode);
                          if (pinCode.isEmpty) {
                            Alert.warning(context, 'ແຈ້ງເຕືອນ',
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

  void _showDialog(BuildContext context, String title, String content) {
    successDialog(context, content, title: title, neutralText: 'OK',
        neutralAction: () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Home(
                tab: 1,
                widget: Dashboard(),
              )));
    });
  }

  showLogo() {
    String image = '';
    if (Global.getStartWith(Global.showPhone(_data.phone).substring(2)) == 9) {
      image = 'assets/images/unitel_full.png';
    }
    if (Global.getStartWith(Global.showPhone(_data.phone).substring(2)) == 7) {
      image = 'assets/images/tplus.png';
    }
    if (Global.getStartWith(Global.showPhone(_data.phone).substring(2)) == 5) {
      image = 'assets/images/laotel.png';
    }
    if (Global.getStartWith(Global.showPhone(_data.phone).substring(2)) == 2) {
      image = 'assets/images/etl.png';
    }
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Image.asset(
          image,
          height: 100,
        ));
  }
}
