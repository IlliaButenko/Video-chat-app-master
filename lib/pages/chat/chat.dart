import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:OCWA/Controllers/firebaseController.dart';
import 'package:OCWA/Controllers/notificationController.dart';
import 'package:OCWA/Controllers/utils.dart';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/enum/user_state.dart';
import 'package:OCWA/models/call.dart';
import 'package:OCWA/models/chat_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/callscreens/incoming_call.dart';
import 'package:OCWA/pages/callscreens/isolate_manager.dart';
import 'package:OCWA/pages/callscreens/pickup/pickup_layout.dart';
import 'package:OCWA/pages/chat/all_people.dart';
import 'package:OCWA/pages/chat/all_user.dart';
import 'package:OCWA/pages/chat/user.dart';
import 'package:OCWA/pages/chat/widgets/add_friend.dart';
import 'package:OCWA/pages/chat/widgets/online_users.dart';
import 'package:OCWA/pages/chat/widgets/online_users_count.dart';
import 'package:OCWA/pages/chat/widgets/unread_count.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/login/login.dart';
import 'package:OCWA/pages/profile/profile.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:OCWA/provider/user_provider.dart';
import 'package:OCWA/resources/local_db/repository/log_repository.dart';
import 'package:OCWA/ui/dialog/friend_request.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/ui/widgets/loading_shimmer.dart';
import 'package:OCWA/utils/connectivity.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clearnotification/clearnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/commons.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as schedule;
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';
import 'package:OCWA/utils/extension.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:workmanager/workmanager.dart';
import '../home.dart';
import 'notifications/notifications.dart';
import 'notifications/schedule_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'tools/GlobalChat.dart';
import 'chat_list_screen.dart';
import 'name_icon.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    // initialise the plugin of flutterlocalnotifications.
    FlutterLocalNotificationsPlugin flip =
        new FlutterLocalNotificationsPlugin();

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = new IOSInitializationSettings();

    // initialise settings for both Android and iOS device.
    var settings = new InitializationSettings(android, IOS);
    flip.initialize(settings);
    _showNotificationWithDefaultSound(flip);
    return Future.value(true);
  });
}

Future _showNotificationWithDefaultSound(flip) async {
  // Show a notification after every 15 minute with the first
  // appearance happening a minute after invoking the method
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flip.show(0, 'OCWA', 'TEST', platformChannelSpecifics,
      payload: 'Default_Sound');
}

enum ChatOptions {
  findFriend,
  sentRequest,
  receiveRequest,
  settings,
  clear,
  logout
}

