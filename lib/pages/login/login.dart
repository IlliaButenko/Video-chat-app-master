import 'dart:convert';

import 'package:OCWA/models/response.dart';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/chat/chat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/loading.dart';
import 'package:OCWA/pages/login/forgot_password.dart';
import 'package:OCWA/pages/login/phone_verify.dart';
import 'package:OCWA/pages/login/register.dart';
import 'package:OCWA/ui/dialog/loading.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/pages/E2EE/e2ee.dart' as e2ee;
import 'package:OCWA/utils/navigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/styles/text_styles.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../home.dart';

Services services = new StorageServiceSharedPreferences();

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool hiddenText = true;
  TextEditingController _phoneCtrl;
  TextEditingController _id;
  TextEditingController _passwordCtrl;
  GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _id = TextEditingController();
    _phoneCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
//    _id.text = "cheng";
//    _passwordCtrl.text = "password";
  }

  void _toggleVisibility() {
    setState(() {
      hiddenText = !hiddenText;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    return WillPopScope(
      onWillPop: () async => exit(context),
      child: Scaffold(
        backgroundColor: UIHelper.MUZ_BACKGROUND_COLOR,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  height: UIHelper.dynamicHeight(650),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: UIHelper.MUZ_SHADOW,
                            blurRadius:
                                10.0, // has the effect of softening the shadow
                            spreadRadius:
                                1.0, // has the effect of extending the shadow
                            offset: Offset(
                              3.0, // horizontal, move right 10
                              3.0, // vertical, move down 10
                            )),
                      ],
                      borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(UIHelper.dynamicWidth(150)),
                          bottomRight:
                              Radius.circular(UIHelper.dynamicWidth(150))),
                      color: UIHelper.SPOTIFY_COLOR),
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 130, 0, 0),
                      child: Text(UIHelper.welcomeBack,
                          textAlign: TextAlign.center,
                          style: UITextStyles.loginStyle))),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextFormField(
                      controller: _id,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      obscureText: false,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ID',
                          hintText: '',
                          prefixText: '@',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextFormField(
                      controller: _passwordCtrl,
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      obscureText: hiddenText,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: IconButton(
                              icon: hiddenText
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                              onPressed: _toggleVisibility,
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'Password',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                        child: SizedBox(
                          height: 30,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50.0)),
                            onPressed: () {
                              confirmDialog(context);
                            },
                            child: Text(UIHelper.forgetPassword,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: UIHelper.SPOTIFY_COLOR)),
                          ),
                        )),
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
                                _signIn(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Login',
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
                              navigator(context, Register());
                            },
                            child: Text(
                              UIHelper.signUp,
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
      ),
    );
  }

  _signIn(BuildContext context) async {
    if (_id.text.isEmpty) {
      Alert.warning(context, 'Alert', 'Please enter an ID', 'OK');
      return;
    }

    if (_passwordCtrl.text.isEmpty) {
      Alert.warning(context, 'Alert', 'Please enter a password', 'OK');
      return;
    }

    final data = jsonEncode(
        {"account_id": _id.text.trim(), "password": _passwordCtrl.text.trim()});

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'Ongoing...');
      ResponseModel result = ResponseModel.fromJson({
        "status":'success',
        "message":"string",
        "data": {
          "username": "username",
          "account_id": "account_id",
          "id": "1",
          "mobile": "mobile",
          "firstName": "firstName",
          "lastName": "lastName",
          "email": "email",
          "address": "address",
          "created": "created",
          "avatar": "https://source.unsplash.com/300x300/?portrait",
        }
      });
   /*   Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                    widget: Chat(),
                    tab: 0,
                  )));
   */  // final result = await NetworkUtil.post('/login', data);
      await pr.hide();
      if (result.status == 'success') {
   //     FirebaseAuth auth = FirebaseAuth.instance;
  //      if (auth.currentUser != null) {
          services.setValue(USERNAME, result.data['username'].toString());
          services.setValue(ACCOUNT_ID, result.data['account_id'].toString());
          services.setValue(ID, result.data['id'].toString());
          services.setValue(PHONE, '+' + result.data['mobile'].toString());
          services.setValue(
              FULL_NAME,
              result.data['firstName'].toString() +
                  ' ' +
                  result.data['lastName'].toString());
          services.setValue(EMAIL_APP, result.data['email'].toString());
          services.setValue(ADDRESS, result.data['address'].toString());
          services.setValue(CREATED, result.data['created'].toString());
          services.setValue(PHOTO_URL, result.data['avatar'].toString());
          services.setValue(USER, jsonEncode(result.data));
          G.loggedInId = int.parse(result.data['id']);
          G.loggedInUser = UserModel.fromJson(result.data);
          await loadWallet();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Loading()));
