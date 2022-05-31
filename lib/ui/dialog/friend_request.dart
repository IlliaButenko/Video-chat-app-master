import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/models/record.dart';
import 'package:OCWA/models/record_list.dart';
import 'package:OCWA/models/record_service.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/chat/user.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

enum Options { advanceSearch }

class FriendRequestDialog extends StatefulWidget {
  @override
  _FriendRequestDialogState createState() {
    return _FriendRequestDialogState();
  }
}

class _FriendRequestDialogState extends State<FriendRequestDialog> {
  final TextEditingController _filter = new TextEditingController();

  RecordList _records = new RecordList();
  RecordList _filteredRecords = new RecordList();

  String _searchText = "";
  bool isSearch = false;
  Icon _searchIcon = new Icon(Icons.search);

  Widget _appBarTitle = new Text('ຄົນທີ່ຂໍທ່ານເປັນເພື່ອນ');
  List<List<PopupMenuItem<Options>>> _popupMenus;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _records.records = new List();
    _filteredRecords.records = new List();
    _popupMenus = [
      [
        PopupMenuItem<Options>(
          child: Text("ຄົ້ນຫາຂັ້ນສູງ"),
          value: Options.advanceSearch,
        ),
      ],
    ];
    _getRecords();
  }

  void _getRecords() async {
    RecordService.type = 'receive';
    RecordList records = await RecordService().loadRecords();

    setState(() {
      isLoading = false;
      for (UserModel record in records.records) {
        this._records.records.add(record);
        this._filteredRecords.records.add(record);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      backgroundColor: appDarkGreyColor,
      body: (isLoading)
          ? Center(
              child: Container(
                child: Text(
                  'ກຳລັງໂຫລດ....',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          :  _filteredRecords.records.length > 0 ? _buildList(context) : Container(),
      //_filteredRecords.records.length > 0 ? _buildList(context) : Container(),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
        elevation: 0.1,
        backgroundColor: UIHelper.SPOTIFY_COLOR,
        centerTitle: true,
        title: _appBarTitle,
        actions: <Widget>[
          new IconButton(icon: _searchIcon, onPressed: _searchPressed),
        ]);
  }

  void _selectOption(Options option) {
    switch (option) {
      case Options.advanceSearch:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => FriendRequestDialog()));
        break;
    }
  }

  Widget _buildList(BuildContext context) {
    if (!(_searchText.isEmpty)) {
      _filteredRecords.records = new List();
      for (int i = 0; i < _records.records.length; i++) {
        if (_records.records[i].name
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          _filteredRecords.records.add(_records.records[i]);
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: this
          ._filteredRecords
          .records
          .map((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, UserModel record) {
    return Card(
      key: ValueKey(record.name),
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        child: Column(children: <Widget>[
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.white24))),
                child: Hero(
                    tag: "avatar_" + record.name,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(record.avatar),
                    ))),
            title: Text(
              record.name,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: <Widget>[
                new Flexible(
                    child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: "@${record.accountId}",
                          style: TextStyle(color: Colors.white),
                        ),
                        maxLines: 3,
                        softWrap: true,
                      )
                    ]))
              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right,
                color: Colors.white, size: 30.0),
            onTap: () async {
              final tmp = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return new UserPage(record: record);
              }));
              setState(() {
                record = tmp;
                if (record.friendStatus == 1)
                  _filteredRecords.records
                      .removeWhere((element) => element.id == record.id);
              });
            },
          ),
          getButton(record, context),
        ]),
      ),
    );
  }

  _FriendRequestDialogState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _resetRecords();
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  void _resetRecords() {
    this._filteredRecords.records = new List();
    for (UserModel record in _records.records) {
      this._filteredRecords.records.add(record);
    }
  }

  void _searchPressed() {
    setState(() {
      isSearch = true;
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          style: new TextStyle(color: Colors.white),
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search, color: Colors.white),
            fillColor: Colors.white,
            hintText: 'ຄົ້ນຫາຕາມຊື່',
            hintStyle: TextStyle(color: Colors.white),
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('ຜູ້ຄົນທັງໝົດ');
        isSearch = false;
        _filter.clear();
      }
    });
  }

  Widget getButton(UserModel record, BuildContext context) {
    if (record.friendStatus == 0) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Container(
          height: 28.0,
          margin: const EdgeInsets.only(bottom: 5.0),
          child: FlatButton.icon(
              onPressed: () {
                acceptFriendRequest(context, record);
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
          height: 28.0,
          margin: const EdgeInsets.only(bottom: 5.0),
          child: FlatButton.icon(
              onPressed: () {
                rejectFriendRequest(context, record);
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
    return Container();
  }

  acceptFriendRequest(BuildContext context, UserModel record) async {
    final data = jsonEncode({
      "id": await services.getValue('id'),
      "userOneId": await services.getValue('id'),
      "userTwoId": record.id.toString()
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/accept-friend-request', data);
      await pr.hide();
      Alert.success(context, 'ສຳເລັດ',
          'ທ່ານໄດ້ຮັບ (' + record.name + ') ເປັນເພື່ອນແລ້ວ', 'OK');
      if (result.status == "success") {
        setState(() {
          record.friendStatus = 1;
          record.actionUserId = G.loggedInUser.id;
          if (record.friendStatus == 1)
            _filteredRecords.records.removeWhere((element) => element.id == record.id);
        });
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }

  rejectFriendRequest(BuildContext context, UserModel record) async {
    final data = jsonEncode({
      "id": await services.getValue('id'),
      "userOneId": await services.getValue('id'),
      "userTwoId": record.id.toString()
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/cancel-friend-request', data);
      await pr.hide();
      Alert.success(context, 'ສຳເລັດ',
          'ທ່ານໄດ້ປະຕິເສດ (' + record.name + ') ເປັນເພື່ອນແລ້ວ', 'OK');
      if (result.status == "success") {
        setState(() {
          record.friendStatus = -1;
          record.actionUserId = -1;
          if (record.friendStatus == -1)
            _filteredRecords.records.removeWhere((element) => element.id == record.id);
        });
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }
}
