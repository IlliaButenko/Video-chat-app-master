import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/chat/chat.dart';
import 'package:OCWA/pages/configs/configs.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/home.dart';
import 'package:OCWA/pages/loading.dart';
import 'package:OCWA/pages/login/login.dart';
import 'package:OCWA/pages/login/phone_verify.dart';
import 'package:OCWA/pages/login/register.dart';
import 'package:OCWA/pages/login/register_profile.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/pages/E2EE/e2ee.dart' as e2ee;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/commons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:OCWA/utils/extension.dart';

Services services = new StorageServiceSharedPreferences();

class PhoneConfirm extends StatefulWidget {
  UserModel user;
  AuthCredential authCredential;
  String verificationId;
  String data;

  PhoneConfirm(
      {Key key, this.user, this.authCredential, this.verificationId, this.data})
      : super(key: key);

  @override
  _PhoneConfirmState createState() => _PhoneConfirmState();
}

class _PhoneConfirmState extends State<PhoneConfirm> {
  String _code = "";

  bool hiddenText = true;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  String phoneCode = '+856';
  final storage = new FlutterSecureStorage();
  bool isLoading = false;
  User currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text('Message sent to Off: ' +
                        Global.showPhone(widget.user.phone))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: PinEntryTextField(
                      fields: 6,
                      isTextObscure: true,
                      showFieldAsBox: true,
                      onSubmit: (String pin) {
                        _code = pin; //end showDialog()
                      }, // end onSubmit
                    )),
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
                          child: Text('Not received SMS?',
                              style: TextStyle(
                                  fontSize: 15, color: UIHelper.SPOTIFY_COLOR)),
                        ),
                      )),
                ),
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
                                  'Confirm',
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
                _backButton
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> handleSignUp(
      {AuthCredential authCredential, BuildContext context}) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    prefs = await SharedPreferences.getInstance();
    if (isLoading == false) {
      this.setState(() {
        isLoading = true;
      });
    }

    AuthCredential credential;
    if (authCredential == null)
      credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _code,
      );
    else
      credential = authCredential;
    User firebaseUser;
    var phoneNo = (phoneCode + widget.user.phone).trim();

    try {
      await pr.show();
//      pr.update(message: '?????????????????????????????????...');
      final userCredential = await firebaseAuth
          .signInWithCredential(credential)
          .catchError((err) async {
        print(err.toString());
        await pr.hide();
        await OCWA.reportError(err, 'signInWithCredential');
        OCWA.toast('Please check the verification code and try again.');
        return;
      });
      firebaseUser = userCredential.user;
    } catch (e) {
      print(e.toString());
      await pr.hide();
      await OCWA.reportError(e, 'signInWithCredential catch block');
      OCWA.toast('Please check the verification code and try again.');
      return;
    } finally {
      await pr.hide();
    }

    if (firebaseUser != null) {
// Check is already sign up
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
      pr.update(message: 'Ongoing...');
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(USERS)
          .where(UID, isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      final pair = await e2ee.X25519().generateKeyPair();
      await storage.write(key: PRIVATE_KEY, value: pair.secretKey.toBase64());
      if (documents.isEmpty) {
        await pr.hide();
        Alert.error(context, 'An error occurred', 'Please register', 'OK');
      } else {

        await FirebaseFirestore.instance.collection(USERS).doc(phoneNo).set({
          AUTHENTICATION_TYPE: AuthenticationType.passcode.index,
          PUBLIC_KEY: pair.publicKey.toBase64()
        }, SetOptions(merge: true));
        // Write data to local
        final data = jsonDecode(widget.data);
        services.setValue(USERNAME, data['username'].toString());
        services.setValue(ACCOUNT_ID, data['account_id'].toString());
        services.setValue(ID, data['id'].toString());
        services.setValue(PHONE, '+' + data['mobile'].toString());
        services.setValue(
            FULL_NAME,
            data['firstName'].toString() +
                ' ' +
                data['lastName'].toString());
        services.setValue(EMAIL_APP, data['email'].toString());
        services.setValue(ADDRESS, data['address'].toString());
        services.setValue(CREATED, data['created'].toString());
        services.setValue(PHOTO_URL, data['avatar'].toString());
        services.setValue(USER, jsonEncode(data));
        final user = UserModel(
            id: int.parse(data['id']), name: data['firstName'].toString() +
            ' ' +
            data['lastName'].toString(), created: data['created'].toString(), avatar: data['avatar'].toString());
        setState(() {
          Global.userModel = user;
          G.loggedInId = int.parse(data['id']);
          G.loggedInUser = UserModel.fromJson(data);
        });

        await loadWallet();
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => Loading()));
//        Navigator.pushReplacement(context, MaterialPageRoute(
//            builder: (context) => Home(widget: Chat(), tab: 0,)));

      }
    } else {
      OCWA.toast("Registration failed.");
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

  Future<void> verifyPhoneNumber() async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    await pr.show();
    pr.update(message: 'Ongoing...');

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      OCWA.toast('The code was sent via SMS');
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) async {
      await pr.hide();
      OCWA.reportError(
          '${authException.message} Phone: ${widget.user.phone} Country Code: $phoneCode ',
          authException.code);
      setState(() {
        isLoading = false;
      });

      OCWA.toast(
          'Authentication failed - ${authException.message}. Try again later.');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      setState(() {
        isLoading = false;
      });
      widget.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) async {
      await pr.hide();
      setState(() {
        isLoading = false;
      });

      widget.verificationId = verificationId;
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: (phoneCode + widget.user.phone).trim(),
        timeout: const Duration(minutes: 2),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  confirm(BuildContext context) async {
    if (_code.isNullOrEmpty()) {
      Alert.warning(context, 'Alert', 'Please enter a confirmation code', 'OK');
      return;
    }
    handleSignUp(authCredential: widget.authCredential, context: context);
  }

  Widget get _topBar => Container(
      height: UIHelper.dynamicHeight(500),
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
          padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
          child: Text('Confirm the code from SMS',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, color: Colors.white))));

  Widget get _backButton => Center(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text(
                  'Return',
                  style: TextStyle(fontSize: 20, color: UIHelper.SPOTIFY_COLOR),
                ),
              ),
            )),
      );

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
                  'Submit the code again',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Text(
                      'Do you want to submit the verification code again??',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
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
                          'Wanted',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: UIHelper.SPOTIFY_COLOR,
                        onPressed: () {
                          resendCode(context);
                        },
                      ),
                      FlatButton(
                        child: Text('Not required'),
                        color: UIHelper.AVOCADOS_SECONDARY_COLOR,
                        onPressed: () {
                          Navigator.of(context).pop('No');
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

  resendCode(BuildContext context) async {
    verifyPhoneNumber();
  }
}
