import 'dart:async';
import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/ui/dialog/transaction_detail.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:OCWA/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Services services = new StorageServiceSharedPreferences();

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final formatter = new NumberFormat("#,###");
  dynamic timer;
  dynamic wallet;
  dynamic income;
  dynamic expense;
  dynamic id;
  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    super.initState();
    timer = Timer(Duration(milliseconds: 1), () => loadWallet());
  }

  loadWallet() async {
    id = await services.getValue(ACCOUNT_ID);
    final _wallet =
        await NetworkUtil.post('/wallet', jsonEncode({"id": id}));
    final _income =
        await NetworkUtil.post('/income', jsonEncode({"id": id}));
    final _expense =
        await NetworkUtil.post('/expense', jsonEncode({"id": id}));
    if (_wallet.status == "success") {
      setState(() {
        isLoading = false;
        wallet = _wallet.data;
        income = _income.data;
        expense = _expense.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light,
    );
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text(
            'ປະຫວັດການເຄື່ອນໄຫວ',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w300,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 160,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              decoration: BoxDecoration(
                  color: UIHelper.SPOTIFY_COLOR,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            'ຍອດລວມ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 1.5),
                          ),
                          if (isLoading == true)
                            Center(
                              child: Container(
                                child: Text('ກຳລັງໂຫລດ....',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12.0)),
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.only(
                                  top: 5.0,
                                  left: 10.0,
                                  bottom: 5.0,
                                  right: 10.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    (wallet != null)
                                        ? formatter.format(wallet).toString()
                                        : '0',
                                    style: TextStyle(
                                        color: UIHelper.THEME_PRIMARY,
                                        fontSize: 25,
                                        letterSpacing: 1.5,
                                        fontFamily: 'Muli',
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ' LAK',
                                    style: TextStyle(
                                        fontSize: 10, color: UIHelper.SPOTIFY_COLOR, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.arrow_downward,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'ລາຍຮັບ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 1.5),
                          ),
                          if (isLoading == true)
                            Center(
                              child: Container(
                                child: Text('ກຳລັງໂຫລດ....',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12.0)),
                              ),
                            )
                          else
                            Row(
                              children: <Widget>[
                                Text(
                                  (income != null)
                                      ? formatter
                                          .format(
                                              Global.removeDecimalZeroFormat(
                                                  income))
                                          .toString()
                                      : '0',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: UIHelper.WHITE,
                                      fontSize: 18,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' LAK',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                )
                              ],
                            )
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_upward,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'ລາຍຈ່າຍ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 1.5),
                          ),
                          if (isLoading == true)
                            Center(
                              child: Container(
                                child: Text(
                                  'ກຳລັງໂຫລດ....',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12.0),
                                ),
                              ),
                            )
                          else
                            Row(
                              children: <Widget>[
                                Text(
                                  (expense != null)
                                      ? formatter
                                          .format(
                                              Global.removeDecimalZeroFormat(
                                                  expense))
                                          .toString()
                                      : '0',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' LAK',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                )
                              ],
                            )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: buildTransactions(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTransactions() {
    return FutureBuilder<List<Transaction>>(
      future: NetworkUtil.getTransaction('/transaction'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Transaction> data = snapshot.data;
          return _transactionListView(data);
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

  ListView _transactionListView(data) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _buildTransactions(index, data);
        });
  }

  Widget _buildTransactions(int index, data) {
    Transaction tr = data[index];
    return Container(
      height: 90,
      margin: EdgeInsets.only(bottom: 2),
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () {
          _openDialog(tr);
        },
        leading: Container(
          height: 60,
          width: 60,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: UIHelper.SPOTIFY_COLOR,
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: NetworkImage(
                      'https://ui-avatars.com/api/?name=' + tr.status),
                  fit: BoxFit.fill)),
        ),
        title: Text(
          getType(data[index].type, data[index].status),
          style: kTextStyle(18, FontWeight.w600),
        ),
        subtitle: Text(
          getStatus(data[index].status),
          style: kTextStyle(13, null),
        ),
        trailing: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            formatter.format(tr.amount) + ' LAK',
            style: TextStyle(
                color:
                    data[index].status == 'expense' ? Colors.red : Colors.green,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future _openDialog(Transaction transaction) async {
    await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new TransactionDetail(
            transaction: transaction,
          );
        },
        fullscreenDialog: true));
  }

  getStatus(String status) {
    if (status == 'expense') return 'ລາຍຈ່າຍ';
    if (status == 'income') {
      return 'ລາຍຮັບ';
    }
  }

  getType(String type, String status) {
    if (type == 'Transfer') {
      if (status == 'expense') return 'ໂອນເງິນອອກ';
      if (status == 'income') return 'ໄດ້ຮັບເງິນໂອນ';
    }
    if (type == 'Withdraw') {
      return 'ຖອນເງິນອອກ';
    }
    if (type == 'Recharge') {
      return 'ຈ່າຍຄ່າໂທລະສັບ';
    }
    if (type == 'Deposit') {
      return 'ເຕີມເງິນເຂົ້າ';
    }
    if (type == 'Payment') {
      return 'ຊຳລະເງິນ';
    }
    return 'ທົ່ວໄປ';
  }
}
