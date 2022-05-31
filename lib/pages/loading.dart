import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/chat/chat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/home.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'chat/tools/GlobalChat.dart';
import 'login/login.dart';

Services services = new StorageServiceSharedPreferences();

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  bool isLoading;
  bool isLoggedIn = false;
  static const String TAG = "LoginScreen.BodyState";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAuth();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  checkAuth() async {
    setState(() {
      isLoading = true;
    });

    dynamic data = await services.getValue(USER);

    final id = await services.getValue(ID);
    final name = await services.getValue(FULL_NAME);
    final created = await services.getValue(CREATED);
    final avatar = await services.getValue(PHOTO_URL);

    if (id != null) {
      G.loggedInId = int.parse(id);
      if (data != null) G.loggedInUser = UserModel.fromJson(json.decode(data));
      if (mounted) {
        setState(() {
          Global.userModel = UserModel(
              id: int.parse(id), name: name, created: created, avatar: avatar);
        });
      }

//      await loadWallet();
      setState(() {
        isLoading = false;
        isLoggedIn = true;

        Global.wallet = 0;
      });

    } else {
      setState(() {
        Global.wallet = 0;
        isLoading = false;
        isLoggedIn = false;
      });
    }
  }

  loadWallet() async {
    final id = await services.getValue(ID);
    try {
      final model = await NetworkUtil.post(
          '/wallet', jsonEncode({"id": await services.getValue(ACCOUNT_ID)}));
      final _list = await NetworkUtil.getTransferContact('/transfer-history');
      final checkWallet =
          await NetworkUtil.post('/wallet-status', jsonEncode({"id": id}));
      if (model.status == "success") {
        if (mounted) {
          setState(() {
            Global.wallet = model.data;
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
      } else {
        Global.enableWallet = false;
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return process();
  }

  process() {
    if (isLoading) {
      return WillPopScope(
        onWillPop: () async => exit(context),
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: UIHelper.SPOTIFY_COLOR),
            child: const SpinKitChasingDots(color: Colors.white),
          ),
        ),
      );
    } else {
      if (Global.wallet == null) {
        return WillPopScope(
          onWillPop: () async => exit(context),
          child: Center(
            child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: UIHelper.SPOTIFY_COLOR),
                child: Center(
                  child: FlatButton.icon(
                      height: 50,
                      color: UIHelper.APRICOT_PRIMARY_COLOR,
                      onPressed: () {
                        checkAuth();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text(
                        'ກົດເພື່ອດຶງຂໍ້ມູນໃໝ່',
                        style: TextStyle(fontSize: 22),
                      )),
                )),
          ),
        );
      } else {
        if (isLoggedIn) {
          return Home(
            widget: Chat(),
            tab: 0,
          );
        } else {
          return Login();
        }
      }
    }
  }

  exit(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
