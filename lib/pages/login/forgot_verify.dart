import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/login/login.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/styles/text_styles.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ForgotVerify extends StatefulWidget {
  UserModel user;
  ForgotVerify({Key key, this.user}) : super(key: key);
  @override
  _ForgotVerifyState createState() => _ForgotVerifyState();
}

class _ForgotVerifyState extends State<ForgotVerify> {
  String _code;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    return Scaffold(
      backgroundColor: UIHelper.MUZ_BACKGROUND_COLOR,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _topBar,
            Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text(
                      'ກະລຸນາປ້ອນລະຫັດສ່ວນຕົວ',
                      style: TextStyle(color: UIHelper.SPOTIFY_COLOR),
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: PinEntryTextField(
                      fields: 4,
                      isTextObscure: true,
                      showFieldAsBox: true,
                      onSubmit: (String pin) {
                        _code = pin; //end showDialog()
                      }, // end onSubmit
                    )),
                Center(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          child: RaisedButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50.0)),
                            onPressed: () {
                              confirm(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'ຢືນຢັນ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                ),
                Center(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(50.0)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'ກັບຄືນ',
                            style: TextStyle(
                                fontSize: 20, color: UIHelper.SPOTIFY_COLOR),
                          ),
                        ),
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _topBar => Container(
      height: UIHelper.dynamicHeight(650),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: UIHelper.MUZ_SHADOW,
                blurRadius: 10.0, // has the effect of softening the shadow
                spreadRadius: 1.0, // has the effect of extending the shadow
                offset: Offset(
                  3.0, // horizontal, move right 10
                  3.0, // vertical, move down 10
                )),
          ],
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(UIHelper.dynamicWidth(150)),
              bottomRight: Radius.circular(UIHelper.dynamicWidth(150))),
          color: UIHelper.SPOTIFY_COLOR),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 130, 0, 0),
          child: Column(
            children: <Widget>[
              Text('ປ້ອນລະຫັດສ່ວນຕົວ',
                  textAlign: TextAlign.center, style: UITextStyles.loginStyle),
              Text(
                'ເພື່ອກູ້ລະຫັດຜ່ານ',
                style: TextStyle(fontSize: 15, color: Colors.white),
              )
            ],
          )));

  confirm(BuildContext context) async {
    if (_code.isEmpty) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນລະຫັດສ່ວນຕົວ', 'OK');
      return;
    }

    final data = jsonEncode({
      "phone": widget.user.phone,
      "code": _code,
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final model = await NetworkUtil.post('/resetpassword', data);
      await pr.hide();
      if (model.status == 'success') {
        Alert.success(
            context,
            'ສຳເລັດ',
            'ລະຫັດຜ່ານໃໝ່ໄດ້ສົ່ງ SMS ເຂົ້າຫາເບີ: ' +
                Global.showPhone(widget.user.phone),
            "OK", action: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Login()));
        });
      } else {
        Alert.warning(context, model.status, model.message, 'OK');
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), 'OK');
    }
  }
}