Services services = new StorageServiceSharedPreferences();
enum ConfirmAction { CANCEL, ACCEPT }

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin {
  List<UserModel> _totalFriends;
  List<UserModel> _onlineFriends;
  List<ChatModel> _chatLists;
  bool isLoading;
  bool chatLoading = false;
  int selectedIndex = 0;
  final List<String> categories = ['ສົນທະນາ', 'ເພື່ອນອອນລາຍ', 'ເພື່ອນທັງໝົດ'];
  UserModel user;
  int friendRequest = 0;
  bool hasInternet = true;

  List<double> itemHeights;
  List<Color> itemColors;
  bool reversed = false;
  bool isRead = true;

  /// The alignment to be used next time the user scrolls or jumps to an item.
  double alignment = 0;
  bool _isSearching;
  TextField _searchBar;
  TextEditingController _searchBarController;
  String _searchKeyword = '';

  int _tabIndex;
  TabController _tabController;
  bool isNewStatus = false;
  SharedPreferences prefs;
  StreamSubscription spokenSubscription;
  List<StreamSubscription> unreadSubscriptions = List<StreamSubscription>();
  String currentUserNo;
  List<StreamController> controllers = new List<StreamController>();
  StreamController<String> _userQuery =
      new StreamController<String>.broadcast();
  List<Map<String, dynamic>> _users = List<Map<String, dynamic>>();
  bool showHidden = false, biometricEnabled = false;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  UserProvider userProvider;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _platformVersion = 'Unknown';
  bool _isShowingWindow = false;
  bool _isUpdatedWindow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
    schedule.SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      FirebaseController.instance.setUserState(
        userId: userProvider.getUser.phone,
        userState: UserState.Online,
      );

      LogRepository.init(
        isHive: true,
        dbName: userProvider.getUser.uid,
      );
    });
    firebaseCloudMessaging_Listeners();
    NetworkCheck.checkInternet(fetchPrefrence);
    OCWA.internetLookUp();
    NotificationController.instance.takeFCMTokenWhenAppLaunch();
    NotificationController.instance.initLocalNotification();
    FirebaseController.instance.getUnreadMSGCount(G.loggedInId.toString());
    setCurrentChatRoomID('none');
    _initPlatformState();
    _checkPermissions();

    isLoading = true;
    _isSearching = false;
    _tabIndex = 0; // Start at second tab.

    _searchBarController = new TextEditingController();
    _searchBarController.addListener(() {
      setState(() {
        _searchKeyword = _searchBarController.text;
      });
    });

    _searchBar = new TextField(
      controller: _searchBarController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'ຄົ້ນຫາ...',
        border: InputBorder.none,
      ),
    );

    _tabController = new TabController(
      length: 3,
      initialIndex: _tabIndex,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
        _isSearching = false;
        _searchBarController?.text = "";
        if (_tabController.index == 2) {
          isNewStatus = false;
        }
      });
    });
  }

  init() async {
    try {
      prefs = await SharedPreferences.getInstance();
      currentUserNo = await services.getValue(PHONE);
      user = new UserModel();
      if (mounted) {
        setState(() {
          user = Global.userModel;
        });
      }

      await loadWallet();

      final request = await NetworkUtil.post('/count-pending-friend-request',
          jsonEncode({"id": await services.getValue(ID)}));
      if (mounted) {
        setState(() {
          friendRequest = request.data;
        });
      }

      final friend = await NetworkUtil.getUserList('/load-friends');
      if (mounted) {
        setState(() {
          _totalFriends = friend;
          isLoading = false;
        });
      }

      Timer.periodic(new Duration(seconds: 1), (timer) async {
        final request = await NetworkUtil.post('/count-pending-friend-request',
            jsonEncode({"id": await services.getValue(ID)}));
        if (mounted) {
          setState(() {
            friendRequest = request.data;
          });
        }
      });
    } catch (e) {
      print(e.toString());
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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

  void firebaseCloudMessaging_Listeners() {
    Future.delayed(Duration(seconds: 1), () {
      if (Platform.isIOS) iOS_Permission();
      _firebaseMessaging.configure(
        onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
        },
      );
    });
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      NotificationController.instance
          .sendLocalNotification(data['title'], data['body'], jsonEncode(data));
      if (data['msg_type'] != 'call') {
        await Firebase.initializeApp();
        await FirebaseController.instance
            .updateChatRoomStatus(data['chatroomid'], data['msg_id'], true);
      } else {
//        Call call = Call(callerName: data['title']);
//        await IncomingCall.instance.showOverlayWindow(call);
        await LaunchApp.openApp(
            androidPackageName: 'com.oudomsup.ocwa',
            iosUrlScheme: 'ocwa://',
            openStore: false);
//        FlutterRingtonePlayer.play(
//          android: AndroidSounds.ringtone,
//          ios: IosSounds.voicemail,
//          looping: true, // Android only - API >= 28
//          volume: 0.1, // Android only - API >= 28
//          asAlarm: false, // Android only - all APIs
//        );
      }
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print('FCM: notification $notification');
    }

    // Or do other work.
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await SystemAlertWindow.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _checkPermissions() async {
    await SystemAlertWindow.checkPermissions;
//    ReceivePort _port = ReceivePort();
//    IsolateManager.registerPortWithName(_port.sendPort);
//    _port.listen((dynamic callBackData) async {
//      String tag= callBackData[0];
//      switch (tag) {
//        case "reject_call":
//          print("Call reject");
//          await SystemAlertWindow.closeSystemWindow();
//          break;
//        case "accept_call":
//          print("Accept Call");
//
//          break;
//      }
//    });

    SystemAlertWindow.registerOnClickListener(callBack);
//    SystemAlertWindow.registerOnClickListener(callBackFunction);
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();

    String currentUserId = currentUserNo;

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
    if (currentUserNo != null)
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(currentUserNo)
          .set({LAST_SEEN: true}, SetOptions(merge: true));
  }

  void setLastSeen() async {
    if (currentUserNo != null)
      await FirebaseFirestore.instance.collection(USERS).doc(currentUserNo).set(
          {LAST_SEEN: DateTime.now().millisecondsSinceEpoch},
          SetOptions(merge: true));
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
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controllers.forEach((controller) {
      controller.close();
    });
    spokenSubscription?.cancel();
    _userQuery.close();
    cancelUnreadSubscriptions();
    setLastSeen();
  }

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription?.cancel();
    });
  }

  bool _searhBarOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NetworkCheck.checkInternet(fetchPrefrence);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => exit(context),
      child: PickupLayout(
        scaffold: new Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            backgroundColor: _isSearching ? Colors.white : null,
            leading: _isSearching
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: UIHelper.SPOTIFY_COLOR,
                    onPressed: () {
                      setState(() {
                        _searhBarOpen = false;
                        _isSearching = false;
                        _searchBarController?.text = "";
                      });
                    },
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Home(
                                    widget: Profile(),
                                    tab: 2,
                                  )));
                    },
                    child: Global.userModel.avatar != null
                        ? new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  Global.userModel.avatar),
                            ),
                          )
                        : new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/images/default_profile.png'),
                            ),
                          ),
                  ),
            title: _isSearching
                ? _searchBar
                : Text(
                    Global.userModel.name != null ? Global.userModel.name : '',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
            actions: _isSearching
                ? null
                : <Widget>[
                    NamedIcon(
                      text: 'ແຈ້ງເຕືອນ',
                      iconData: Icons.notifications,
                      notificationCount: friendRequest,
                      isBadge: true,
                      onTap: () {
                        openNotification();
                      },
                    ),
                    NamedIcon(
                      text: 'ຄົ້ນຫາ',
                      iconData: Icons.search,
                      notificationCount: 11,
                      isBadge: false,
                      onTap: () {
                        setState(() {
                          _searhBarOpen = true;
                          _isSearching = true;
                          _searchBarController?.text = "";
                        });
                      },
                    ),
                    PopupMenuButton<ChatOptions>(
                      tooltip: "ຕົວເລືອກອື່ນ",
                      onSelected: _selectOption,
                      itemBuilder: (BuildContext context) {
                        return getPopupMenu();
                      },
                    ),
                  ],
            bottom: _isSearching
                ? null
                : TabBar(
                    controller: _tabController,
                    tabs: <Widget>[
                      Tab(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "ສົນທະນາ",
                              ),
                              UnReadCount()
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "ເພື່ອນອອນລາຍ",
                              ),
                              OnlineUsersCount()
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "ເພື່ອນທັງໝົດ",
                        ),
                      ),
                    ],
                    labelPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(),
                  child: chatContainer(context),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ClipRRect(
                    child: (isLoading)
                        ? LoadingShimmer()
                        : OnlineUsers(phone: currentUserNo)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ClipRRect(
                  child: friendsContainer(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  chatContainer(BuildContext context) {
    return VisibilityDetector(
      key: Key("1"),
      onVisibilityChanged: ((visibility) async {
        print('ChatList Visibility code is ' + '${visibility.visibleFraction}');
        if (visibility.visibleFraction == 1.0) {
          FirebaseController.instance
              .getUnreadMSGCount(G.loggedInId.toString());
        }
        try {
          await ClearNotification.all;
        } on PlatformException {}
      }),
      child: ChatListScreen(
        currentUserNo: currentUserNo,
      ),
    );
  }

  friendsContainer(BuildContext context) {
    if (isLoading) {
      return LoadingShimmer();
    } else {
      if (_totalFriends == null || _totalFriends.length == 0) {
        return AddFriend();
      } else {
        return _totalFriendsList();
      }
    }
  }

  ListView _totalFriendsList() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: _totalFriends != null ? _totalFriends.length : 0,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int index) {
        UserModel user = _totalFriends[index];
        return GestureDetector(
          onTap: () async {
            final tmp = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return new UserPage(record: user);
            }));
            setState(() {
              user = tmp;
              if (user.friendStatus == -1)
                _totalFriends.removeWhere((element) => element.id == user.id);
            });
          },
          child: Container(
            height: 60.0,
            margin: EdgeInsets.only(bottom: 1.0, top: 2.0),
            padding: EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
                color: UIHelper.WHITE, borderRadius: BorderRadius.circular(0)),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 25.0,
                  backgroundImage: CachedNetworkImageProvider(user.avatar),
                ),
                SizedBox(width: 6.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        color: UIHelper.THEME_PRIMARY,
                        fontSize: 16.0,
                      ),
                    ),
                    Text("@" + user.accountId,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: UIHelper.SPOTIFY_COLOR)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> logout(BuildContext context) async {
    confirmationDialog(context, "ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ?",
        title: 'ອອກຈາກລະບົບ',
        confirm: false,
        neutralText: 'ຕ້ອງການ',
        positiveText: "ບໍ່ຕ້ອງການ",
        positiveAction: () {}, neutralAction: () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      FirebaseController.instance
          .setUserState(userId: currentUserNo, userState: UserState.Offline);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    });

    return false;
  }

  exit(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void _selectOption(ChatOptions option) async {
    switch (option) {
      case ChatOptions.findFriend:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AllUser()));
        break;
      case ChatOptions.sentRequest:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AllPeople()));
        break;
      case ChatOptions.receiveRequest:
        openNotification();
        break;
      case ChatOptions.settings:
        Call call = Call(callerName: 'Test');
        await IncomingCall.instance.showOverlayWindow(call);
        break;
      case ChatOptions.clear:
        break;
      case ChatOptions.logout:
        logout(context);
        break;
    }
  }

  Future openNotification() async {
    final result =
        await Navigator.of(context).push(new MaterialPageRoute<UserModel>(
            builder: (BuildContext context) {
              return new FriendRequestDialog();
            },
            fullscreenDialog: true));
    setState(() {
      init();
    });
  }

  String getMessage(ChatModel chat) {
    bool fromMe = chat.sender == G.loggedInUser.id;
    if (chat.transferStatus == "sent" || chat.transferStatus.isNullOrEmpty()) {
      if (fromMe) {
        return "ໂອນເງິນໃຫ້ " + chat.name;
      } else {
        return "ໄດ້ຮັບເງິນໂອນຈາກ " + chat.name;
      }
    } else if (chat.transferStatus == "received" ||
        chat.transferStatus == "done") {
      if (fromMe) {
        return chat.name + " ໄດ້ຮັບເງິນແລ້ວ";
      } else {
        return "ໄດ້ຮັບເງິນແລ້ວ";
      }
    } else if (chat.transferStatus == "cancelled" ||
        chat.transferStatus == "cancel") {
      return "ການໂອນເງິນຖືກຍົກເລກແລ້ວ";
    } else {
      if (fromMe) {
        return "ໂອນເງິນໃຫ້ " + chat.name;
      } else {
        return "ໂອນເງິນຈາກ " + chat.name;
      }
    }
  }

  getPopupMenu() {
    return [
      PopupMenuItem<ChatOptions>(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search,
              size: 24.0,
              color: Colors.black,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('ຫາເພື່ອນໃໝ່'),
          ],
        ),
        value: ChatOptions.findFriend,
      ),
      PopupMenuItem<ChatOptions>(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.people_outline,
              size: 24.0,
              color: Colors.black,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('ຄົນທີ່ທ່ານໄດ້ສົ່ງຂໍເປັນເພື່ອນ'),
          ],
        ),
        value: ChatOptions.sentRequest,
      ),
      PopupMenuItem<ChatOptions>(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.people,
              size: 24.0,
              color: Colors.black,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('ຄົນທີ່ໄດ້ສົ່ງຂໍທ່ານເປັນເພື່ອນ'),
          ],
        ),
        value: ChatOptions.receiveRequest,
      ),
      PopupMenuItem<ChatOptions>(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.settings,
              size: 24.0,
              color: Colors.black,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('ຕັ້ງຄ່າ'),
          ],
        ),
        value: ChatOptions.settings,
      ),
      PopupMenuItem<ChatOptions>(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.settings,
              size: 24.0,
              color: Colors.black,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('ລົບຂໍ້ຄວາມທັງໝົດ'),
          ],
        ),
        value: ChatOptions.clear,
      ),
      PopupMenuItem<ChatOptions>(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.lock,
              size: 24.0,
              color: Colors.black,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('ອອກຈາກລະບົບ'),
          ],
        ),
        value: ChatOptions.logout,
      ),
    ];
  }

  @override
  bool get wantKeepAlive => true;
}

bool callBackFunction(String tag) {
  print("Got tag " + tag);
  SendPort port = IsolateManager.lookupPortByName();
  port.send([tag]);
  return true;
}

void callBack(String tag) async {
  print(tag);
  switch (tag) {
    case "reject_call":
      await SystemAlertWindow.closeSystemWindow();
      break;
    case "accept_call":
      await LaunchApp.openApp(
          androidPackageName: 'com.oudomsup.ocwa',
          iosUrlScheme: 'ocwa://',
          openStore: false);
      await SystemAlertWindow.closeSystemWindow();
      break;
    default:
      print("OnClick event of $tag");
  }
}
