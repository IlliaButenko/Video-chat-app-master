import 'dart:convert';
import 'dart:io';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/ImagePicker/image_picker.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/chat/chat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/loading.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/functions.dart';
import 'package:OCWA/utils/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:OCWA/pages/E2EE/e2ee.dart' as e2ee;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home.dart';

Services services = new StorageServiceSharedPreferences();

class RegisterProfile extends StatefulWidget {
  UserModel user;
  AuthCredential authCredential;
  String verificationId;
  String code;

  RegisterProfile(
      {Key key, this.user, this.authCredential, this.verificationId, this.code})
      : super(key: key);

  @override
  _RegisterProfileState createState() => _RegisterProfileState();
}

class _RegisterProfileState extends State<RegisterProfile> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordCCtrl = TextEditingController();
  final _id = TextEditingController();
  String photoUrl = '';
  String phoneCode = '+856';
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  final storage = new FlutterSecureStorage();
  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  Future<PickedFile> pickedFile;
  FocusNode id;
  bool isLoading = false;
  User currentUser;
  bool hiddenText = true;
  File _userImageFile = File('');
  String _userImageUrlFromFB = '';

  @override
  void initState() {
    super.initState();
    id = new FocusNode();
    _id.text = "";
    currentUser = firebaseAuth.currentUser;
  }

  void _toggleVisibility() {
    setState(() {
      hiddenText = !hiddenText;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
          title: const Text(
            'ຕັ້ງໄອດີ ແລະ ຮູບພາບ',
            style: TextStyle(
              fontSize: 23.0,
              fontWeight: FontWeight.w200,
            ),
          ),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: Stack(
        children: [
          SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HybridImagePicker(
                                      title: 'ເລືອກຮູບ',
                                      callback: getImage,
                                      profile: true))).then(
                              (url) {
                            if (url != null) {
                              setState(() {
                                photoUrl = url.toString();
                              });
                            }
                          });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child: new Stack(fit: StackFit.loose, children: <Widget>[
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            (_userImageFile.path == "")
                                ? new Container(
                                    margin: EdgeInsets.all(10),
                                    width: 140.0,
                                    height: 140.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        image: new AssetImage(
                                            'assets/images/default_profile.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ))
                                : Container(
                              margin: EdgeInsets.all(10),
                              width: 140.0,
                              height: 140.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: new FileImage(_userImageFile),
                                  )),
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 90.0, right: 100.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 25.0,
                                  child: new Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )),
                      ]),
                    )),
                Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TextFormField(
                      controller: _id,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      focusNode: id,
                      obscureText: false,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ໄອດີ',
                          hintText: '',
                          prefixText: '@',
                          helperText:
                              'ຕົວຢ່າງ: john (ເປັນໄອດີສ່ວນຕົວບັນຊີຂອງທ່ານ)',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TextFormField(
                      controller: _firstName,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      obscureText: false,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ຊື່',
                          hintText: '',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TextFormField(
                      controller: _lastName,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      obscureText: false,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ນາມສະກຸນ',
                          hintText: '',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
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
                          labelText: 'ລະຫັດຜ່ານ',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TextFormField(
                      controller: _passwordCCtrl,
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      obscureText: hiddenText,
                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: 'ຢືນຢັນລະຫັດຜ່ານ',
                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0))),
                    ),
                  ),
