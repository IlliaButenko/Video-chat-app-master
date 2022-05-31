import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:OCWA/utils/global.dart';
import 'package:flutter/material.dart';

Services services = new StorageServiceSharedPreferences();

class TransferHistory extends StatefulWidget {
  @override
  _TransferHistoryState createState() => new _TransferHistoryState();
}

class _TransferHistoryState extends State<TransferHistory> {
  bool _canSave = false;
  Future<List<TransferHistoryModel>> _data;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  int id;

  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Scaffold(
      appBar: new AppBar(
          title: const Text('ບັນຊີປາຍທາງທີ່ເຄີຍໂອນ'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: buildHistory(),
      )
    );
  }

  Widget buildHistory() {
    return FutureBuilder<List<TransferHistoryModel>>(
      future: NetworkUtil.getTransferContact('/transfer-history'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<TransferHistoryModel> data = snapshot.data;
          return _historyListView(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(
          child: Container(
            child: Text('ກຳລັງໂຫລດ....'),
          ),
        );
      },
    );
  }

  ListView _historyListView(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index){
          return _buildHistory(index, data);
        }
    );
  }

  Widget _buildHistory(int index, dynamic data){
    return Container(
      height: 80,
      margin: EdgeInsets.only(bottom: 2),
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        onTap: () {
          Navigator.pop(context, data[index]);
        },
        leading: CircleAvatar(
          radius: 25.0,
          backgroundImage: NetworkImage(data[index].avatar),
        ),
        title: Text(
          data[index].firstName + ' ' + data[index].lastName,
          style: TextStyle(
              color: UIHelper.SPOTIFY_COLOR,
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
        subtitle: Text(
          Global.showPhone(data[index].mobile),
          style: TextStyle(
              color: UIHelper.THEME_PRIMARY,
              fontSize: 15,
              fontWeight: FontWeight.bold
          ),
        ),
        trailing: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Column(
            children: <Widget>[
              Text(
                'ໄອດີ: ',
                style: TextStyle(
                    color: UIHelper.THEME_PRIMARY,
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(data[index].accountId, style: TextStyle(fontSize: 20),)
            ],
          ),
        ),
      ),
    );
  }
}