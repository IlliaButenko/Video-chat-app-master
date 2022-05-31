import 'dart:convert';

import 'package:OCWA/Controllers/firebaseController.dart';
import 'package:OCWA/Controllers/utils.dart';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/chat_model.dart';
import 'package:OCWA/models/record.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/global.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'tools/GlobalChat.dart';
import 'message.dart';

Services services = new StorageServiceSharedPreferences();

class UserPage extends StatefulWidget {
  final UserModel record;
  final void Function(UserModel item) callbackFunction;

  UserPage({this.record, this.callbackFunction});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, widget.record),
          ),
          title: new Text(widget.record.name),
        ),
        body: new ListView(children: <Widget>[
          Hero(
            tag: "avatar_" + widget.record.name,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: CachedNetworkImage(imageUrl: widget.record.avatar,
                placeholder: (context, url) => Container(
                transform: Matrix4.translationValues(0, 0, 0),
                child: Container(
                    child: Center(
                        child: new CircularProgressIndicator())),
              ),),
            ),
          ),
          GestureDetector(
              onTap: () {
                //URLLauncher().launchURL(record.url);
              },
              child: new Container(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                child: new Row(
                  children: [
                    // First child in the Row for the name and the
                    new Expanded(
                      // Name and Address are in the same column
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Code to create the view for name.
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  child: new Text(
                                    "ຊື່ ແລະ ນາມສະກຸນ",
                                    style: new TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.record.name,
                                  style: TextStyle(fontSize: 20),
                                )
                              ]),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Text("@${widget.record.accountId}"),
                        Row(
                          children: <Widget>[
                            new Icon(
                              Icons.phone,
                              color: Colors.red[500],
                            ),
                            new Text(
                                ' ${Global.showPhone(widget.record.mobile)}'),
                          ],
                        )
                      ],
                    )
                    // Icon to indicate the phone number.
                  ],
                ),
              )),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              getButton(),
              PopupMenuButton<int>(
                onSelected: (value) {
                  print(value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.block,
                          size: 24.0,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('Block'),
                      ],
                    ),
                  ),
                ],
                icon: Icon(Icons.more_vert),
                offset: Offset(0, 100),
              )
