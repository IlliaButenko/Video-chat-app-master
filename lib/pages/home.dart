import 'dart:convert';

import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/callscreens/pickup/pickup_layout.dart';
import 'package:OCWA/pages/login/login.dart';
import 'package:OCWA/pages/profile/profile.dart';
import 'package:OCWA/pages/qr/generate.dart';
import 'package:OCWA/pages/qr/scan.dart';
import 'package:OCWA/pages/settings/settings.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat/chat.dart';
import 'dasboard/dasboard.dart';

Services services = new StorageServiceSharedPreferences();

class Home extends StatefulWidget {
  int tab;
  Widget widget;
  Home({Key key, this.title, this.tab, this.widget}) : super(key: key);
  final String title;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  // Properties & Variables needed

  int currentTab = 0; // to keep track of active tab index
  final List<Widget> screens = [
    Chat(),
    Dashboard(),
    Profile(),
    SettingsScreen(),
  ]; // to store nested tabs
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Chat(); // Our first view in viewport

  @override
  void initState() {
    super.initState();
    currentTab = widget.tab;
    currentScreen = widget.widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageStorage(
          child: currentScreen,
          bucket: bucket,
        ),
        floatingActionButton: FloatingActionButton(
          child: Image.asset(
              'assets/images/qrscan_2.png', width: 35.0, color: Colors.white,),
          backgroundColor: UIHelper.SPOTIFY_COLOR,
          foregroundColor: Colors.white,
          onPressed: () {
            scan(context);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          currentScreen =
                              Chat(); // if user taps on this dashboard tab will be active
                          currentTab = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.chat,
                            color: currentTab == 0 ? UIHelper.SPOTIFY_COLOR : Colors.grey,
                          ),
                          Text(
                            'ສົນທະນາ',
                            style: TextStyle(
                              color: currentTab == 0 ? UIHelper.SPOTIFY_COLOR : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          currentScreen =
                              Dashboard(); // if user taps on this dashboard tab will be active
                          currentTab = 1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.account_balance_wallet,
                            color: currentTab == 1 ? UIHelper.SPOTIFY_COLOR : Colors.grey,
                          ),
                          Text(
                            'ກະເປົາ',
                            style: TextStyle(
                              color: currentTab == 1 ? UIHelper.SPOTIFY_COLOR : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Right Tab bar icons

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          currentScreen =
                              Profile(); // if user taps on this dashboard tab will be active
                          currentTab = 2;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: currentTab == 2 ? UIHelper.SPOTIFY_COLOR : Colors.grey,
                          ),
                          Text(
                            'ໂປຼໄຟລ',
                            style: TextStyle(
                              color: currentTab == 2 ? UIHelper.SPOTIFY_COLOR : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          currentScreen =
                              SettingsScreen(); // if user taps on this dashboard tab will be active
                          currentTab = 3;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.settings,
                            color: currentTab == 3 ? UIHelper.SPOTIFY_COLOR : Colors.grey,
                          ),
                          Text(
                            'ຕັ້ງຄ່າ',
                            style: TextStyle(
                              color: currentTab == 3 ? UIHelper.SPOTIFY_COLOR : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )

              ],
            ),
          ),
        ),
      )
    ;
  }

  void scan(BuildContext context) async {
    var status = await Permission.camera.status;
    if (status.isUndetermined || status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      if (await Permission.camera.request().isGranted) {
        navigator(context, ScanScreen(type: 'pay',));
      }
    }
    if (status.isGranted) {
      navigator(context, ScanScreen(type: 'pay',));
    }
  }

  @override
  bool get wantKeepAlive => true;
}