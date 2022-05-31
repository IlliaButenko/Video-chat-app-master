import 'package:OCWA/Controllers/firebaseController.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/enum/user_state.dart';
import 'package:OCWA/pages/callscreens/pickup/pickup_layout.dart';
import 'package:OCWA/pages/chat/chat.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/login/login.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/global.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../home.dart';
import 'languages_screen.dart';

Services services = new StorageServiceSharedPreferences();

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;
  TextEditingController _id = TextEditingController();
  TextEditingController _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: WillPopScope(
        onWillPop: () async => goTo(context),
        child: new Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.settings),
              iconSize: 50.0,
              color: Colors.white,
              onPressed: () {},
            ),
            title: Text('ຕັ້ງຄ່າ'),
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
          body: SettingsList(
            backgroundColor: Colors.white,
            darkBackgroundColor: Colors.white,
            lightBackgroundColor: Colors.white,
            sections: [
              SettingsSection(
                title: 'ທົ່ວໄປນ',
                tiles: [
                  SettingsTile(
                    title: 'ພາສາ',
                    subtitle: 'ລາວ',
                    leading: Icon(Icons.language),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              LanguagesScreen()));
                    },
                  ),
                  SettingsTile(
                    title: 'ຊ່ວຍເຫຼືອ',
                    leading: Icon(Icons.help),
                    onTap: () {},
                  ),
                ],
              ),
              SettingsSection(
                title: 'ບັນຊີ',
                tiles: [
                  SettingsTile(
                    title: 'ໄອດີ',
                    leading: Icon(Icons.verified_user),
                    subtitle: '@${G.loggedInUser.accountId}',
                    trailing: FlatButton.icon(
                      onPressed: () {
                        changeId(context);
                      },
                      icon: Icon(Icons.edit),
                      label: Text('ປ່ຽນ'),
                      color: UIHelper.AVOCADOS_SECONDARY_COLOR,
                    ),
                  ),
                  SettingsTile(
                      title: 'ເບີໂທລະສັບ',
                      subtitle: Global.showPhone(G.loggedInUser.phone),
                      leading: Icon(Icons.phone),
                      trailing: FlatButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.edit),
                        label: Text('ປ່ຽນ'),
                        color: UIHelper.AVOCADOS_SECONDARY_COLOR,
                      )),
                ],
              ),
              SettingsSection(
                title: 'ຄວາມປອດໄພ',
                tiles: [
//                  SettingsTile.switchTile(
//                    title: 'Lock app in background',
//                    leading: Icon(Icons.phonelink_lock),
//                    switchValue: lockInBackground,
//                    onToggle: (bool value) {
//                      setState(() {
//                        lockInBackground = value;
//                        notificationsEnabled = value;
//                      });
//                    },
//                  ),
//                  SettingsTile.switchTile(
//                      title: 'Use fingerprint',
//                      leading: Icon(Icons.fingerprint),
//                      onToggle: (bool value) {},
//                      switchValue: false),
                  SettingsTile.switchTile(
                    title: 'Lock ກະເປົາທຸກຄັ້ງ',
                    leading: Icon(Icons.lock),
                    switchValue: true,
                    onToggle: (bool value) {},
                  ),
                  SettingsTile.switchTile(
                    title: 'ເປີດຮັບແຈ້ງເຕືອນ',
                    enabled: notificationsEnabled,
                    leading: Icon(Icons.notifications_active),
                    switchValue: true,
                    onToggle: (value) {},
                  ),
                ],
              ),
              SettingsSection(
                title: 'ຂໍ້ກຳນົດ ແລະ ກົດລະບຽນການນຳໃຊ້',
                tiles: [
                  SettingsTile(
                      title: 'ຂໍ້ກຳນົດ ແລະ ເງື່ອນໄຂການນຳໃຊ້',
                      leading: Icon(Icons.description)),
                  SettingsTile(
                      title: 'ຂໍ້ມູນສ່ວນບຸກຄົນ',
                      leading: Icon(Icons.collections_bookmark)),
                ],
              )
            ],
          ),
        ),
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

  changeId(BuildContext context) async {
    String id = await idDialog(context);

    if (id.isEmpty)
      return;


  }

  Future<String> idDialog(BuildContext context) async {
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
          child: _dialogIdContent(context),
        );
      },
    );
  }

  _dialogIdContent(BuildContext context) {
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
                  'ປ້ອນໄອດີໃໝ່ທີ່ຕ້ອງການ',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Text(
                      'ໄອດີເກົ່າ: @${G.loggedInUser.accountId}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: TextFormField(
                    controller: _id,
                    keyboardType: TextInputType.text,
                    autocorrect: true,
                    obscureText: false,
                    style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                    decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: 'ໃສ່ໄອດີທີ່ຕ້ອງການ',
                        hintText: '',
                        prefixText: '@',
                        hintStyle: TextStyle(color: UIHelper.MUZ_TEXT_COLOR),
                        border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0))),
                  ),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text('ບັນທຶກ', style: TextStyle(color: Colors.white),),
                        color: UIHelper.SPOTIFY_COLOR,
                        onPressed: () {
                          print(_id.text);
                          if (_id.text.trim().isEmpty) {
                            Alert.warning(context, 'ແຈ້ງເຕືອນ',
                                'ກະລຸນາປ້ອນໄອດີ', 'OK');
                            return;
                          } else {
                            Navigator.of(context).pop(_id.text);
                          }
                        },
                      ),
                      FlatButton(
                        child: Text('ປິດ'),
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
}