//                  Padding(
//                    padding: const EdgeInsets.all(0.0),
//                    child: TextFormField(
//                      autocorrect: true,
//                      obscureText: false,
//                      initialValue: widget.user.phone,
//                      style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
//                      decoration: InputDecoration(
//                          contentPadding:
//                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                          labelText: 'ເບີໂທລະສັບ',
//                          hintText: '',
//                          prefixText: phoneCode,
//                          enabled: false,
//                          hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
//                          border: UnderlineInputBorder(
//                              borderRadius: BorderRadius.circular(32.0))),
//                    ),
//                  ),
                ]),
                Center(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          child: RaisedButton(
                            color: UIHelper.SPOTIFY_COLOR,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50.0)),
                            onPressed: () {
                              // go to dashboard
                              confirm(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'ສຳເລັດການລົງທະບຽນ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
          // Loading
          Positioned(
            child: isLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(enigmaBlue)),
              ),
              color: Colors.black.withOpacity(0.8),
            )
                : Container(),
          ),
        ]
      ),
    );
  }


  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  Future getImage(File image) async {
    if (image != null) {
      setState(() {
        _userImageFile = image;
      });
    }
    return uploadFile();
  }

  Future uploadFile() async {
    String fileName = phoneCode + widget.user.phone;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    TaskSnapshot uploading =
    await reference.putFile(_userImageFile);
    return uploading.ref.getDownloadURL();
  }

  confirm(BuildContext context) {
    if (_id.text.isEmpty) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາໃສ່ໄອດີຂອງທ່ານ', 'OK');
      id.requestFocus();
      return;
    }

    if (_firstName.text.isEmpty) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນຊື່', "OK");
      return;
    }

    if (_lastName.text.isEmpty) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນນາມສະກຸນ', 'OK');
      return;
    }

    if (_passwordCtrl.text.isEmpty) {
      Alert.warning(context, 'ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນລະຫັດຜ່ານ', 'OK');
      return;
    }

    if (_passwordCtrl.text != _passwordCCtrl.text) {
      Alert.warning(
          context, 'ລະຫັດຜ່ານບໍ່ກົງກັນ', 'ກະລຸນາກວດສອບແລ້ວລອງໃໝ່', 'OK');
      return;
    }

    final validCharacters = Global.validCharacters;
    if (!validCharacters.hasMatch(_id.text)) {
      Alert.warning(
          context,
          'ແຈ້ງເຕືອນ',
          'ໄອດີຂອງທ່ານບໍ່ສາມາດຍະວ່າງໄດ້ ແລະ ໃສ່ໄດ້ສະເພາະຕົວເລກ ແລະ ຕົວອັກສອນພາສາອັງກິດເທົ່ານັ້ນ',
          'OK');
      return;
    }

    checkAccountId(context);
  }

  checkAccountId(BuildContext context) async {
    final data = jsonEncode({
      "account_id": _id.text,
      "phone": Global.getPhone(widget.user.phone)
    });

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final model = await NetworkUtil.post('/check-account-id', data);
      await pr.hide();
      if (model.status == 'success') {
        register(context);
      } else {
        Alert.error(context, model.status, model.message, 'OK');
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), 'OK');
    }
  }

  register(BuildContext context) async {
    final data = jsonEncode(
        {
          "uid": currentUser.uid,
          "accountId": _id.text,
          "firstName": _firstName.text,
          "lastName": _lastName.text,
          "phone": Global.getPhone(widget.user.phone),
          "password": _passwordCtrl.text,
          "code": widget.code,
          "photoUrl": photoUrl
        });
    //print(data);
    final ProgressDialog pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final model = await NetworkUtil.post('/register', data);
      await pr.hide();
      if (model.status == 'success') {
        UserModel user = new UserModel.fromJson(model.data);
        handleSignUp(user, context);
      } else {
        Alert.error(context, model.status, model.message, 'OK');
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), 'OK');
    }
  }

  Future<Null> handleSignUp(UserModel userModel, BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    if (isLoading == false) {
      this.setState(() {
        isLoading = true;
      });
    }

    var phoneNo = (phoneCode + widget.user.phone).trim();
    currentUser = FirebaseAuth.instance.currentUser;
    print('Photo: ${currentUser.photoURL}');
    final ProgressDialog pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
        showLogs: false);
    if (currentUser != null) {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(USERS)
          .where(ID, isEqualTo: currentUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      final pair = await e2ee.X25519().generateKeyPair();
      await storage.write(key: PRIVATE_KEY, value: pair.secretKey.toBase64());
      if (documents.isEmpty) {
        // Update data to server if new user
        await FirebaseFirestore.instance.collection(USERS).doc(phoneNo).set({
          PUBLIC_KEY: pair.publicKey.toBase64(),
          COUNTRY_CODE: phoneCode,
          NICKNAME: _firstName.text.trim(),
          FULL_NAME: getFullName(_firstName.text.trim(), _lastName.text.trim()),
          FIRST_NAME: _firstName.text.trim(),
          LAST_NAME: _lastName.text.trim(),
          PASSWORD: userModel.password,
          PHOTO_URL: photoUrl,
          ID: userModel.id.toString(),
          UID: currentUser.uid,
          PHONE: phoneNo,
          AUTHENTICATION_TYPE: AuthenticationType.passcode.index,
          ABOUT_ME: '',
          CREATED: userModel.created
        }, SetOptions(merge: true));

        // Write data to local
        await prefs.setString(ID, userModel.id.toString());
        await prefs.setString(UID, currentUser.uid);
        await prefs.setString(NICKNAME, _firstName.text.trim());
        await prefs.setString(FULL_NAME,
            getFullName(_firstName.text.trim(), _lastName.text.trim()));
        await prefs.setString(FIRST_NAME, _firstName.text.trim());
        await prefs.setString(LAST_NAME, _lastName.text.trim());
        await prefs.setString(PHOTO_URL, photoUrl);
        await prefs.setString(PHONE, phoneNo);
        await prefs.setString(COUNTRY_CODE, phoneCode);
        await prefs.setString(ACCOUNT_ID, _id.text.trim());
        await prefs.setString(USER, jsonEncode(userModel.toJson()));
        await prefs.setString(CREATED, userModel.created);

        final id = userModel.id.toString();
        final name = getFullName(_firstName.text.trim(), _lastName.text.trim());
        final created = new DateTime.now();
        final avatar = photoUrl;
        final user = UserModel(
            id: int.parse(id), name: name, created: created.toString(), avatar: avatar);
        setState(() {
          Global.userModel = new UserModel(
              id: int.parse(id), name: name, created: created.toString(), avatar: avatar);
          print('if');
          print(user.toJson());
          G.loggedInId = userModel.id;
          G.loggedInUser = user;
        });
        await pr.hide();
//        await loadWallet();
        unawaited(Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (content) => Loading())));
//        Navigator.pushReplacement(context, MaterialPageRoute(
//            builder: (context) => Home(widget: Chat(), tab: 0,)));
        OCWA.toast('ຍິນດີຕ້ອນຮັບ!');
        await pr.hide();

      } else {
        await FirebaseFirestore.instance.collection(USERS).doc(phoneNo).set({
          AUTHENTICATION_TYPE: AuthenticationType.passcode.index,
          PUBLIC_KEY: pair.publicKey.toBase64(),
          COUNTRY_CODE: phoneCode,
          NICKNAME: _firstName.text.trim(),
          FULL_NAME: getFullName(_firstName.text.trim(), _lastName.text.trim()),
          FIRST_NAME: _firstName.text.trim(),
          LAST_NAME: _lastName.text.trim(),
          PASSWORD: userModel.password,
          PHOTO_URL: photoUrl,
          ID: userModel.id.toString(),
          UID: currentUser.uid,
          PHONE: phoneNo,
          ABOUT_ME: '',
          CREATED: userModel.created
        }, SetOptions(merge: true));
        // Write data to local
        await prefs.setString(ID, userModel.id.toString());
        await prefs.setString(UID, currentUser.uid);
        await prefs.setString(NICKNAME, _firstName.text.trim());
        await prefs.setString(FULL_NAME,
            getFullName(_firstName.text.trim(), _lastName.text.trim()));
        await prefs.setString(FIRST_NAME, _firstName.text.trim());
        await prefs.setString(LAST_NAME, _lastName.text.trim());
        await prefs.setString(PHOTO_URL, currentUser.photoURL);
        await prefs.setString(PHONE, phoneNo);
        await prefs.setString(COUNTRY_CODE, phoneCode);
        await prefs.setString(ACCOUNT_ID, _id.text.trim());
        await prefs.setString(USER, jsonEncode(userModel.toJson()));
        await prefs.setString(CREATED, userModel.created);

        final id = userModel.id.toString();
        final name = getFullName(_firstName.text.trim(), _lastName.text.trim());
        final created = userModel.created;
        final avatar = currentUser.photoURL;
        final user = UserModel(
            id: int.parse(id), name: name, created: created, avatar: avatar);
        setState(() {
          Global.userModel = new UserModel(
              id: int.parse(id), name: name, created: created.toString(), avatar: avatar);
          print('else');
          print(user.toJson());
          G.loggedInId = userModel.id;
          G.loggedInUser = user;
        });
        await pr.hide();
//        await loadWallet();
        unawaited(Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (content) => Loading())));
//        Navigator.pushReplacement(context, MaterialPageRoute(
//            builder: (context) => Home(widget: Chat(), tab: 0,)));
        OCWA.toast('ຍິນດີຕ້ອນຮັບ!');
      }
    } else {
      OCWA.toast("ລົງທະບຽນບໍ່ສຳເລັດ.");
    }
  }

  loadWallet() async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    await pr.show();
    pr.update(message: 'ກຳລັງເຂົ້າລະບົບ...');
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
}
