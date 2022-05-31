
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/pages/qr/scan.dart';
import 'package:OCWA/pages/topup/card/card_confirm.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

Services services = new StorageServiceSharedPreferences();

class CardTopup extends StatefulWidget {
  String cardNumber;
  CardTopup({Key key, this.cardNumber}) : super(key: key);
  @override
  _CardTopupState createState() => _CardTopupState();
}

class _CardTopupState extends State<CardTopup> {
  final formatter = new NumberFormat("#,###");
  TextEditingController _cardNumber;
  bool focus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cardNumber = new TextEditingController();
    focus = true;
    if (widget.cardNumber != null) {
      _cardNumber.text = widget.cardNumber;
    }
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
            'ເພີ່ມເງິນເຂົ້າກະເປົາ',
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
                            'ເຕີມດ້ວຍບັດໂທລະສັບ',
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
                  padding: const EdgeInsets.all(0),
                  child: TextFormField(
                      controller: _cardNumber,
                      autofocus: focus,
                      keyboardType: TextInputType.number,
                      autocorrect: true,
                      obscureText: false,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: IconButton(
                              icon: Image.asset(
                                'assets/images/qrscan_2.png', width: 35.0, color: Colors.black,),
                              onPressed: () {
                                scan(context);
                              },
                            ),
                          ),
                          contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ເລກບັດ',
                          hintText: '',
                          hintStyle:
                          TextStyle(color: UIHelper.POMEGRANATE_TEXT_COLOR),
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
                onPressed: () {
                  next(context);
                },
                color: UIHelper.SPOTIFY_COLOR,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Text("ເຕີມ      ", style: TextStyle(fontSize: 20)),
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

  void scan(BuildContext context) async {
    var status = await Permission.camera.status;
    if (status.isUndetermined || status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      if (await Permission.camera.request().isGranted) {
        navigator(context, ScanScreen(type: 'deposit',));
      }
    }
    if (status.isGranted) {
      navigator(context, ScanScreen(type: 'deposit',));
    }
  }

  next(BuildContext context) {
    if (_cardNumber.text.isEmpty) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນເລກບັດ', 'OK');
      setState(() {
        focus = true;
      });
      return;
    }
    navigator(context, CardConfirm(cardNumber: _cardNumber.text,));
  }
}