//          Navigator.pushReplacement(context, MaterialPageRoute(
//              builder: (context) => Home(widget: Chat(), tab: 0,)));
    /*    } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => PhoneVerify(jsonEncode(result.data))));
        }
     */ } else {
        await pr.hide();
        Alert.warning(context, result.status, result.message, 'OK');
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'An error occurred', e.toString(), 'OK');
    }
  }

  loadWallet() async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    await pr.show();
    pr.update(message: 'Signing in...');
    final id = await services.getValue(ID);
    final name = await services.getValue(FULL_NAME);
    final created = await services.getValue(CREATED);
    final avatar = await services.getValue(PHOTO_URL);
    try {
      final model = await NetworkUtil.post(
          '/wallet', jsonEncode({"id": await services.getValue(ACCOUNT_ID)}));
      final _list = await NetworkUtil.getTransferContact('/transfer-history');
      final checkWallet =
          await NetworkUtil.post('/wallet-status', jsonEncode({"id": id}));
      await pr.hide();
      if (model.status == "success") {
        if (mounted) {
          print("Wallet: ${model.data}");
          setState(() {
            Global.wallet = model.data;
            Global.userModel = new UserModel(
                id: int.parse(id),
                name: name,
                created: created,
                avatar: avatar);
            Global.historyModel = _list;
          });
        }
      }
      if (checkWallet.status == 'success' && checkWallet.data == '1') {
        if (mounted) {
          setState(() {
            Global.enableWallet = true;
          });
        }
      }
    } catch (e) {
      print(e.toString());
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
                  'Recover password',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Text(
                      'Enter a phone number to recover the password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      autocorrect: true,
                      obscureText: false,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'Phone number',
                          hintText: '209XXXXXXX',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: UIHelper.SPOTIFY_COLOR,
                        onPressed: () {
                          if (_phoneCtrl.text.isEmpty) {
                            Alert.info(context, 'Alert',
                                'Please enter a phone number', 'OK');
                            return;
                          } else {
                            resetPassword(context);
                          }
                        },
                      ),
                      FlatButton(
                        child: Text('Cancel'),
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

  resetPassword(BuildContext context) async {
    if (_phoneCtrl.text.isEmpty) {
      Alert.warning(context, 'Alert', 'Please enter a phone number', 'OK');
      return;
    }

    if (!Global.validatePhone(_phoneCtrl.text)) {
      Alert.warning(context, 'Alert', 'Invalid phone number', 'OK');
      return;
    }

    final data = jsonEncode({"phone": Global.getPhone(_phoneCtrl.text)});

    try {
      Dialogs.showLoadingDialog(context, _keyLoader); //invoking login
      final result = await NetworkUtil.post('/resend-code', data);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (result.status == "success") {
        UserModel user = new UserModel(phone: Global.getPhone(_phoneCtrl.text));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ForgotPassword(
                  user: user,
                )));
      } else {
        Alert.error(context, result.status, result.message, 'OK');
      }
    } catch (e) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true)
          .pop(); //close the dialoge
      Alert.error(context, 'An error occurred', e.toString(), 'OK');
    }
  }

  exit(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
