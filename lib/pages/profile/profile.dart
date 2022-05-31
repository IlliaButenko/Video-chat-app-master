import 'dart:convert';
import 'dart:io';

import 'package:OCWA/Controllers/firebaseController.dart';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/enum/user_state.dart';
import 'package:OCWA/main.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/ImagePicker/camera_picker.dart';
import 'package:OCWA/pages/ImagePicker/image_picker.dart';
import 'package:OCWA/pages/callscreens/pickup/pickup_layout.dart';
import 'package:OCWA/pages/chat/chat.dart';
import 'package:OCWA/pages/chat/fullphoto.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/home.dart';
import 'package:OCWA/pages/login/login.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/functions.dart';
import 'package:OCWA/utils/global.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:commons/commons.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../const.dart';

Services services = new StorageServiceSharedPreferences();

class Profile extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<Profile>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  UserModel user = UserModel();
  TextEditingController _firstName;
  TextEditingController _lastName;
  TextEditingController _email;
  TextEditingController _phone;
  String _avatar;
  File file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firstName = new TextEditingController();
    _lastName = new TextEditingController();
    _email = new TextEditingController();
    _phone = new TextEditingController();
    init();
  }

  init() async {
    user = UserModel.fromJson(jsonDecode(await services.getValue('user')));
    setState(() {
      _firstName.text = user.firstName;
      _lastName.text = user.lastName;
      _email.text = user.email;
      _phone.text = Global.showPhone(user.phone);
      _avatar = user.avatar; //Global.userModel.avatar;
    });
  }

  Future<bool> logout(BuildContext context) async {
    confirmationDialog(context, "ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ?",
        title: 'ອອກຈາກລະບົບ',
        confirm: false,
        neutralText: 'ຕ້ອງການ',
        positiveText: "ບໍ່ຕ້ອງການ",
        positiveAction: () {}, neutralAction: () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      FirebaseController.instance.setUserState(
          userId: Global.firePhone(G.loggedInUser.phone),
          userState: UserState.Offline);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: WillPopScope(
        onWillPop: () async => goTo(context),
        child: new Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.person),
                iconSize: 50.0,
                color: Colors.white,
                onPressed: () {},
              ),
              title: Text('ໂປຼໄຟລ'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.lock),
                  iconSize: 30.0,
                  color: Colors.white,
                  onPressed: () {
                    logout(context);
                  },
                ),
              ],
            ),
            body: new Container(
              color: Colors.white,
              child: new ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      if (_avatar != null)
                        new Container(
                          height: 180.0,
                          color: Colors.white,
                          child: new Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: new Stack(
                                    fit: StackFit.loose,
                                    children: <Widget>[
                                      new Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullPhoto(
                                                      url: _avatar,
                                                      imageProvider:
                                                          CachedNetworkImageProvider(
                                                              _avatar),
                                                    ),
                                                  ));
                                            },
                                            child: new Container(
                                                width: 140.0,
                                                height: 140.0,
                                                decoration: new BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: new DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            _avatar),
                                                    fit: BoxFit.cover,
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _settingModalBottomSheet(context);
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 90.0, right: 100.0),
                                            child: new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                      ),
                                    ]),
                              )
                            ],
                          ),
                        ),
                      if (_avatar == null)
                        new Container(
                          height: 180.0,
                          color: Colors.white,
                          child: new Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: new Stack(
                                    fit: StackFit.loose,
                                    children: <Widget>[
                                      new Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Container(
                                              width: 140.0,
                                              height: 140.0,
                                              decoration: new BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: new DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/default_profile.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _settingModalBottomSheet(context);
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 90.0, right: 100.0),
                                            child: new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                      ),
                                    ]),
                              )
                            ],
                          ),
                        ),
                      new Container(
                        color: Color(0xffFFFFFF),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 25.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'ຂໍ້ມູນສ່ວນຕົວ',
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          _status
                                              ? _getEditIcon()
                                              : new Container(),
                                        ],
                                      )
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'ຊື່',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextField(
                                          decoration: const InputDecoration(
                                            hintText: "",
                                          ),
                                          enabled: !_status,
                                          autofocus: !_status,
                                          controller: _firstName,
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'ນາມສະກຸນ',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextField(
                                          decoration: const InputDecoration(
                                            hintText: "",
                                          ),
                                          enabled: !_status,
                                          autofocus: !_status,
                                          controller: _lastName,
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'ອີເມວ',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextField(
                                          decoration: const InputDecoration(
                                              hintText: ""),
                                          enabled: !_status,
                                          controller: _email,
                                        ),
                                      ),
                                    ],
                                  )),
                              !_status ? _getActionButtons() : new Container(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("ບັນທຶກ"),
                textColor: Colors.white,
                color: UIHelper.SPOTIFY_COLOR,
                onPressed: () async {
                  _updateProfile(context);
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("ຍົກເລີກ"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Future<bool> goTo(BuildContext context) async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  widget: Chat(),
                  tab: 0,
                )));
    return false;
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text('ຖ່າຍຮູບ'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HybridCameraPicker(
                                    title: 'ຖ່າຍຮູບ',
                                    callback: getFile,
                                  ))).then((url) {
                        if (url != null) {
                          Navigator.pop(context);
                          _updateAvatar(context, url);
                        }
                      });
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo),
                  title: new Text('ເລືອກຮູບ'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HybridImagePicker(
                                  title: 'ເລືອກຮູບ',
                                  callback: getFile,
                                ))).then((url) {
                      if (url != null) {
                        Navigator.pop(context);
                        _updateAvatar(context, url);
                      }
                    });
                  },
                ),
              ],
            ),
          );
        });
  }

  getFile(File _file) {
    if (_file != null) {
      setState(() {
        file = _file;
      });
    }
    return uploadFile();
  }

  getImageFileName(id, timestamp) {
    return "$id-$timestamp";
  }

  Future uploadFile() async {
    final uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName =
        getImageFileName(G.loggedInId.toString(), '$uploadTimestamp');
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    TaskSnapshot uploading;
    uploading = await reference.putFile(file);
    return uploading.ref.getDownloadURL();
  }

  void _updateAvatar(context, url) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    await pr.show();
    pr.update(message: 'ກຳລັງດຳເນີນ...');

    await FirebaseController.instance.updateUserAvatar(url);

    final data = jsonEncode({"id": G.loggedInUser.id, "avatar": url});

    final result = await NetworkUtil.post('/edit-customer-avatar', data);
    await pr.hide();
    if (result.status == 'success') {
      Alert.success(context, 'ສຳເລັດ', 'ຮູບພາບທ່ານໄດ້ຖືກປ່ຽນແລ້ວ', 'OK');
      setState(() {
        _avatar = url;
        Global.userModel.avatar = url;
      });
      //print(jsonEncode(result.data));
      services.setValue(USER, null);
      services.setValue(USER, jsonEncode(result.data));
      services.setValue(PHOTO_URL, url);
    } else {
      Alert.error(context, 'ບໍ່ສຳເລັດ', 'ເກີດຂໍ້ຜິດພາດກະລຸນາລອງໃໝ່', 'OK');
    }
  }

  void _updateProfile(context) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    await pr.show();
    pr.update(message: 'ກຳລັງດຳເນີນ...');
    try {
      await FirebaseController.instance.updateUserProfile(
          G.loggedInUser.id, _firstName.text, _lastName.text, _email.text);

      final data = jsonEncode({
        "id": G.loggedInUser.id,
        "firstName": _firstName.text,
        "lastName": _lastName.text,
        "email": _email.text
      });

      final result = await NetworkUtil.post('/edit-customer', data);
      await pr.hide();
      if (result.status == 'success') {
        Alert.success(
            context, 'ສຳເລັດ', 'ຂໍ້ມູນສ່ວນຕົວທ່ານໄດ້ຖືກປ່ຽນແລ້ວ', 'OK');
        services.setValue(USER, null);
        services.setValue(USER, jsonEncode(result.data));
        services.setValue(FULL_NAME, getFullName(_firstName.text, _lastName.text));
      } else {
        Alert.error(context, 'ບໍ່ສຳເລັດ', 'ເກີດຂໍ້ຜິດພາດກະລຸນາລອງໃໝ່', 'OK');
      }
    } catch (e) {
      Alert.error(context, 'ບໍ່ສຳເລັດ', 'ເກີດຂໍ້ຜິດພາດກະລຸນາລອງໃໝ່', 'OK');
      await pr.hide();
    }
  }
}
