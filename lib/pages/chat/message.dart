import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:OCWA/Controllers/firebaseController.dart';
import 'package:OCWA/Controllers/notificationController.dart';
import 'package:OCWA/Controllers/utils.dart';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/enum/user_state.dart';
import 'package:OCWA/enum/view_state.dart';
import 'package:OCWA/models/message_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/GiphyPicker/giphy_picker.dart';
import 'package:OCWA/pages/ImagePicker/camera_picker.dart';
import 'package:OCWA/pages/ImagePicker/file_picker.dart';
import 'package:OCWA/pages/ImagePicker/image_picker.dart';
import 'package:OCWA/pages/ImagePicker/video_picker.dart';
import 'package:OCWA/pages/callscreens/pickup/pickup_layout.dart';
import 'package:OCWA/pages/chat/bubble/file.dart';
import 'package:OCWA/pages/chat/tools/photoBubble.dart';
import 'package:OCWA/pages/chat/fullphoto.dart';
import 'package:OCWA/pages/chat/records/active_codec.dart';
import 'package:OCWA/pages/chat/records/recorder_state.dart';
import 'package:OCWA/pages/chat/records/temp_file.dart';
import 'package:OCWA/pages/chat/video_box.dart';
import 'package:OCWA/pages/chat/widgets/user_status.dart';
import 'package:OCWA/pages/configs/Palette.dart';
import 'package:OCWA/pages/configs/configs.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:OCWA/provider/image_upload_provider.dart';
import 'package:OCWA/ui/colors.dart';
import 'package:OCWA/ui/dialog/chat_transfer.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/ui/widgets/BottomSheetFixed.dart';
import 'package:OCWA/ui/widgets/GradientSnackBar.dart';
import 'package:OCWA/ui/widgets/VideoPlayerWidget.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/call_utilities.dart';
import 'package:OCWA/utils/connectivity.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/mask.dart';
import 'package:OCWA/utils/permissions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/commons.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:im_animations/im_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:OCWA/utils/extension.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'tools/ChatBubble.dart';
import 'tools/GlobalChat.dart';
import 'tools/TransferBubble.dart';
import 'audioplayers/AudioPlayer.dart';

const int SAMPLE_RATE = 44100;
const int BLOCK_SIZE = 4096;

enum Media {
  file,
  buffer,
  asset,
  stream,
  remoteExampleFile,
}
enum AudioState {
  isPlaying,
  isPaused,
  isStopped,
  isRecording,
  isRecordingPaused,
}

enum ChatDetailMenuOptions {
  viewContact,
  media,
  search,
  muteNotifications,
  wallpaper,
  more,
}

enum ChatDetailMoreMenuOptions {
  report,
  block,
  clearChat,
  exportChat,
  addShortcut,
}

Services services = new StorageServiceSharedPreferences();

class Messages extends StatefulWidget {
  int myID;
  String myName;
  String selectedUserToken;
  int selectedUserID;
  String selectedPhone;
  String chatID;
  String selectedUserName;
  String selectedUserThumbnail;

  Messages(
      this.myID,
      this.myName,
      this.selectedUserToken,
      this.selectedUserID,
      this.chatID,
      this.selectedUserName,
      this.selectedUserThumbnail,
      this.selectedPhone);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final TextEditingController _msgTextController = new TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  final ScrollController _chatListController = ScrollController();
  String messageType = 'text';
  BuildContext _context;
  int chatListLength = 20;
  double _scrollPosition = 560;

  bool isAttach = false;
  bool isEmoji = false;
  bool isGif = true;
  bool record = false;
  bool hasInternet = true;
  bool showSendButton = false;
  MoneyMaskedTextController _amount = new MoneyMaskedTextController(
      precision: 0, decimalSeparator: '', thousandSeparator: ',');
  FocusNode _amountFocus = new FocusNode();
  String pinCode;
  bool pageLoaded;
  bool iSend;
  AppLifecycleState _lastLifecycleState;
  bool checkApp;

  // Sending image properties
  ImageUploadProvider _imageUploadProvider;
  ImagePicker picker;
  PickedFile pickedFile;
  File file;
  File video;
  File thumbnail;
  File cameraVideo;

  // Record voice
  bool initialized = false;
  String recordingFile;
  Track track;
  AnimationController _controller;
  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;
  StreamSubscription _recordingDataSubscription;

  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
  Media _media = Media.file;
  Codec _codec = Codec.aacADTS;
  StreamController<Food> recordingDataController;
  IOSink sink;

// Optimist
// Optimist

  List<String> _path = [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    setCurrentChatRoomID(widget.chatID);
    FirebaseController.instance.getUnreadMSGCount(G.loggedInId.toString());
    _chatListController.addListener(_scrollListener);
    NetworkCheck.checkInternet(fetchPrefrence);
    _controller = new AnimationController(
      vsync: this,
    );
    super.initState();
    tempFile(suffix: '.aac').then((path) {
      recordingFile = path;
      track = Track(trackPath: recordingFile);
      setState(() {});
    });

    initAuido();
  }

