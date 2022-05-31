import 'package:OCWA/Controllers/utils.dart';
import 'package:OCWA/pages/chat/widgets/online_dot_indicator.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/ui/colors.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'tools/GlobalChat.dart';
import 'message.dart';

class ChatListScreen extends StatefulWidget {
  String currentUserNo;

  ChatListScreen({this.currentUserNo});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Widget getIcon(isRead, isSend, isDeliver) {
    if (!isSend) {
      return Icon(
        Icons.access_time,
        size: 18.0,
        color: Colors.grey,
      );
    }

    if (isSend && !isDeliver) {
      return Icon(
        Icons.check,
        size: 18.0,
        color: Colors.grey,
      );
    }

    return Icon(
      Icons.done_all,
      size: 18.0,
      color: isRead ? blueCheckColor : Colors.grey,
    );
  }

  Future<void> _moveTochatRoom(selectedUserToken, selectedUserID,
      selectedUserName, selectedUserThumbnail, selectedPhone) async {
    try {
      String chatID = makeChatId(G.loggedInId, selectedUserID);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Messages(
                  G.loggedInId,
                  G.loggedInUser.name,
                  selectedUserToken,
                  int.parse(selectedUserID),
                  chatID,
                  selectedUserName,
                  selectedUserThumbnail,
                  selectedPhone)));
    } catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(USERS)
            .doc(widget.currentUserNo)
            .collection('chatlist')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
              color: Colors.white.withOpacity(0.7),
            );
          return (snapshot.hasData && snapshot.data.docs.length > 0)
              ? ListView(
                  children: snapshot.data.docs.map((check) {
                  if (check.data()['chatWith'] == G.loggedInId.toString()) {
                    return Container(
                      child: Text(''),
                    );
                  } else {
                    return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(USERS)
                            .where(ID, isEqualTo: check.data()['chatWith'])
                            .snapshots(),
                        builder: (context, userListSnapshot) {
                          if (!userListSnapshot.hasData) return Container();
                          if (userListSnapshot.hasData &&
                              userListSnapshot.data.docs.length > 0) {
                            var data = userListSnapshot.data.docs[0];
                            return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection(USERS)
                                    .doc(widget.currentUserNo)
                                    .collection('chatlist')
                                    .where('chatWith',
                                        isEqualTo: data.data()[ID])
                                    .snapshots(),
                                builder: (context, chatListSnapshot) {
                                  if (chatListSnapshot.hasData &&
                                      chatListSnapshot.data.docs.length > 0)
                                    return GestureDetector(
                                      onTap: () {
                                        _moveTochatRoom(
                                            data.data()['FCMToken'],
                                            data.data()[ID],
                                            data.data()[FULL_NAME],
                                            data.data()[PHOTO_URL],
                                            data.data()[PHONE]);
                                      },
                                      child: Container(
                                        child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('chatroom')
                                                .doc(chatListSnapshot
                                                    .data.docs[0]
                                                    .data()['chatID'])
                                                .collection(chatListSnapshot
                                                    .data.docs[0]
                                                    .data()['chatID'])
                                                .where('idTo',
                                                    isEqualTo:
                                                        G.loggedInId.toString())
                                                .where('isRead',
                                                    isEqualTo: false)
                                                .snapshots(),
                                            builder:
                                                (context, notReadMSGSnapshot) {
                                              return Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: (chatListSnapshot
                                                                .hasData &&
                                                            chatListSnapshot
                                                                    .data
                                                                    .docs
                                                                    .length >
                                                                0 &&
                                                            notReadMSGSnapshot
                                                                .hasData &&
                                                            notReadMSGSnapshot
                                                                    .data
                                                                    .docs
                                                                    .length >
                                                                0)
                                                        ? Color(0xFFFFEFEE)
                                                        : Colors.transparent,
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: Colors
                                                                .grey[200]))),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Stack(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            children: [
                                                              ClipOval(
                                                                child: data.data()['photoUrl'] !=
                                                                            null &&
                                                                        data.data()['photoUrl'] !=
                                                                            ""
                                                                    ? CachedNetworkImage(
                                                                        imageUrl:
                                                                            data.data()['photoUrl'],
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                Container(
                                                                          transform: Matrix4.translationValues(
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          child: Container(
                                                                              width: 60,
                                                                              height: 60,
                                                                              child: Center(child: new CircularProgressIndicator())),
                                                                        ),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            new Icon(Icons.error),
                                                                        width:
                                                                            60,
                                                                        height:
                                                                            60,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : Image
                                                                        .asset(
                                                                        'assets/images/default_profile.png',
                                                                        width:
                                                                            60,
                                                                        height:
                                                                            60,
                                                                      ),
                                                              ),
                                                              OnlineDotIndicator(
                                                                phone:
                                                                    data.data()[
                                                                        PHONE],
                                                              )
                                                            ]),
                                                        SizedBox(width: 10.0),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              data.data()[
                                                                  'fullName'],
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 5.0),
                                                            if (chatListSnapshot
                                                                    .hasData &&
                                                                chatListSnapshot
                                                                        .data
                                                                        .docs
                                                                        .length >
                                                                    0)
                                                              StreamBuilder<
                                                                      QuerySnapshot>(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'chatroom')
                                                                      .doc(chatListSnapshot.data.docs[0]
                                                                              .data()[
                                                                          'chatID'])
                                                                      .collection(chatListSnapshot.data.docs[0]
                                                                              .data()[
                                                                          'chatID'])
                                                                      .orderBy(
                                                                          'timestamp',
                                                                          descending:
                                                                              true)
                                                                      .limit(20)
                                                                      .snapshots(),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                        .hasData) {
                                                                      for (var data in snapshot
                                                                          .data
                                                                          .docs) {
                                                                        if (data.data()['idTo'] == G.loggedInId.toString() &&
                                                                            data.data()['isDeliver'] ==
                                                                                false) {
                                                                          if (data.reference !=
                                                                              null) {
                                                                            FirebaseFirestore.instance.runTransaction((Transaction
                                                                                myTransaction) async {
                                                                              await myTransaction.update(data.reference, {
                                                                                'isDeliver': true
                                                                              });
                                                                            });
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                    return Container();
                                                                  }),
                                                            if (data.data()[
                                                                        'type'] ==
                                                                    null ||
                                                                data.data()[
                                                                        'type'] ==
                                                                    'text')
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                                child: Text(
                                                                  (chatListSnapshot
                                                                              .hasData &&
                                                                          chatListSnapshot.data.docs.length >
                                                                              0)
                                                                      ? chatListSnapshot
                                                                          .data
                                                                          .docs[
                                                                              0]
                                                                          .data()['lastChat']
                                                                      : data.data()['aboutMe'],
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    fontSize:
                                                                        15.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: <Widget>[
                                                        Text(
                                                          chatListSnapshot
                                                                      .hasData &&
                                                                  (chatListSnapshot
                                                                          .data
                                                                          .docs
                                                                          .length >
                                                                      0)
                                                              ? readTimestamp(
                                                                  chatListSnapshot
                                                                          .data
                                                                          .docs[0]
                                                                          .data()[
                                                                      'timestamp'])
                                                              : '',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 5.0),
                                                        if (chatListSnapshot.hasData &&
                                                            chatListSnapshot
                                                                    .data
                                                                    .docs
                                                                    .length >
                                                                0)
                                                          StreamBuilder<
                                                                  QuerySnapshot>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'chatroom')
                                                                  .doc(chatListSnapshot
                                                                          .data
                                                                          .docs[0]
                                                                          .data()[
                                                                      'chatID'])
                                                                  .collection(chatListSnapshot
                                                                          .data
                                                                          .docs[0]
                                                                          .data()[
                                                                      'chatID'])
                                                                  .where('idTo',
                                                                      isEqualTo:
                                                                          G.loggedInId.toString())
                                                                  .where('isRead', isEqualTo: false)
                                                                  .snapshots(),
                                                              builder: (context, notReadMSGSnapshot) {
                                                                return Container(
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: (notReadMSGSnapshot.hasData &&
                                                                            notReadMSGSnapshot.data.docs.length >
                                                                                0 &&
                                                                            notReadMSGSnapshot
                                                                                .hasData &&
                                                                            notReadMSGSnapshot.data.docs.length >
                                                                                0)
                                                                        ? Colors.red[
                                                                            400]
                                                                        : Colors
                                                                            .transparent,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    (chatListSnapshot.hasData &&
                                                                            chatListSnapshot.data.docs.length >
                                                                                0)
                                                                        ? ((notReadMSGSnapshot.hasData &&
                                                                                notReadMSGSnapshot.data.docs.length > 0)
                                                                            ? '${notReadMSGSnapshot.data.docs.length}'
                                                                            : '')
                                                                        : '',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          12.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                        if (chatListSnapshot.hasData &&
                                                            chatListSnapshot
                                                                    .data
                                                                    .docs
                                                                    .length >
                                                                0)
                                                          StreamBuilder<
                                                                  QuerySnapshot>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'chatroom')
                                                                  .doc(chatListSnapshot
                                                                          .data
                                                                          .docs[0]
                                                                          .data()[
                                                                      'chatID'])
                                                                  .collection(chatListSnapshot
                                                                          .data
                                                                          .docs[0]
                                                                          .data()[
                                                                      'chatID'])
                                                                  .orderBy('timestamp',
                                                                      descending:
                                                                          true)
                                                                  .limit(1)
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  statusMSGSnapshot) {
                                                                if (chatListSnapshot.hasData &&
                                                                    chatListSnapshot
                                                                            .data
                                                                            .docs
                                                                            .length >
                                                                        0 &&
                                                                    statusMSGSnapshot
                                                                        .hasData &&
                                                                    statusMSGSnapshot
                                                                            .data
                                                                            .docs
                                                                            .length >
                                                                        0) {
                                                                  if (statusMSGSnapshot
                                                                          .data
                                                                          .docs[
                                                                              0]
                                                                          .data()['idFrom'] ==
                                                                      G.loggedInId.toString()) {
                                                                    return getIcon(
                                                                        statusMSGSnapshot.data.docs[0].data()[
                                                                            'isRead'],
                                                                        statusMSGSnapshot.data.docs[0].data()[
                                                                            'isSend'],
                                                                        statusMSGSnapshot
                                                                            .data
                                                                            .docs[0]
                                                                            .data()['isDeliver']);
                                                                  }
                                                                }
                                                                return Container();
                                                              })
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                    );
                                  return Container();
                                });
                          }
                          return Container();
                        });
                  }
                }).toList())
              : Center(
                  child: Container(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        SizedBox.fromSize(
                          size: Size(80, 80),
                          // button width and height
                          child: ClipOval(
                            child: Material(
                              color: UIHelper.SPOTIFY_COLOR,
                              // button color
                              child: InkWell(
                                splashColor: Colors.green,
                                // splash color
                                onTap: () {},
                                // button pressed
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.chat,
                                      color: UIHelper.WHITE,
                                    ),
                                    // icon
                                    Text(
                                      "ເລີ່ມ",
                                      style: TextStyle(color: UIHelper.WHITE),
                                    ),
                                    // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          'ທ່ານຍັງບໍ່ມີການສົນທະນາ',
                          style: TextStyle(color: UIHelper.SPOTIFY_COLOR),
                        )
                      ])),
                );
//                Container(
//                  child: Center(
//                      child: Column(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Icon(Icons.forum, color: Colors.grey[700],size: 64,),
//                          Padding(
//                            padding: const EdgeInsets.all(10.0),
//                            child: Text(
//                              'There are no users except you.\nPlease use other devices to chat.',
//                              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
//                              textAlign: TextAlign.center,
//                            ),
//                          ),
//                        ],
//                      )),
//                );
        });
  }
}