//              PopupMenuButton<Options>(
//                tooltip: "More options",
//                onSelected: _selectOption,
//                itemBuilder: (BuildContext context) {
//                  return _popupMenus;
//                },
//              )
            ],
          )
        ]));
  }

  // ignore: missing_return
  Widget getButton() {
    int friendStatus = widget.record.friendStatus;
    print(friendStatus);
    if (friendStatus == -1) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Container(
          height: 30.0,
          child: FlatButton.icon(
              onPressed: () {
                addFriend(context);
              },
              color: UIHelper.SPOTIFY_COLOR,
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text(
                'ເພີ່ມເພື່ອນ',
                style: TextStyle(color: Colors.white),
              )),
        ),
        SizedBox(
          width: 4.0,
        ),
      ]);
    }
    if (friendStatus == 0) {
      if (widget.record.actionUserId == G.loggedInUser.id) {
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Container(
            height: 30.0,
            child: FlatButton.icon(
                onPressed: () {
                  cancelFriendRequest(context);
                },
                color: UIHelper.AVOCADOS_SECONDARY_COLOR,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  'ຍົກເລີກ',
                  style: TextStyle(color: Colors.white),
                )),
          ),
          SizedBox(
            width: 4.0,
          ),
        ]);
      } else {
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Container(
            height: 30.0,
            child: FlatButton.icon(
                onPressed: () {
                  acceptFriendRequest(context);
                },
                color: UIHelper.SPOTIFY_COLOR,
                icon: Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  'ຢືນຢັນ',
                  style: TextStyle(color: Colors.white),
                )),
          ),
          SizedBox(
            width: 4.0,
          ),
          Container(
            height: 30.0,
            child: FlatButton.icon(
                onPressed: () {
                  rejectFriendRequest(context);
                },
                color: UIHelper.WATERMELON_PRIMARY_COLOR,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  'ປະຕິເສດ',
                  style: TextStyle(color: Colors.white),
                )),
          ),
          SizedBox(
            width: 4.0,
          ),
        ]);
      }
    }
    if (friendStatus == 1) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Container(
          height: 30.0,
          child: FlatButton.icon(
              onPressed: () {
                _moveTochatRoom(context);
              },
              color: UIHelper.SPOTIFY_COLOR,
              icon: Icon(
                Icons.chat,
                color: Colors.white,
              ),
              label: Text(
                'ສົນທະນາ',
                style: TextStyle(color: Colors.white),
              )),
        ),
        SizedBox(
          width: 4.0,
        ),
        Container(
          height: 30.0,
          child: FlatButton.icon(
              onPressed: () {
                removeFriend(context);
              },
              color: UIHelper.THEME_PRIMARY,
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.white,
              ),
              label: Text(
                'ເລີກເປັນເພື່ອນ',
                style: TextStyle(color: Colors.white),
              )),
        ),
        SizedBox(
          width: 4.0,
        ),
      ]);
    }
    return Container();
  }

  addFriend(BuildContext context) async {
    final data = jsonEncode({
      "id": await services.getValue('id'),
      "userOneId": await services.getValue('id'),
      "userTwoId": widget.record.id.toString()
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/send-friend-request', data);
      await pr.hide();
      Alert.success(context, 'ສຳເລັດ',
          'ທ່ານໄດ້ສົ່ງຂໍ (' + widget.record.name + ') ເປັນເພື່ອນແລ້ວ', 'OK');
      if (result.status == "success") {
        setState(() {
          widget.record.friendStatus = 0;
          widget.record.actionUserId = G.loggedInUser.id;
        });
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }

  cancelFriendRequest(BuildContext context) async {
    final data = jsonEncode({
      "id": await services.getValue('id'),
      "userOneId": await services.getValue('id'),
      "userTwoId": widget.record.id.toString()
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/cancel-friend-request', data);
      await pr.hide();
      Alert.success(context, 'ສຳເລັດ',
          'ທ່ານໄດ້ຍົກເລີກຂໍ (' + widget.record.name + ') ເປັນເພື່ອນແລ້ວ', 'OK');
      if (result.status == "success") {
        setState(() {
          widget.record.friendStatus = -1;
          widget.record.actionUserId = -1;
        });
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }

  acceptFriendRequest(BuildContext context) async {
    final data = jsonEncode({
      "id": await services.getValue('id'),
      "userOneId": await services.getValue('id'),
      "userTwoId": widget.record.id.toString()
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/accept-friend-request', data);
      await pr.hide();
      Alert.success(context, 'ສຳເລັດ',
          'ທ່ານໄດ້ຮັບ (' + widget.record.name + ') ເປັນເພື່ອນແລ້ວ', 'OK');
      if (result.status == "success") {
        setState(() {
          widget.record.friendStatus = 1;
          widget.record.actionUserId = G.loggedInUser.id;
        });
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }

  rejectFriendRequest(BuildContext context) async {
    final data = jsonEncode({
      "id": await services.getValue('id'),
      "userOneId": await services.getValue('id'),
      "userTwoId": widget.record.id.toString()
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/cancel-friend-request', data);
      await pr.hide();
      Alert.success(context, 'ສຳເລັດ',
          'ທ່ານໄດ້ປະຕິເສດ (' + widget.record.name + ') ເປັນເພື່ອນແລ້ວ', 'OK');
      if (result.status == "success") {
        setState(() {
          widget.record.friendStatus = -1;
          widget.record.actionUserId = -1;
        });
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }

  removeFriend(BuildContext context) async {
    final data = jsonEncode({
      "id": await services.getValue('id'),
      "userOneId": await services.getValue('id'),
      "userTwoId": widget.record.id.toString()
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/cancel-friend-request', data);
      await pr.hide();
      Alert.success(context, 'ສຳເລັດ',
          'ທ່ານໄດ້ລົບ (' + widget.record.name + ') ອອກຈາກເພື່ອນແລ້ວ', 'OK');
      if (result.status == "success") {
        setState(() {
          widget.record.friendStatus = -1;
          widget.record.actionUserId = -1;
        });
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }

  Future<void> _moveTochatRoom(context) async {
    try {
        final token = await FirebaseController.instance.getUserToken(widget.record.phone);
      String chatID = makeChatId(G.loggedInId, widget.record.id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Messages(
                  G.loggedInId,
                  G.loggedInUser.name,
                  token,
                  widget.record.id,
                  chatID,
                  widget.record.name,
                  widget.record.avatar,
                  "+" + Global.getPhone(widget.record.phone))));
    } catch (e) {
      print(e.message);
    }
  }
}
