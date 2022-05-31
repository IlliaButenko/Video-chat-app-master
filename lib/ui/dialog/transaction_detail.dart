import 'dart:convert';

import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/models/transaction_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:OCWA/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Services services = new StorageServiceSharedPreferences();

class TransactionDetail extends StatefulWidget {

  Transaction transaction;
  TransactionDetail({Key key, this.transaction}) : super(key: key);

  @override
  _TransactionDetailState createState() => new _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  int id;
  final formatter = new NumberFormat("#,###");
  String type;
  String status;
  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    type = widget.transaction.type;
    status = widget.transaction.status;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('ລາຍລະອຽດທຸລະກຳ'),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: ListView(
                padding: const EdgeInsets.only(top: 10.0),
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 8.00),
                        child: Text(Global.dateOnly(widget.transaction.created)),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8.00),
                        child: Text(Global.timeAndSec(widget.transaction.created)),
                      )
                    ],
                  ),
                  Container(
                    height: 30.0,
                    alignment: AlignmentDirectional.center,
                    child: Center(
                      child: Text(getTitle(widget.transaction.type, widget.transaction.status), style: TextStyle(fontSize: 22),),
                    ),
                  ),
                  Container(
                    height: 75,
                    margin: EdgeInsets.only(bottom: 1),
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: ListTile(
                      title: Text(
                        'ໝາຍເລກອ້າງອີງ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        widget.transaction.transactionId,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: UIHelper.STRAWBERRY_SECONDARY_COLOR,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (type != 'Recharge')
                    Container(
                    height: 75,
                    margin: EdgeInsets.only(bottom: 1),
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                        borderRadius: BorderRadius.circular(0)),
                    child: ListTile(
                      title: Text(
                        'ຊື້ ແລະ ນາມນະກຸນ',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black45,
                            fontWeight: FontWeight.normal),
                      ),
                      subtitle: Text(
                        (status == 'expense' || type == 'Deposit') ? widget.transaction.name2 : widget.transaction.name,
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                  ),
                  Container(
                    height: 75,
                    margin: EdgeInsets.only(bottom: 1),
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                        borderRadius: BorderRadius.circular(0)),
                    child: ListTile(
                      title: Text(
                        (type == 'Recharge') ? 'ເບີໂທລະສັບ': 'ໄອດີ',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black45,
                            fontWeight: FontWeight.normal),
                      ),
                      subtitle: Text(
                          (type == 'Recharge') ? Global.displayPhone(widget.transaction.phone2) : widget.transaction.toAccountId,
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                  ),
                  Container(
                    height: 75,
                    margin: EdgeInsets.only(bottom: 1),
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                        borderRadius: BorderRadius.circular(0)),
                    child: ListTile(
                      title: Text(
                        'ຈຳນວນເງິນ',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black45,
                            fontWeight: FontWeight.normal),
                      ),
                      subtitle: Text(
                        formatter.format(widget.transaction.amount),
                        style: TextStyle(
                            color: UIHelper.SPOTIFY_COLOR,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (type != 'Recharge')
                    Container(
                    height: 75,
                    margin: EdgeInsets.only(bottom: 1),
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                        borderRadius: BorderRadius.circular(0)),
                    child: ListTile(
                      title: Text(
                        'ຈຸດປະສົງ',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black45,
                            fontWeight: FontWeight.normal),
                      ),
                      subtitle: Text(
                        widget.transaction.remark != null ? widget.transaction.remark : '',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                  )
                ]),
          ),
        )
    );
  }

  String getTitle(String type, String status) {
    if (type == 'Transfer') {
      if (status == 'expense')
        return 'ໂອນເງິນອອກ';
      if (status == 'income')
        return 'ໄດ້ຮັບເງິນໂອນ';
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