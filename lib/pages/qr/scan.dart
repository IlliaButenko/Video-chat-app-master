import 'dart:async';
import 'dart:convert';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/chat/user.dart';
import 'package:OCWA/pages/payment/payment.dart';
import 'package:OCWA/pages/topup/card/card.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/qrcode_reader_view.dart';
import 'package:permission_handler/permission_handler.dart';

import 'generate.dart';
Services services = new StorageServiceSharedPreferences();

class ScanScreen extends StatefulWidget {
  String type;
  ScanScreen({Key key, this.type}) : super(key: key);
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  String barcode = "";
  BuildContext context;
  bool scanned = false;
  GlobalKey<QrcodeReaderViewState> qrViewKey = GlobalKey();

  @override
  initState() {
    super.initState();
    Timer.periodic(new Duration(seconds: 1), (timer) async {
      if (mounted && scanned) {
        setState(() {
          validateData();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
        appBar: new AppBar(
          title: new Text('ສະແກນ QR Code'),
        ),
        body: QrcodeReaderView(key: qrViewKey, onScan: onScan, helpWidget:
        Text('ກະລຸນາວາງລະຫັດ QR ໃນກ່ອງ', style: TextStyle(fontFamily: 'Souliyo'),), viewQr: viewQr,),
    );
  }

  Future onScan(String data) async {
    barcode = data;
    if (barcode != "") {
      scanned = true;
    }
    qrViewKey.currentState.startScan();
  }

  Future viewQr() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GenerateScreen(), fullscreenDialog: true),
    );
  }

  validateData() {
    if (barcode.isNotEmpty) {
      if (widget.type == 'pay') {
        UserModel user = new UserModel.fromJson(jsonDecode(barcode));
        if (user != null && user.accountId != null) {
          if (user.customerType == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => PaymentScreen(user: user,)));
          } else {
            loadUser(user);
          }
        } else {
          Alert.info(this.context, 'ແຈ້ງເຕືອນ', 'QR ທີ່ສະແກນບໍ່ຖືກຮູບແບບ', 'OK');
        }
      } else if (widget.type == 'deposit') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CardTopup(cardNumber: barcode,)));
      }
    }
  }

  loadUser(UserModel record) async {
    final data = jsonEncode({
      "id": await services.getValue('id'),
      "userOneId": await services.getValue('id'),
      "userTwoId": record.id.toString()
    });
    final result = await NetworkUtil.post('/load-account', data);
    if (result.status == "success") {
      UserModel user = UserModel.fromJson(result.data);
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => UserPage(record: user,)));
    }
  }
}