  Future<void> _initializeAudio(bool withUI) async {
    await playerModule.closeAudioSession();
    await playerModule.openAudioSession(
        withUI: withUI,
        focus: AudioFocus.requestFocusAndKeepOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
    await recorderModule.setSubscriptionDuration(Duration(milliseconds: 10));
    initializeDateFormatting('lo', null);
    await setCodec(_codec);
  }

  Future<void> initAuido() async {
    await recorderModule.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _initializeAudio(true);
  }

  void setCodec(Codec codec) async {
    setState(() {
      _codec = codec;
    });
  }

  _scrollListener() {
    setState(() {
      if (_scrollPosition < _chatListController.position.pixels) {
        _scrollPosition = _scrollPosition + 560;
        chatListLength = chatListLength + 20;
      }
      print('list view position is $_scrollPosition');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    setCurrentChatRoomID('none');
    if (recordingFile != null) {
      try {
        File(recordingFile).delete();
      } catch (e) {
        // ignore
      }
    }
    if (_controller != null) _controller.dispose();

    super.dispose();
    cancelPlayerSubscriptions();
    cancelRecorderSubscriptions();
    cancelRecordingDataSubscription();
    releaseFlauto();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();

    String currentUserId = Global.firePhone(G.loggedInUser.phone);

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? FirebaseController.instance.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? FirebaseController.instance.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? FirebaseController.instance.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? FirebaseController.instance.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void setIsActive() async {
    if (Global.firePhone(G.loggedInUser.phone) != null)
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(Global.firePhone(G.loggedInUser.phone))
          .set({LAST_SEEN: true}, SetOptions(merge: true));
  }

  void setLastSeen() async {
    if (Global.firePhone(G.loggedInUser.phone) != null)
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(Global.firePhone(G.loggedInUser.phone))
          .set({LAST_SEEN: DateTime.now().millisecondsSinceEpoch},
              SetOptions(merge: true));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  fetchPrefrence(bool isNetworkPresent) async {
    if (isNetworkPresent) {
      if (mounted) {
        setState(() {
          hasInternet = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          hasInternet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    this._context = context;
    return PickupLayout(
      scaffold: Scaffold(
          backgroundColor: chatDetailScaffoldBgColor,
          appBar: AppBar(
            leading: FlatButton(
              shape: CircleBorder(),
              padding: const EdgeInsets.only(left: 2.0),
              onPressed: () {
                goBack(context);
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.arrow_back,
                    size: 24.0,
                    color: Colors.white,
                  ),
                  Hero(
                      tag: "avatar_" + widget.selectedUserID.toString(),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: widget.selectedUserThumbnail != null &&
                                widget.selectedUserThumbnail != ""
                            ? CachedNetworkImageProvider(
                                widget.selectedUserThumbnail)
                            : AssetImage(
                                'assets/images/default_profile.png',
                              ),
                      )),
                ],
              ),
            ),
            title: Material(
              color: Colors.white.withOpacity(0.0),
              child: InkWell(
                highlightColor: highlightColor,
                splashColor: secondaryColor,
                onTap: () {},
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        widget.selectedUserName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    UserStatus(phone: widget.selectedPhone)
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.videocam),
                    onPressed: () async => await Permissions
                            .cameraAndMicrophonePermissionsGranted()
                        ? CallUtils.dial(
                            from: UserModel(
                                phone: Global.firePhone(G.loggedInUser.phone),
                                name: G.loggedInUser.name,
                                avatar: G.loggedInUser.avatar),
                            to: UserModel(
                                phone: widget.selectedPhone,
                                name: widget.selectedUserName,
                                avatar: widget.selectedUserThumbnail),
                            context: context,
                            type: 'video',
                            token: widget.selectedUserToken)
                        : {},
                  );
                },
              ),
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () async => await Permissions
                            .cameraAndMicrophonePermissionsGranted()
                        ? CallUtils.dial(
                            from: UserModel(
                                phone: Global.firePhone(G.loggedInUser.phone),
                                name: G.loggedInUser.name,
                                avatar: G.loggedInUser.avatar),
                            to: UserModel(
                                phone: widget.selectedPhone,
                                name: widget.selectedUserName,
                                avatar: widget.selectedUserThumbnail),
                            context: context,
                            type: 'voice',
                            token: widget.selectedUserToken)
                        : {},
                  );
                },
              ),
              PopupMenuButton<ChatDetailMenuOptions>(
                tooltip: "More options",
                onSelected: _onSelectMenuOption,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<ChatDetailMenuOptions>(
                      child: Text("View contact"),
                      value: ChatDetailMenuOptions.viewContact,
                    ),
                    PopupMenuItem<ChatDetailMenuOptions>(
                      child: Text("Media"),
                      value: ChatDetailMenuOptions.media,
                    ),
                    PopupMenuItem<ChatDetailMenuOptions>(
                      child: Text("Search"),
                      value: ChatDetailMenuOptions.search,
                    ),
                    PopupMenuItem<ChatDetailMenuOptions>(
                      child: Text("Mute notifications"),
                      value: ChatDetailMenuOptions.muteNotifications,
                    ),
                    PopupMenuItem<ChatDetailMenuOptions>(
                      child: Text("Wallpaper"),
                      value: ChatDetailMenuOptions.wallpaper,
                    ),
                    PopupMenuItem<ChatDetailMenuOptions>(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: Text("More"),
                        trailing: Icon(Icons.arrow_right),
                      ),
                      value: ChatDetailMenuOptions.more,
                    ),
                  ];
                },
              ),
            ],
          ),
          body: VisibilityDetector(
            key: Key("1"),
            onVisibilityChanged: ((visibility) {
              print('ChatRoom Visibility code is ' +
                  '${visibility.visibleFraction}');
              if (visibility.visibleFraction == 1.0) {
                FirebaseController.instance
                    .getUnreadMSGCount(G.loggedInId.toString());
              }
            }),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  isAttach = false;
                  isEmoji = false;
                });
              },
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chatroom')
                      .doc(widget.chatID)
                      .collection(widget.chatID)
                      .orderBy('timestamp', descending: true)
                      .limit(chatListLength)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    if (snapshot.hasData) {
                      for (var data in snapshot.data.docs) {
//                    print(data.data());
                        if (data.data()['idTo'] == G.loggedInId.toString() &&
                            data.data()['isRead'] == false) {
                          if (!data.reference.isNullOrEmpty()) {
                            FirebaseFirestore.instance.runTransaction(
                                (Transaction myTransaction) async {
                              await myTransaction
                                  .update(data.reference, {'isRead': true});
                            });
                            FirebaseController.instance
                                .getUnreadMSGCount(G.loggedInId.toString());
                          }
                        }

                        if (data.data()['idFrom'] == G.loggedInId.toString() &&
                            data.data()['isSend'] == false) {
                          if (!data.reference.isNullOrEmpty()) {
                            FirebaseFirestore.instance.runTransaction(
                                (Transaction myTransaction) async {
                              await myTransaction
                                  .update(data.reference, {'isSend': true});
                            });
                          }
                        }

                        if (data.data()['idTo'] == G.loggedInId.toString() &&
                            data.data()['isDeliver'] == false) {
                          if (!data.reference.isNullOrEmpty()) {
                            FirebaseFirestore.instance.runTransaction(
                                (Transaction myTransaction) async {
                              await myTransaction
                                  .update(data.reference, {'isDeliver': true});
                            });
                          }
                        }
                      }
                    }
                    return Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView(
                                  reverse: true,
                                  shrinkWrap: true,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(4.0, 10, 4, 10),
                                  controller: _chatListController,
                                  children: snapshot.data.docs.map((data) {
                                    return int.parse(data.data()['idFrom']) ==
                                            widget.selectedUserID
                                        ? _listItemOther(
                                            context,
                                            widget.selectedUserName,
                                            widget.selectedUserThumbnail,
                                            data.data()['type'] == 'video'
                                                ? data.data()['thumbnail']
                                                : data.data()['content'],
                                            returnTimeStamp(
                                                data.data()['timestamp']),
                                            data.data()['type'],
                                            data.data()['transferStatus'],
                                            data.data())
                                        : _listItemMine(
                                            context,
                                            data.data()['type'] == 'video'
                                                ? data.data()['thumbnail']
                                                : data.data()['content'],
                                            returnTimeStamp(
                                                data.data()['timestamp']),
                                            data.data()['isRead'],
                                            data.data()['isSend'],
                                            data.data()['isDeliver'],
                                            data.data()['type'],
                                            data.data()['transferStatus'],
                                            data.data());
                                  }).toList()),
                            ),
                            _imageUploadProvider.getViewState ==
                                    ViewState.LOADING
                                ? Container(
                                    alignment: Alignment.centerRight,
                                    margin:
                                        EdgeInsets.only(right: 15, bottom: 15),
                                    child: CircularProgressIndicator(),
                                  )
                                : Container(),
                            _buildMessageComposer(context),
                            SizedBox(
                              height: 5.0,
                            ),
                            if (isAttach)
                              Ink(
                                color: Colors.white,
                                child: new Wrap(
                                  children: <Widget>[
                                    ClipRRect(
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: UIHelper.THEME_PRIMARY,
                                                width: 0,
                                                style: BorderStyle.solid)),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Column(
                                          children: [
                                            new ListTile(
                                              leading: SizedBox(
                                                height: 30.0,
                                                child: Image.asset(
                                                  'assets/images/icons8-data_transfer.png',
                                                  color: UIHelper.THEME_PRIMARY,
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _amount.updateValue(0.0);
                                                  _amountFocus.requestFocus();
                                                });
                                                openAmountPopup(context);
                                              },
                                              title: new Text('ໂອນເງິນ'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ClipRRect(
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: UIHelper.THEME_PRIMARY,
                                                width: 0,
                                                style: BorderStyle.solid)),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Column(
                                          children: [
                                            new ListTile(
                                                leading: SizedBox(
                                                  height: 30.0,
                                                  child: Image.asset(
                                                    'assets/images/icons8-image.png',
                                                    color:
                                                        UIHelper.THEME_PRIMARY,
                                                  ),
                                                ),
                                                title: new Text('ຮູບພາບ'),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              HybridImagePicker(
                                                                title:
                                                                    'ເລືອກຮູບ',
                                                                callback:
                                                                    getFile,
                                                              ))).then((url) {
                                                    if (url != null) {
                                                      setState(() {
                                                        messageType = 'image';
                                                      });
                                                      _handleSubmitted(
                                                          context, url);
                                                    }
                                                  });
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ClipRRect(
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: UIHelper.THEME_PRIMARY,
                                                width: 0,
                                                style: BorderStyle.solid)),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Column(
                                          children: [
                                            new ListTile(
                                              leading: SizedBox(
                                                height: 30.0,
                                                child: Image.asset(
                                                  'assets/images/icons8-video.png',
                                                  color: UIHelper.THEME_PRIMARY,
                                                ),
                                              ),
                                              title: new Text('ວີດີໂອ'),
                                              onTap: () {
                                                setState(() {
                                                  messageType = 'video';
                                                });
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HybridVideoPicker(
                                                              title:
                                                                  'ເລືອກວິດີໂອນ',
                                                              callback: getFile,
                                                            ))).then((url) {
                                                  if (url != null) {
                                                    setState(() {
                                                      messageType = 'video';
                                                    });
                                                    _handleSubmitted(
                                                        context, url);
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ClipRRect(
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: UIHelper.THEME_PRIMARY,
                                                width: 0,
                                                style: BorderStyle.solid)),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Column(
                                          children: [
                                            new ListTile(
                                                leading: SizedBox(
                                                  height: 30.0,
                                                  child: Image.asset(
                                                    'assets/images/icons8-file.png',
                                                    color:
                                                        UIHelper.THEME_PRIMARY,
                                                  ),
                                                ),
                                                title: new Text('ເອກະສານ'),
                                                onTap: () {
                                                  setState(() {
                                                    messageType = 'file';
                                                  });
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              HybridFilePicker(
                                                                title:
                                                                    'ເລືອກເອກະສານ',
                                                                callback:
                                                                    getFile,
                                                              ))).then((url) {
                                                    if (url != null) {
                                                      setState(() {
                                                        messageType = 'file';
                                                      });
                                                      _handleSubmitted(
                                                          context, url);
                                                    }
                                                  });
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ClipRRect(
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: UIHelper.THEME_PRIMARY,
                                                width: 0,
                                                style: BorderStyle.solid)),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Column(
                                          children: [
                                            new ListTile(
                                                leading: SizedBox(
                                                  height: 30.0,
                                                  child: Image.asset(
                                                    'assets/images/icons8-gif.png',
                                                    color:
                                                        UIHelper.THEME_PRIMARY,
                                                  ),
                                                ),
                                                title: new Text('ພາບເຄື່ອນໄຫວ'),
                                                onTap: () async {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  final gif =
                                                      await GiphyPicker.pickGif(
                                                          context: context,
                                                          apiKey:
                                                              Giphy_API_KEY);
                                                  setState(() {
                                                    messageType = 'image';
                                                  });
                                                  _handleSubmitted(context,
                                                      gif.images.original.url);
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),

//                                    ClipRRect(
//                                      child: Ink(
//                                        decoration: BoxDecoration(
//                                            border: Border.all(
//                                                color: UIHelper.THEME_PRIMARY,
//                                                width: 0,
//                                                style: BorderStyle.solid)),
//                                        width:
//                                            MediaQuery.of(context).size.width /
//                                                2,
//                                        child: Column(
//                                          children: [
//                                            new ListTile(
//                                              leading: SizedBox(
//                                                height: 30.0,
//                                                child: Image.asset(
//                                                  'assets/images/icons8-contacts.png',
//                                                  color: UIHelper.THEME_PRIMARY,
//                                                ),
//                                              ),
//                                              title: new Text('ເພື່ອນ'),
//                                              onTap: () => {},
//                                            ),
//                                          ],
//                                        ),
//                                      ),
//                                    ),
                                  ],
                                ),
                              ),
                            if (isEmoji)
                              EmojiPicker(
                                rows: 3,
                                columns: 7,
                                recommendKeywords: [
                                  "face",
                                  "like",
                                  "racing",
                                  "horse",
                                  "good"
                                ],
                                numRecommended: 50,
                                onEmojiSelected: (emoji, category) {
                                  _msgTextController.text += emoji.emoji;
                                  setState(() {
                                    showSendButton = true;
                                  });
                                },
                              ),
                          ],
                        ),
//                Positioned(
//                  // Loading view in the center.
//                  child: _isLoading
//                      ? Container(
//                    child: Center(
//                      child: CircularProgressIndicator(),
//                    ),
//                    color: Colors.white.withOpacity(0.7),
//                  )
//                      : Container(),
//                ),
                      ],
                    );
                  }),
            ),
          )),
    );
  }

  Widget _listItemOther(BuildContext context, String name, String thumbnail,
      String message, String time, String type, String transferStatus, data) {
    final size = MediaQuery.of(context).size;
    Color chatBgColor = Colors.grey[200];
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child: CachedNetworkImage(
                        imageUrl: thumbnail,
                        placeholder: (context, url) => Container(
                          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                          child: Container(
                              width: 60,
                              height: 60,
                              child: Center(
                                  child: new CircularProgressIndicator())),
                        ),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: (type == 'voice')
                              ? const EdgeInsets.all(0)
                              : const EdgeInsets.fromLTRB(0, 4, 0, 8),
                          child: Column(children: [
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: size.width - 140),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          color: type == 'text'
                                              ? chatBgColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: _chat(
                                            context,
                                            type,
                                            message,
                                            false,
                                            transferStatus,
                                            time,
                                            false,
                                            false,
                                            false,
                                            data)),
                                  ]),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listItemMine(
      BuildContext context,
      String message,
      String time,
      bool isRead,
      bool isSend,
      bool isDeliver,
      String type,
      String transferStatus,
      data) {
    final size = MediaQuery.of(context).size;
    Color chatBgColor = messageBubbleColor;
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: (type == 'voice')
                    ? const EdgeInsets.all(0)
                    : const EdgeInsets.fromLTRB(0, 4, 4, 4),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: size.width - size.width * 0.34),
                        child: Container(
                            decoration: BoxDecoration(
                              color: type == 'text'
                                  ? chatBgColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: _chat(
                                context,
                                type,
                                message,
                                true,
                                transferStatus,
                                time,
                                isRead,
                                isSend,
                                isDeliver,
                                data)),
                      ),
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getFile(File _file) {
    if (_file != null) {
      setState(() {
        file = _file;
      });
    }
    return uploadFile();
  }

  getImageFileName(id, timestamp) {
    return "$id-$timestamp";
  }

  Future uploadFile() async {
    final uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName =
        getImageFileName(G.loggedInId.toString(), '$uploadTimestamp');
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    TaskSnapshot uploading;
    if (messageType == 'video') {
      thumbnail = await getThumbnail(file);
      uploading = await reference.putFile(
          file, SettableMetadata(contentType: 'video/mp4'));
    } else {
      uploading = await reference.putFile(file);
    }
    return uploading.ref.getDownloadURL();
  }

  showFilePicker(FileType fileType) async {
    FilePickerResult file = await FilePicker.platform.pickFiles(type: fileType);
    GradientSnackBar.showMessage(context, 'Sending attachment..');
  }

  void showVideoPlayer(parentContext, String videoUrl) async {
    await showModalBottomSheetApp(
        context: parentContext,
        builder: (BuildContext bc) {
          return VideoPlayerWidget(videoUrl);
        });
  }

  Future uploadFileThumbnail() async {
    final uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName =
        getImageFileName(G.loggedInId.toString(), '$uploadTimestamp');
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    TaskSnapshot uploading;
    uploading = await reference.putFile(thumbnail);
    return uploading.ref.getDownloadURL();
  }

  Future<void> _handleSubmitted(BuildContext context, String text) async {
    try {
      String thumb = '';
      if (messageType == 'video') {
        thumb = await uploadFileThumbnail();
        setState(() {});
        _resetTextFieldAndLoading(context);
        if (text.isNullOrEmpty()) return;
        var msgId = await FirebaseController.instance.sendMessageToChatRoom(
            widget.chatID,
            G.loggedInId.toString(),
            widget.selectedUserID.toString(),
            text,
            messageType,
            thumb);
        await FirebaseController.instance.updateChatRequestField(
            widget.selectedPhone,
            getType(messageType, text),
            widget.chatID,
            G.loggedInId.toString(),
            widget.selectedUserID.toString(),
            messageType,
            false);
        await FirebaseController.instance.updateChatRequestField(
            await services.getValue(PHONE),
            getType(messageType, text),
            widget.chatID,
            G.loggedInId.toString(),
            widget.selectedUserID.toString(),
            messageType,
            true);
        _getUnreadMSGCountThenSendMessage(context, msgId, text);
        setState(() {});
      } else {
        setState(() {});
        _resetTextFieldAndLoading(context);
        if (text.isNullOrEmpty()) return;
        var msgId = await FirebaseController.instance.sendMessageToChatRoom(
            widget.chatID,
            G.loggedInId.toString(),
            widget.selectedUserID.toString(),
            text,
            messageType,
            thumb);
        await FirebaseController.instance.updateChatRequestField(
            widget.selectedPhone,
            getType(messageType, text),
            widget.chatID,
            G.loggedInId.toString(),
            widget.selectedUserID.toString(),
            messageType,
            false);
        await FirebaseController.instance.updateChatRequestField(
            await services.getValue(PHONE),
            getType(messageType, text),
            widget.chatID,
            G.loggedInId.toString(),
            widget.selectedUserID.toString(),
            messageType,
            true);
        _getUnreadMSGCountThenSendMessage(context, msgId, text);
        setState(() {});
      }
    } catch (e) {
      _showDialog(
          context, 'Error user information to database: ' + e.toString());
      _resetTextFieldAndLoading(context);
    }
  }

  String getType(type, text) {
    switch (type) {
      case 'image':
        type = '(ຮູບພາບ)';
        break;
      case 'video':
        type = '(ວິດີໂອ)';
        break;
      case 'transfer':
        type = '(ເງິນໂອນ)';
        break;
      case 'voice':
        type = '(ຂໍ້ຄວາມສຽງ)';
        break;
      case 'text':
        type = text;
        break;
      default:
        type = '';
        break;
    }
    return type;
  }

  Future<void> _getUnreadMSGCountThenSendMessage(
      BuildContext context, int msgId, String text) async {
    try {
      int unReadMSGCount = await FirebaseController.instance
          .getUnreadMSGCount(widget.selectedUserID.toString());
      await NotificationController.instance.sendNotificationMessageToPeerUser(
          unReadMSGCount,
          messageType,
          text,
          widget.myName,
          widget.chatID,
          widget.selectedUserToken,
          msgId);
    } catch (e) {
      print(e.message);
    }
  }

  _resetTextFieldAndLoading(BuildContext context) {
    _msgTextController.text = '';
    showSendButton = false;
    setState(() {});
  }

  _showDialog(BuildContext context, String msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(msg),
          );
        });
  }

  Future<bool> initRecord() async {
    if (!initialized) {
      initializeDateFormatting('lo', null);
      await UtilRecorder().init();
      ActiveCodec().recorderModule = UtilRecorder().recorderModule;
      ActiveCodec().setCodec(withUI: false, codec: Codec.mp3);

      initialized = true;
    }
    return initialized;
  }

  void _startAnimation() {
    _controller.stop();
    _controller.reset();
    _controller.repeat(
      period: Duration(seconds: 1),
    );
  }

  void _stopAnimation() {
    _controller.stop();
    _controller.reset();
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      isEmoji = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      isEmoji = true;
      isAttach = false;
    });
  }

  _buildMessageComposer(BuildContext context) {
    final List<double> values = [];
    MediaQueryData queryData = MediaQuery.of(context);
    var rng = new Random();
    for (var i = 0; i < 100; i++) {
      values.add(rng.nextInt(70) * 1.0);
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: UIHelper.SPOTIFY_COLOR,
                borderRadius: BorderRadius.circular(30)),
            child: IconButton(
              icon: Icon(Icons.add),
              iconSize: 35.0,
              color: Colors.white,
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  if (!isAttach) {
                    isAttach = true;
                  } else {
                    isAttach = false;
                  }
                  isEmoji = false;
                });
              },
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          Expanded(
            child: Stack(alignment: Alignment.center, children: [
              Stack(alignment: Alignment.centerRight, children: [
                TextField(
                  onTap: () {
                    setState(() {
                      isAttach = false;
                      isEmoji = false;
                    });
                  },
                  minLines: 1,
                  maxLines: 3,
                  focusNode: textFieldFocus,
                  controller: _msgTextController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    if (value.trim() != "") {
                      setState(() {
                        showSendButton = true;
                        isGif = false;
                      });
                    } else {
                      setState(() {
                        showSendButton = false;
                        isGif = true;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'ພິມຂໍ້ຄວາມ...',
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UIHelper.WHITE,
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!isEmoji) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(Icons.sentiment_satisfied),
                ),
              ]),
              if (record)
                Container(
                  height: 48.0,
                  width: 48.0,
                  child: ColorSonar(
                    // wavesDisabled: true,
                    // waveMotion: WaveMotion.synced,
                    contentAreaRadius: 48.0,
                    waveFall: 15.0,
                    // waveMotionEffect: Curves.elasticIn,
                    waveMotion: WaveMotion.synced,
                    child: HeartbeatProgressIndicator(
                      duration: const Duration(milliseconds: 500),
                      child: Icon(
                        Icons.mic,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
            ]),
          ),
          if (isGif)
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HybridCameraPicker(
                              title: 'ຖ່າຍຮູບ',
                              callback: getFile,
                            ))).then((url) {
                  if (url != null) {
                    setState(() {
                      messageType = 'image';
                    });
                    _handleSubmitted(context, url);
                  }
                });
              },
              icon: Icon(Icons.camera_alt),
            ),
          SizedBox(
            width: 5.0,
          ),
          if (showSendButton)
            Container(
              decoration: BoxDecoration(
                  color: UIHelper.SPOTIFY_COLOR,
                  borderRadius: BorderRadius.circular(30.0)),
              child: IconButton(
                icon: Icon(Icons.send),
                iconSize: 35.0,
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    messageType = 'text';
                    isGif = true;
                  });
                  _handleSubmitted(context, _msgTextController.text);
                },
              ),
            ),
          if (!showSendButton)
            GestureDetector(
              onTap: () {
                Future<PermissionStatus> status =
                    Permission.microphone.request();
                status.then((stat) {
                  if (stat != PermissionStatus.granted) {
                    throw RecordingPermissionException(
                        "Microphone permission not granted");
                  }
                });
                _startAnimation();
                setState(() {
                  record = true;
                });
              },
              onLongPress: () {
                Future<PermissionStatus> status =
                    Permission.microphone.request();
                status.then((stat) {
                  if (stat != PermissionStatus.granted) {
                    throw RecordingPermissionException(
                        "Microphone permission not granted");
                  }
                });
                _startAnimation();
                setState(() {
                  record = true;
                  isGif = false;
                });
              },
              onLongPressStart: onLongPressStartDetail,
              onLongPressEnd: onLongPressEndDetail,
              onLongPressUp: () {
                setState(() {
                  record = false;
                  isGif = true;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: UIHelper.SPOTIFY_COLOR,
                    borderRadius: BorderRadius.circular(30)),
                child: IconButton(
                  icon: Icon(Icons.keyboard_voice),
                  color: Colors.white,
                  onPressed: () {},
                  iconSize: 35.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  onLongPressStartDetail(onLongPressTartDetails) async {
    print('Started');
    initializeDateFormatting('lo', null);
    setState(() {
      record = true;
    });
    startRecorder();
  }

  onLongPressEndDetail(onLongPressEndDetails) async {
    print('Ended');
    setState(() {
      record = false;
    });
    stopRecorder();

    if (recordingFile != null) {
      _imageUploadProvider.setToLoading();
      final audioUrl = await uploadAudio();
      setState(() {
        messageType = 'voice';
      });
      _handleSubmitted(_context, audioUrl);
      _imageUploadProvider.setToIdle();
    }
  }

  Future uploadAudio() async {
    final uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName =
        getImageFileName(G.loggedInId.toString(), '$uploadTimestamp');
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    TaskSnapshot uploading;
    uploading = await reference.putFile(
        File(recordingFile), SettableMetadata(contentType: 'audio/aac'));
    return uploading.ref.getDownloadURL();
  }

  void startRecorder() async {
    try {
      // Request Microphone permission if needed
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException("Microphone permission not granted");
      }

      await recorderModule.startRecorder(
        toFile: recordingFile,
        codec: _codec,
        bitRate: 128000,
        numChannels: 1,
        sampleRate: 96000,
      );

      print('startRecorder');

      _recorderSubscription = recorderModule.onProgress.listen((e) {
        if (e != null && e.duration != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.duration.inMilliseconds,
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'lo').format(date);

          this.setState(() {});
        }
      });

      this.setState(() {
        record = true;
        this._path[_codec.index] = recordingFile;
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        stopRecorder();
        record = false;
        cancelRecordingDataSubscription();
        cancelRecorderSubscriptions();
      });
    }
  }

  Future<void> getDuration() async {
    switch (_media) {
      case Media.file:
      case Media.buffer:
        Duration d =
            await flutterSoundHelper.duration(this._path[_codec.index]);
        break;
      case Media.asset:
        break;
      case Media.remoteExampleFile:
        break;
    }
    setState(() {});
  }

  void stopRecorder() async {
    try {
      await recorderModule.stopRecorder();
      print('stopRecorder');
      cancelRecorderSubscriptions();
      cancelRecordingDataSubscription();
      getDuration();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    this.setState(() {
      record = false;
    });
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  void cancelRecordingDataSubscription() {
    if (_recordingDataSubscription != null) {
      _recordingDataSubscription.cancel();
      _recordingDataSubscription = null;
    }
    recordingDataController = null;
    if (sink != null) {
      sink.close();
      sink = null;
    }
  }

  Future<void> releaseFlauto() async {
    try {
      await playerModule.closeAudioSession();
      await recorderModule.closeAudioSession();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  _chat(BuildContext context, type, message, fromMe, transferStatus, timestamps,
      isRead, isSend, isDeliver, data) {
    if (type == 'transfer') {
      return _transferBubble(context, message, fromMe, transferStatus,
          timestamps, isRead, isSend, isDeliver, data);
    } else if (type == 'image') {
      return _photoBubble(context, message, fromMe, transferStatus, timestamps,
          isRead, isSend, isDeliver);
    } else if (type == 'voice') {
      return _voiceBubble(context, message, fromMe, transferStatus, timestamps,
          isRead, isSend, isDeliver, data);
    } else if (type == 'video') {
      return _videoBubble(context, message, fromMe, transferStatus, timestamps,
          isRead, isSend, isDeliver, data);
    } else if (type == 'file') {
      //return _videoBubble(context, message, fromMe, transferStatus, timestamps,
      //isRead, isSend, isDeliver, data);
      double lrEdgeInsets = 1.0;
      double tbEdgeInsets = 1.0;
      return Row(
        children: <Widget>[
          Container(
            child: FileBubble(message, fromMe),
            padding: EdgeInsets.fromLTRB(
                lrEdgeInsets, tbEdgeInsets, lrEdgeInsets, tbEdgeInsets),
            constraints: BoxConstraints(maxWidth: 200.0),
            decoration: BoxDecoration(
                color: fromMe
                    ? Palette.selfMessageBackgroundColor
                    : Palette.otherMessageBackgroundColor,
                borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(
                right: fromMe ? 10.0 : 0, left: fromMe ? 0 : 10.0),
          )
        ],
        mainAxisAlignment: fromMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start, // aligns the chatitem to right end
      );
    } else {
      return _chatBubble(context, message, fromMe, transferStatus, timestamps,
          isRead, isSend, isDeliver);
    }
  }

  _chatBubble(BuildContext context, message, fromMe, transferStatus, timestamps,
      isRead, isSend, isDeliver) {
    Alignment chatArrowAlignment =
        fromMe ? Alignment.topRight : Alignment.topLeft;
    Color chatBgColor = fromMe ? messageBubbleColor : Colors.grey[200];

    return CustomPaint(
      painter: ChatBubble(
        color: chatBgColor,
        alignment: chatArrowAlignment,
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 5, 2),
        child: Stack(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              child: Container(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                      minWidth: 100.0,
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              timestamps,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                              ),
                            ),
                            SizedBox(
                              width: 4.0,
                            ),
                            fromMe
                                ? getIcon(isRead, isSend, isDeliver)
                                : Container()
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  _transferBubble(BuildContext context, message, fromMe, transferStatus,
      timestamps, isRead, isSend, isDeliver, data) {
    Alignment chatArrowAlignment =
        fromMe ? Alignment.topRight : Alignment.topLeft;

    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            final msg = MessageModel(
                id: data['timestamp'].toString(),
                content: data['content'],
                chatId: widget.chatID,
                sender: int.parse(data['idFrom']),
                transferStatus: data['transferStatus']);
            openChatTransfer(context, msg);
          },
          child: CustomPaint(
            painter: TransferBubble(
              color: Colors.transparent,
              alignment: chatArrowAlignment,
            ),
            child: Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Stack(
                children: <Widget>[
                  Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: transferStatus == "received" ||
                                    transferStatus == "done"
                                ? Colors.white
                                : transferStatus == "cancelled" ||
                                        transferStatus == "cancel"
                                    ? UIHelper.APPLE_GRADIENT_COLOR_ONE
                                    : Colors.green,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        margin: EdgeInsets.all(0.0),
                        height: 50.0,
                        padding: EdgeInsets.only(
                            left: 5.0, right: 5.0, bottom: 5.0, top: 5.0),
                        constraints: BoxConstraints(
                          minWidth: 100.0,
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: transferStatus == "received" ||
                                            transferStatus == "done"
                                        ? Colors.green
                                        : transferStatus == "cancelled" ||
                                                transferStatus == "cancel"
                                            ? UIHelper.APPLE_GRADIENT_COLOR_TWO
                                            : UIHelper.APRICOT_PRIMARY_COLOR,
                                    borderRadius: BorderRadius.circular(30.0)),
                                height: 40.0,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    transferStatus == "received" ||
                                            transferStatus == "done"
                                        ? 'assets/images/icons8-checkmark.png'
                                        : transferStatus == "cancelled" ||
                                                transferStatus == "cancel"
                                            ? 'assets/images/icons8-cancel.png'
                                            : 'assets/images/icons8-data_transfer.png',
                                    color: UIHelper.WHITE,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                new NumberFormat("#,###")
                                        .format(double.parse(message)) +
                                    ' LAK',
                                style: TextStyle(
                                  color: transferStatus == "received" ||
                                          transferStatus == "done"
                                      ? UIHelper.THEME_PRIMARY
                                      : transferStatus == "cancelled" ||
                                              transferStatus == "cancel"
                                          ? UIHelper.STRAWBERRY_SHADOW
                                          : UIHelper.WHITE,
                                  fontSize: 22.0,
                                ),
                              ),
                            ]),
                      ),
                      Container(
                        margin: EdgeInsets.all(0.0),
                        color: transferStatus == "received" ||
                                transferStatus == "done"
                            ? UIHelper.THEME_PRIMARY
                            : transferStatus == "cancelled" ||
                                    transferStatus == "cancel"
                                ? UIHelper.FIG_TEXT_COLOR
                                : UIHelper.SPOTIFY_COLOR,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                getStatus(transferStatus, fromMe),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    timestamps,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  fromMe
                                      ? getIcon(isRead, isSend, isDeliver)
                                      : Container()
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _photoBubble(BuildContext context, imageUrlFromFB, fromMe, transferStatus,
      timestamps, isRead, isSend, isDeliver) {
    Alignment chatArrowAlignment =
        fromMe ? Alignment.topRight : Alignment.topLeft;
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullPhoto(
                    url: imageUrlFromFB,
                    imageProvider: CachedNetworkImageProvider(imageUrlFromFB),
                  ),
                ));
          },
          child: CustomPaint(
            painter: PhotoBubble(
              color: Colors.transparent,
              alignment: chatArrowAlignment,
            ),
            child: Container(
              width: 160,
              child: Stack(
                children: <Widget>[
                  Container(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[900],
                            border:
                                Border.all(color: Colors.grey[100], width: 3),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Container(
                          child: CachedNetworkImage(
                            imageUrl: imageUrlFromFB,
                            placeholder: (context, url) => Container(
                              transform: Matrix4.translationValues(0, 0, 0),
                              child: Container(
                                  width: 160,
                                  height: 180,
                                  child: Center(
                                      child: new CircularProgressIndicator())),
                            ),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                            width: 160,
                            height: 180,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  timestamps,
                                  style: TextStyle(
                                    color: UIHelper.FIG_TEXT_COLOR,
                                    fontSize: 10.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.0,
                                ),
                                fromMe
                                    ? getIcon(isRead, isSend, isDeliver)
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _voiceBubble(BuildContext context, imageUrlFromFB, fromMe, transferStatus,
      timestamps, isRead, isSend, isDeliver, data) {
    Alignment chatArrowAlignment =
        fromMe ? Alignment.topRight : Alignment.topLeft;
    return Column(
      children: <Widget>[
        CustomPaint(
          painter: ChatBubble(
            color: Colors.transparent,
            alignment: chatArrowAlignment,
          ),
          child: Container(
            child: Stack(
              children: <Widget>[
                Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            color: Color(0xFFFAF0E6),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: _buildPlayer(imageUrlFromFB, fromMe)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                timestamps,
                                style: TextStyle(
                                  color: UIHelper.FIG_TEXT_COLOR,
                                  fontSize: 10.0,
                                ),
                              ),
                              SizedBox(
                                width: 4.0,
                              ),
                              fromMe
                                  ? getIcon(isRead, isSend, isDeliver)
                                  : Container()
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer(url, fromMe) {
    return Padding(
        padding: const EdgeInsets.all(0.0),
        child: RecorderPlaybackController(
            child: Column(
          children: [
            AudioPlayers(
              url,
              fromMe: fromMe,
            ),
//            SoundPlayerUI.fromLoader(
//              (context) => loadTrack(context, url),
//              showTitle: true,
//              audioFocus: AudioFocus.requestFocusAndDuckOthers,
//            )
          ],
        )));
  }

  Future<Track> loadTrack(BuildContext context, url) async {
    Track track;
    track = Track(trackPath: url, codec: ActiveCodec().codec);
    track.albumArtUrl =
        'https://file-examples-com.github.io/uploads/2017/10/file_example_PNG_500kB.png';
    if (Platform.isIOS) {
      track.albumArtAsset = 'AppIcon';
    } else if (Platform.isAndroid) {
      track.albumArtAsset = 'AppIcon.png';
    }
    return track;
  }

  _videoBubble(BuildContext context, imageUrlFromFB, fromMe, transferStatus,
      timestamps, isRead, isSend, isDeliver, data) {
    Alignment chatArrowAlignment =
        fromMe ? Alignment.topRight : Alignment.topLeft;
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoBox(data['content']),
                    fullscreenDialog: true));
//            showVideoPlayer(context, data['content']);
          },
          child: CustomPaint(
            painter: PhotoBubble(
              color: Colors.transparent,
              alignment: chatArrowAlignment,
            ),
            child: Container(
              width: 160,
              child: Stack(
                children: <Widget>[
                  Container(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              border: Border.all(
                                  color: UIHelper.POMEGRANATE_TEXT_COLOR,
                                  width: 3),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Container(
                              child: Stack(children: [
                            CachedNetworkImage(
                              imageUrl: imageUrlFromFB,
                              placeholder: (context, url) => Container(
                                transform: Matrix4.translationValues(0, 0, 0),
                                child: Container(
                                    width: 180,
                                    height: 160,
                                    child: Center(
                                        child:
                                            new CircularProgressIndicator())),
                              ),
                              errorWidget: (context, url, error) =>
                                  new Icon(Icons.error),
                              width: 180,
                              height: 160,
                              fit: BoxFit.fitWidth,
                            ),
                            Container(
                              width: 180,
                              height: 160,
                              child: Image.asset(
                                'assets/images/play3.png',
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ]))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  timestamps,
                                  style: TextStyle(
                                    color: UIHelper.FIG_TEXT_COLOR,
                                    fontSize: 10.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.0,
                                ),
                                fromMe
                                    ? getIcon(isRead, isSend, isDeliver)
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<File> getThumbnail(File videoFile) async {
    Uint8List uint8list;
    return OCWA.checkAndRequestPermission(Permission.storage).then((res) async {
      if (res) {
        uint8list = await VideoThumbnail.thumbnailData(
          video: videoFile.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 160,
          // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 100,
        );
        final file = File('${(await getTemporaryDirectory()).path}/' +
            randomIdWithName('image') +
            '.jpeg');
        await file.writeAsBytes(uint8list);
        return file;
      } else {
        OCWA.showRationale(
            'Permission to access gallery needed to send photos to your friends.');
        return null;
      }
    });
  }

  Future<String> confirmDialog(BuildContext context) async {
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
          child: _dialogContent(context),
        );
      },
    );
  }

  _dialogContent(BuildContext context) {
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
                  'ຢືນຢັນການໂອນ',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'ໂອນເງິນໃຫ້: ' + widget.selectedUserName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  new NumberFormat("#,###").format(_amount.numberValue) +
                      ' LAK',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: UIHelper.SPOTIFY_COLOR,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Text(
                      'ກະລຸນາປ້ອນລະຫັດສ່ວນຕົວຂອງທ່ານເພື່ອຢືນຢັນ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: PinEntryTextField(
                    isTextObscure: true,
                    showFieldAsBox: true,
                    onSubmit: (String pin) {
                      pinCode = pin; //end showDialog()
                    }, // end onSubmit
                  ),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text('ຢືນຢັນ'),
                        color: UIHelper.SPOTIFY_COLOR,
                        onPressed: () {
                          if (pinCode.isNullOrEmpty()) {
                            Alert.info(context, 'ແຈ້ງເຕືອນ',
                                'ກະລຸນາປ້ອນລະຫັດຢືນຢັນ', 'OK');
                            return;
                          } else {
                            Navigator.of(context).pop(pinCode);
                          }
                        },
                      ),
                      FlatButton(
                        child: Text('ຍົກເລີກ'),
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

  _onSelectMenuOption(ChatDetailMenuOptions option) {
    switch (option) {
      case ChatDetailMenuOptions.viewContact:
        break;
      case ChatDetailMenuOptions.media:
        break;
      case ChatDetailMenuOptions.search:
        break;
      case ChatDetailMenuOptions.muteNotifications:
        break;
      case ChatDetailMenuOptions.wallpaper:
        break;
      case ChatDetailMenuOptions.more:
        break;
    }
  }

  void transfer(BuildContext context) async {
    if (_amount.numberValue == 0) {
      return;
    }
    final String personalCode = await confirmDialog(context);
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      if (personalCode != null && personalCode != "") {
        await pr.show();
        pr.update(message: 'ກຳລັງດຳເນີນ...');
        final result2 = await NetworkUtil.post(
            '/validate-wallet',
            jsonEncode({
              "id": await services.getValue("id"),
              "passcode": personalCode
            }));
        await pr.hide();
        if (result2.status == 'success') {
          if (result2.data == "1") {
            await pr.show();
            pr.update(message: 'ກຳລັງກວດສອບຍອດເງິນ...');
            final result = await NetworkUtil.post(
                '/check-wallet-amount',
                jsonEncode({
                  "account_id": await services.getValue(ACCOUNT_ID),
                  "amount": _amount.numberValue
                }));
            await pr.hide();
            if (result.status == "success") {
              setState(() {
                messageType = 'transfer';
              });
              _handleSubmitted(context, _amount.numberValue.toString());
              Alert.success(
                  context,
                  'ໂອນເງິນສຳລເັດ',
                  'ຈຳນວນເງິນ: ' +
                      new NumberFormat("#,###").format(_amount.numberValue),
                  "OK", action: () {
                Navigator.pop(context);
              });
            } else {
              Alert.warning(context, result.status, result.message, "OK");
            }
          } else {
            Alert.error(context, 'ແຈ້ງເຕືອນ', 'ລະຫັດສ່ວນຕົວບໍ່ຖືກຕ້ອງ', "OK");
          }
        }
      }
    } catch (e) {
      await pr.hide();
      Alert.error(context, 'ເກີດບັນຫາຂັດຂ້ອງ', e.toString(), 'OK');
    }
  }

  void openAmountPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'ໂອນເງິນໃຫ້',
                        style: TextStyle(
                            color: UIHelper.THEME_PRIMARY, fontSize: 18.0),
                      ),
                      Text(
                        widget.selectedUserName,
                        style: TextStyle(
                            color: UIHelper.THEME_PRIMARY, fontSize: 25.0),
                      ),
                      TextFormField(
                        controller: _amount,
                        focusNode: _amountFocus,
                        onChanged: (value) {
//                                                      _amount.updateValue(0.0);
                        },
                        keyboardType: TextInputType.phone,
                        autocorrect: true,
                        obscureText: false,
                        style: TextStyle(fontFamily: 'Souliyo', fontSize: 20.0),
                        decoration: InputDecoration(
                            labelText: 'ຈຳນວນເງິນ',
                            hintText: '2,XXX,XXX',
                            hintStyle: TextStyle(
                                color: UIHelper.POMEGRANATE_TEXT_COLOR),
                            border: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0))),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: FlatButton.icon(
                                onPressed: () {
                                  if (_amount != null &&
                                      _amount.text.trim() != "") {
                                    //Navigator.of(context, rootNavigator: true).pop();
                                    transfer(context);
                                  }
                                },
                                color: UIHelper.SPOTIFY_COLOR,
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'ໂອນ',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                          Container(
                            child: FlatButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                color: UIHelper.WATERMELON_PRIMARY_COLOR,
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'ຍົກເລີກ',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  String getStatus(transferStatus, bool fromMe) {
    if (transferStatus == "sent") {
      if (fromMe) {
        return "ໂອນເງິນໃຫ້ " + widget.selectedUserName;
      } else {
        return "ໂອນເງິນຈາກ " + widget.selectedUserName;
      }
    } else if (transferStatus == "received" || transferStatus == 'done') {
      if (fromMe) {
        return widget.selectedUserName + " ໄດ້ຮັບເງິນແລ້ວ";
      } else {
        return "ໄດ້ຮັບເງິນແລ້ວ";
      }
    } else if (transferStatus == "cancelled" || transferStatus == 'cancel') {
      return "ການໂອນເງິນຖືກຍົກເລີກແລ້ວ";
    } else {
      if (fromMe) {
        return "ໂອນເງິນໃຫ້ " + widget.selectedUserName;
      } else {
        return "ໂອນເງິນຈາກ " + widget.selectedUserName;
      }
    }
  }

  void openChatTransfer(BuildContext context, MessageModel message) async {
    final result =
        await Navigator.of(context).push(new MaterialPageRoute<MessageModel>(
            builder: (BuildContext context) {
              return new ChatTransfer(
                message: message,
                user: new UserModel(
                    id: widget.selectedUserID, name: widget.selectedUserName),
              );
            },
            fullscreenDialog: true));
    setState(() {
      message = result;
    });
  }

  void goBack(BuildContext context) async {
    Navigator.of(context).pop();
  }
}

enum UserOnlineStatus { connecting, online, not_online }
