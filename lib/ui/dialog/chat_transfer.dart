import 'dart:convert';

import 'package:OCWA/Controllers/firebaseController.dart';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/models/message_model.dart';
import 'package:OCWA/models/record.dart';
import 'package:OCWA/models/record_list.dart';
import 'package:OCWA/models/record_service.dart';
import 'package:OCWA/models/response.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/chat/user.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:OCWA/utils/extension.dart';

enum Options { advanceSearch }

class ChatTransfer extends StatefulWidget {
  final MessageModel message;
  final UserModel user;

  ChatTransfer({this.message, this.user});

  @override
  _ChatTransferState createState() => _ChatTransferState();
}

class _ChatTransferState extends State<ChatTransfer> {
  bool fromMe;
  Widget _appBarTitle;

  @override
  void initState() {
    super.initState();
    fromMe = widget.message.sender == G.loggedInUser.id;
    _appBarTitle = new Text('ລາຍລະອຽດການໂອນເງິນ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      backgroundColor: appDarkGreyColor,
      body: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              //makes the red row full width
              child: Container(
                height: 50.0,
                child: Center(
                  child: Text(
                    getMessage(widget.message, widget.user),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // This expands the row element vertically because it's inside a column
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // This makes the blue container full width.
              Expanded(
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: new Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: widget.message.transferStatus ==
                                          "received" ||
                                      widget.message.transferStatus == "done"
                                  ? Colors.green
                                  : UIHelper.APRICOT_PRIMARY_COLOR,
                              borderRadius: BorderRadius.circular(100.0)),
                          height: 100.0,
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Image.asset(
                              widget.message.transferStatus == "received" ||
                                      widget.message.transferStatus == "done"
                                  ? 'assets/images/icons8-checkmark.png'
                                  : 'assets/images/icons8-data_transfer.png',
                              color: UIHelper.WHITE,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          getStatus(widget.message, widget.user),
                          style: TextStyle(
                            color: UIHelper.SPOTIFY_COLOR,
                            fontSize: 12.0,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          new NumberFormat("#,###").format(
                                  double.parse(widget.message.content)) +
                              ' LAK',
                          style: TextStyle(
                            color:
                                widget.message.transferStatus == "received" ||
                                        widget.message.transferStatus == "done"
                                    ? UIHelper.THEME_PRIMARY
                                    : UIHelper.APRICOT_PRIMARY_COLOR,
                            fontSize: 22.0,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        if ((widget.message.transferStatus == 'sent' || widget.message.transferStatus == 'message.transferStatus' ||
                                widget.message.transferStatus
                                    .isNullOrEmpty()) &&
                            !fromMe)
                          Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: FlatButton.icon(
                                onPressed: () {
                                  confirm(context, widget.message, widget.user);
                                },
                                color: UIHelper.SPOTIFY_COLOR,
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'ຮັບເງິນ',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        if ((widget.message.transferStatus == 'sent' ||
                                widget.message.transferStatus
                                    .isNullOrEmpty()) &&
                            fromMe)
                          Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: FlatButton.icon(
                                onPressed: () {
                                  cancel(context, widget.message, widget.user);
                                },
                                color: UIHelper.AVOCADOS_SECONDARY_COLOR,
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'ຍົກເລີກການໂອນ',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () => Navigator.pop(context, widget.message),
      ),
      elevation: 0.1,
      backgroundColor: UIHelper.SPOTIFY_COLOR,
      centerTitle: true,
      title: _appBarTitle,
    );
  }

  Future<bool> confirm(
      BuildContext context, MessageModel message, UserModel record) async {
    confirmationDialog(context, "ທ່ານຕ້ອງການຮັບເງິນບໍ?",
        title: 'ແຈ້ງເຕືອນ',
        confirm: false,
        neutralText: 'ຕ້ອງການ',
        positiveText: "ບໍ່ຕ້ອງການ",
        positiveAction: () {}, neutralAction: () {
      acceptTransfer(context, message, record);
    });
    return false;
  }

  acceptTransfer(
      BuildContext context, MessageModel message, UserModel record) async {
    final data = jsonEncode({
      "messageId": message.id,
      "chatId": message.chatId,
      "sourceId": widget.user.id,
      "remark": "",
      "amount": widget.message.content,
      "created": DateTime.now().toString(),
      "destinationId": await services.getValue('id'),
    });

    print(data);

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      ResponseModel result = await NetworkUtil.post('/chat-transfer', data);
      await pr.hide();
      if (result != null) {
        if (result.status == 'success') {
          var tmp = result.data.toString().split("|");
          var traId = tmp[0];
          var date = tmp[1];
          await FirebaseController.instance.updateChatRoomTransferStatus(message.chatId, message.id,'received', traId, date);
          Alert.success(
              context,
              'ສຳເລັດ',
              'ທ່ານໄດ້ຮັບ (' +
                  new NumberFormat("#,###")
                      .format(double.parse(message.content)) +
                  ' LAK) ຈາກ: ' +
                  record.name,
              'OK');
          setState(() {
            widget.message.transferStatus = 'done';
          });
        } else {
          Alert.error(context, result.status, result.message, "OK");
        }
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }

  Future<bool> cancel(
      BuildContext context, MessageModel message, UserModel user) async {
    confirmationDialog(context, "ທ່ານຕ້ອງການຍົກເລີກແທ້ບໍ?",
        title: 'ແຈ້ງເຕືອນ',
        confirm: false,
        neutralText: 'ຕ້ອງການ',
        positiveText: "ບໍ່ຕ້ອງການ",
        positiveAction: () {}, neutralAction: () {
          cancelTransfer(context, message, user);
        });
    return false;
  }

  cancelTransfer(
      BuildContext context, MessageModel message, UserModel record) async {
    final data = jsonEncode({
      "messageId": message.id,
      "chatId": message.chatId,
      "sourceId": widget.user.id,
      "remark": "",
      "amount": widget.message.content,
      "created": DateTime.now().toString(),
      "destinationId": await services.getValue('id'),
    });

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final date = DateTime.now().toString();
      await FirebaseController.instance.cancelChatRoomTransferStatus(message.chatId, message.id,'cancelled', date);
      await pr.hide();
      Alert.success(
          context,
          'ສຳເລັດ',
          'ທ່ານໄດ້ຍົກເລີກການໂອນເງິນແລ້ວ',
          'OK');
      setState(() {
        widget.message.transferStatus = 'cancelled';
      });
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດຂໍ້ຜິດພັດ', e.toString(), "OK");
    }
  }

  String getStatus(MessageModel chat, UserModel user) {
    bool fromMe = chat.sender == G.loggedInUser.id;
    if (chat.transferStatus == "sent" || chat.transferStatus.isNullOrEmpty()) {
      if (fromMe) {
        return user.name + " ຍັງບໍ່ຮັບເງິນ";
      } else {
        return "ລໍຖ້າຮັບເງິນ";
      }
    } else if (chat.transferStatus == "received" ||
        widget.message.transferStatus == "done") {
      if (fromMe) {
        return user.name + " ໄດ້ຮັບເງິນແລ້ວ";
      } else {
        return "ທ່ານໄດ້ຮັບເງິນແລ້ວ";
      }
    } else if (chat.transferStatus == "cancelled" ||
        widget.message.transferStatus == "cancel") {
      return "ການໂອນເງິນຖືກຍົກເລີກ";
    } else {
      if (fromMe) {
        return user.name + " ຍັງບໍ່ຮັບເງິນ";
      } else {
        return "ລໍຖ້າຮັບເງິນ";
      }
    }
  }

  String getMessage(MessageModel chat, UserModel user) {
    bool fromMe = chat.sender == G.loggedInUser.id;
    if (chat.transferStatus == "sent" || chat.transferStatus.isNullOrEmpty()) {
      if (fromMe) {
        return "ໂອນເງິນໃຫ້ " + user.name;
      } else {
        return "ເງິນໂອນຈາກ " + user.name;
      }
    } else if (chat.transferStatus == "received" ||
        widget.message.transferStatus == "done") {
      if (fromMe) {
        return user.name + " ໄດ້ຮັບເງິນແລ້ວ";
      } else {
        return "ໄດ້ຮັບເງິນແລ້ວ";
      }
    } else if (chat.transferStatus == "cancelled" ||
        widget.message.transferStatus == "cancel") {
      return "ການໂອນເງິນຖືກຍົກເລກແລ້ວ";
    } else {
      if (fromMe) {
        return "ໂອນເງິນໃຫ້ " + user.name;
      } else {
        return "ໂອນເງິນຈາກ " + user.name;
      }
    }
  }

  String getTitle(MessageModel chat, UserModel user) {
    bool fromMe = chat.sender == G.loggedInUser.id;
    if (chat.transferStatus == "sent" || chat.transferStatus.isNullOrEmpty()) {
      if (fromMe) {
        return "ໂອນເງິນໃຫ້ " + user.name;
      } else {
        return "ເງິນໂອນຈາກ " + user.name;
      }
    } else if (chat.transferStatus == "received" ||
        widget.message.transferStatus == "done") {
      if (fromMe) {
        return user.name + " ໄດ້ຮັບເງິນແລ້ວ";
      } else {
        return "ໄດ້ຮັບເງິນແລ້ວ";
      }
    } else if (chat.transferStatus == "cancelled" ||
        widget.message.transferStatus == "cancel") {
      return "ການໂອນເງິນຖືກຍົກເລກແລ້ວ";
    } else {
      if (fromMe) {
        return "ໂອນເງິນໃຫ້ " + user.name;
      } else {
        return "ໂອນເງິນຈາກ " + user.name;
      }
    }
  }

}
