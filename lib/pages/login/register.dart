import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/CountryPicker/country_picker.dart';
import 'package:OCWA/pages/login/register_confirm.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/styles/text_styles.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  bool hiddenText = true;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  final _phoneCtrl = TextEditingController();
  String phoneCode = '+856';
  final storage = new FlutterSecureStorage();
  bool isLoading = false;
  String verificationId;
  User currentUser;
  Country _selected = Country(
    asset: "assets/flags/la_flag.png",
    dialingCode: "856",
    isoCode: "LA",
    name: "Lao People's Democratic Republic",
  );
  int resendingToken;

  @override
  void initState() {
    _phoneCtrl.text = '';
    super.initState();
  }

  void _toggleVisibility() {
    setState(() {
      hiddenText = !hiddenText;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    return Scaffold(
      backgroundColor: UIHelper.MUZ_BACKGROUND_COLOR,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _topBar,
            SizedBox(
              height: 40.0,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CountryPicker(
                    onChanged: (Country country) {
                      setState(() {
                        _selected = country;
                        phoneCode = '+' + country.dialingCode;
                      });
                    },
                    selectedCountry: _selected,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      autocorrect: true,
                      obscureText: false,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 30.0),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ເບີໂທລະສັບ',
                          hintText: '',
                          helperText: 'ຕົວຢ່າງ: 209XXXXXXX',
                          prefixText: phoneCode + ' ',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
                  Center(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(30, 70, 30, 0),
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: UIHelper.MUZ_BUTTONSHADOW,
                                  blurRadius: 10.0,
                                  // has the effect of softening the shadow
                                  spreadRadius: 1.0,
                                  // has the effect of extending the shadow
                                  offset: Offset(
                                    0.0, // horizontal, move right 10
                                    5.0, // vertical, move down 10
                                  ),
                                ),
                              ],
                            ),
                            child: RaisedButton(
                              color: UIHelper.SPOTIFY_COLOR,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(50.0)),
                              onPressed: () {
                                _signUp(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'ລົງທະບຽນ',
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
                  _loginButton,
                ],
              ),
            ),
//            // Loading
//            Positioned(
//              child: isLoading
//                  ? Container(
//                child: Center(
//                  child: CircularProgressIndicator(
//                    valueColor: AlwaysStoppedAnimation<Color>(enigmaBlue),
//                  ),
//                ),
//                color: enigmaBlack.withOpacity(0.8),
//              )
//                  : Container(),
//            ),
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
          child: Text('ລົງທະບຽນ',
              textAlign: TextAlign.center, style: UITextStyles.loginStyle)));

  Widget get _loginButton => Center(
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
                  'ເຂົ້າລະບົບ',
                  style: TextStyle(fontSize: 20, color: UIHelper.SPOTIFY_COLOR),
                ),
              ),
            )),
      );

  Future<void> verifyPhoneNumber() async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    await pr.show();
    pr.update(message: 'ກຳລັງດຳເນີນ...');


      final PhoneVerificationCompleted verificationCompleted =
          (AuthCredential phoneAuthCredential) async {
        await pr.hide();
        print(this.verificationId);
        UserModel user = new UserModel(phone: _phoneCtrl.text);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RegisterConfirm(
                  user: user,
                  verificationId: this.verificationId,
                  authCredential: phoneAuthCredential,
                )));
      };

      final PhoneVerificationFailed verificationFailed =
          (FirebaseAuthException authException) async {
        await pr.hide();
        OCWA.reportError(
            '${authException.message} Phone: ${_phoneCtrl.text} Country Code: $phoneCode ',
            authException.code);
        setState(() {
          isLoading = false;
        });
        await pr.hide();
        OCWA.toast(
            'Authentication failed - ${authException.message}. Try again later.');
      };

      final PhoneCodeSent codeSent =
          (String verificationId, [int forceResendingToken]) async {
        setState(() {
          resendingToken = forceResendingToken;
          isLoading = false;
          this.verificationId = verificationId;
        });
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
          (String verificationId) async {
        await pr.hide();
        setState(() {
          isLoading = false;
          this.verificationId = verificationId;
        });
      };

      await firebaseAuth.verifyPhoneNumber(
          phoneNumber: (phoneCode + _phoneCtrl.text).trim(),
          timeout: const Duration(minutes: 2),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);


  }

  _signUp(BuildContext context) async {
    if (_phoneCtrl.text.isEmpty) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນເບີໂທລະສັບ', 'OK');
      return;
    }

    //Comment to enable global testing
//    if (!Global.validatePhone(_phoneCtrl.text)) {
//      Alert.warning(
//          context, 'ເບີໂທລະສັບບໍ່ຖືກຕ້ອງ', 'ກະລຸນາກວດສອບແລ້ວລອງໃໝ່', 'OK');
//      return;
//    }

//    final data = jsonEncode({
//      "phone": Global.getPhone(_phoneCtrl.text),
//    });
    RegExp e164 =
    new RegExp(r'^\+[1-9]\d{1,14}$');
    String _phone =
    _phoneCtrl.text.toString().trim();
    if (_phone.isNotEmpty &&
        e164.hasMatch(phoneCode + _phone)) {
      setState(() {
        isLoading = true;
      });
    } else {
      OCWA.toast(
          'Please enter a valid number.');
      return;
    }
    final data = jsonEncode({
      "phone": _phone,
    });

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງກວດສອບ...');
      final model = await NetworkUtil.post('/phone', data);
      await pr.hide();
      if (model.status == 'success') {
        verifyPhoneNumber();
      } else {
        Alert.error(context, model.status, model.message, 'OK');
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), 'OK');
    }
  }
}
