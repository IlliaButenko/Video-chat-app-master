import 'dart:async';
import 'dart:convert';

import 'package:OCWA/Controllers/firebaseController.dart';
import 'package:OCWA/data/networkutil.dart';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/enum/user_state.dart';
import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/pages/callscreens/pickup/pickup_layout.dart';
import 'package:OCWA/pages/chat/chat.dart';
import 'package:OCWA/pages/chat/tools/GlobalChat.dart';
import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/login/login.dart';
import 'package:OCWA/pages/profile/profile.dart';
import 'package:OCWA/pages/qr/generate.dart';
import 'package:OCWA/pages/topup/topup.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/ui/widgets/add_button.dart';
import 'package:OCWA/ui/widgets/user_card.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:OCWA/utils/global.dart';
import 'package:OCWA/utils/navigator.dart';
import 'package:OCWA/utils/screen_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../home.dart';

Services services = new StorageServiceSharedPreferences();
enum ConfirmAction { CANCEL, ACCEPT }

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isLoggedIn = false;
  bool isLoading = false;
  final formatter = new NumberFormat("#,###");
  dynamic timer;
  String pinCode = '';
  int option;
  dynamic wallet;
  List<TransferHistoryModel> historyModel;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    init();
  }

  init() async {
    try {
      wallet = Global.wallet;
      historyModel = Global.historyModel;
      Timer.periodic(new Duration(seconds: 5), (timer) async {
        final model = await NetworkUtil.post('/wallet',
            jsonEncode({"id": await services.getValue(ACCOUNT_ID)}));
        if (model.status == "success") {
          if (mounted) {
            setState(() {
              Global.wallet = model.data;
              wallet = model.data;
            });
          }
        }
        historyModel =
            await NetworkUtil.getTransferContact('/transfer-history');
      });
      isLoading = false;
    } catch (e) {
      isLoading = false;
    }
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
          FirebaseController.instance.setUserState(
              userId: Global.firePhone(G.loggedInUser.phone), userState: UserState.Offline);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Login()));
        });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light,
    );
    return PickupLayout(
      scaffold: WillPopScope(
        onWillPop: () async => goTo(context),
        child: new Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.account_balance_wallet),
              iconSize: 50.0,
              color: Colors.white,
              onPressed: () {},
            ),
            title: Text(
              'ກະເປົາ',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w200,
              ),
            ),
            elevation: 0.0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.lock),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: () {
                  logout(context);
                },
              ),
            ],
          ),
          body: walletContainer(context),
        ),
      ),
    );
  }

  Widget _buildServices({String text, Image image, Color color, String route}) {
    return GestureDetector(
        onTap: () {
          // Pushing a named route
          Navigator.of(context).pushNamed(
            route,
            arguments: '',
          );
        }, // handle your onTap here
        child: Column(
          children: <Widget>[
            Container(
              height: 75,
              width: 75,
              margin: EdgeInsets.only(bottom: 18),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: image,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 18, color: UIHelper.SPOTIFY_COLOR),
            ),
          ],
        ));
  }

  Widget _buildCard({String image}) {
    return Container(
      height: 105,
      width: 205,
      margin: EdgeInsets.only(left: 20, top: 10, bottom: 20),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: [
        BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 15)
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
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
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: data.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
              padding: EdgeInsets.only(right: 10), child: AddButton());
        }
        return Padding(
          padding: EdgeInsets.only(right: 20),
          child: UserCardWidget(
            user: data[index - 1],
          ),
        );
      },
    );
  }

  ListView historyListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: historyModel != null ? historyModel.length + 1 : 0,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
              padding: EdgeInsets.only(right: 10), child: AddButton());
        }
        return Padding(
          padding: EdgeInsets.only(right: 20),
          child: UserCardWidget(
            user: historyModel[index - 1],
          ),
        );
      },
    );
  }

  Future<bool> goTo(BuildContext context) async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  widget: Chat(),
                  tab: 0,
                )));
    return false;
  }

  unlockWallet(BuildContext context) async {
    final data = jsonEncode({
      "id": await services.getValue("id"),
    });
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    try {
      await pr.show();
      pr.update(message: 'ກຳລັງດຳເນີນ...');
      final result = await NetworkUtil.post('/wallet-status', data);
      await pr.hide();
      if (result.status == 'success') {
        if (result.data == "1") {
          option = 1;
        } else {
          option = 0;
        }
        final String personalCode = await confirmDialog(context);
        if (personalCode != null && personalCode != "") {
          if (option == 0) {
            await pr.show();
            pr.update(message: 'ກຳລັງດຳເນີນ...');
            final _res = await NetworkUtil.post(
                '/unlock-wallet',
                jsonEncode({
                  "id": await services.getValue("id"),
                  "passcode": personalCode
                }));
            await pr.hide();
            if (_res.status == 'success') {
              setState(() {
                Alert.success(context, 'ສຳເລັດ', '', 'OK');
                Global.enableWallet = true;
              });
            }
          } else {
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
                setState(() {
                  Global.enableWallet = true;
                });
              } else {
                setState(() {
                  Global.enableWallet = false;
                });
                Alert.warning(
                    context, 'ແຈ້ງເຕືອນ', 'ລະຫັດສ່ວນຕົວບໍ່ຖືກຕ້ອງ', 'OK');
              }
            }
          }
        }
      }
    } catch (e) {}
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
                  option == 1 ? 'ຢືນຢັນລະຫັດສ່ວນຕົວ' : 'ຕິດຕັ້ງລະຫັດສ່ວນຕົວ',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Text(
                      '',
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
                      pinCode = pin;
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
                        child: Text(option == 1 ? 'ຢືນຢັນ' : 'ຕິດຕັ້ງ'),
                        color: UIHelper.SPOTIFY_COLOR,
                        onPressed: () {
                          print(pinCode);
                          if (pinCode.isEmpty) {
                            Alert.warning(context, 'ແຈ້ງເຕືອນ',
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

  void qr() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GenerateScreen(), fullscreenDialog: true),
    );
  }

  getProfileImage() async {
    print(await services.getValue('image'));
  }

  walletContainer(BuildContext context) {
    final _media = MediaQuery.of(context).size;
    if (isLoading == true) {
      return Center(
        child: Container(
          child: Text('ກຳລັງອັບເດດຂໍ້ມູນ....'),
        ),
      );
    } else if (Global.enableWallet != null && Global.enableWallet) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 120,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              decoration: BoxDecoration(
                  color: UIHelper.SPOTIFY_COLOR,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'ຍອດເງິນ',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                letterSpacing: 1.5),
                          ),
                          Text(
                            (wallet != null)
                                ? formatter.format(wallet).toString()
                                : '',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                fontFamily: 'Muli',
                                fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: qr,
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: Image(
                                  image:
                                      AssetImage('assets/images/qrscan_3.png'),
                                  fit: BoxFit.cover,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          if (Global.userModel.avatar != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home(
                                              widget: Profile(),
                                              tab: 2,
                                            )));
                              },
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image(
                                    image:
                                        CachedNetworkImageProvider(Global.userModel.avatar),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'ຊື່ ແລະ ນາມສະກຸນ',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                letterSpacing: 1.5),
                          ),
                          Text(
                            (Global.userModel != null)
                                ? Global.userModel.name.toString()
                                : '',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                      color: Colors.black45,
                                      offset: Offset(1, 2),
                                      blurRadius: 2),
                                ]),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'ວັນທີເຂົ້າເປັນສະມາຊິກ'.toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                letterSpacing: 1.5),
                          ),
                          Text(
                            (Global.userModel != null)
                                ? Global.dateOnly(
                                    Global.userModel.created.toString())
                                : '',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'WorkSans',
                                shadows: [
                                  Shadow(
                                      color: Colors.black45,
                                      offset: Offset(1, 2),
                                      blurRadius: 2),
                                ]),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 95.0,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Table(
                        children: [
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: UIHelper.SPOTIFY_COLOR,
                                        width: 2.0)),
                                onPressed: () {
                                  navigator(context, TopUp());
                                },
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(
                                      Icons.add,
                                      size: 25.0,
                                      color: UIHelper.SPOTIFY_COLOR,
                                    ),
                                    Text(
                                      'ເຕີມເງິນ',
                                      style: TextStyle(
                                          color: UIHelper.SPOTIFY_COLOR,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: UIHelper.SPOTIFY_COLOR,
                                        width: 2.0)),
                                onPressed: () => {},
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(
                                      Icons.repeat,
                                      size: 25.0,
                                      color: UIHelper.SPOTIFY_COLOR,
                                    ),
                                    Text(
                                      'ຮັບເງິນ',
                                      style: TextStyle(
                                          color: UIHelper.SPOTIFY_COLOR,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.grey.shade50,
              width: _media.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 10, bottom: 20, top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "ໂອນເງິນດ່ວນ",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    height: screenAwareSize(
                        _media.longestSide <= 775 ? 110 : 83, context),
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                            // ignore: missing_return
                            onNotification: (overscroll) {
                              overscroll.disallowGlow();
                            },
                            child: historyListView()
//                                  buildHistory(),
                            ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                'ບໍລິການ',
                style: kTextStyle(16, FontWeight.w600),
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildServices(
                          text: 'ໂອນເງິນ',
                          image: Image.asset(
                            'assets/images/icons8-data_transfer.png',
                            color: UIHelper.SPOTIFY_COLOR,
                          ),
                          color: Color(0xFFE8EFFC),
                          route: '/transfer'),
                      _buildServices(
                          text: 'ຄ່າໂທລະສັບ',
                          image: Image.asset('assets/images/phone.png',
                              color: UIHelper.SPOTIFY_COLOR),
                          color: Color(0xFFE8EFFC),
                          route: '/recharge'),
                      _buildServices(
                          text: 'ທຸລະກຳ',
                          image: Image.asset('assets/images/transaction.png',
                              color: UIHelper.SPOTIFY_COLOR),
                          color: Color(0xFFE8EFFC),
                          route: '/transaction')
                    ],
                  ),
                ),
                //            Padding(
//              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  _buildServices(
//                      text: 'ຊື້ສິນຄ້າ',
//                      image: Image.asset(
//                          'assets/images/icons8-add_shopping_cart_filled.png'),
//                      color: Color(0xFFE8EFFC)),
//                  _buildServices(
//                      text: 'ປີ້ຍົນ',
//                      image: Image.asset('assets/images/icons8-airport.png'),
//                      color: Color(0xFFE8EFFC)),
//                  _buildServices(
//                      text: 'ປີ້ລົດ',
//                      image: Image.asset(
//                          'assets/images/icons8-double_decker_bus.png'),
//                      color: Color(0xFFE8EFFC)),
//                  _buildServices(
//                      text: 'ປີ້ໜັງ',
//                      image: Image.asset(
//                          'assets/images/icons8-hd_720p_filled.png'),
//                      color: Color(0xFFE8EFFC))
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  _buildServices(
//                      text: 'ໂຮງແຮມ',
//                      image:
//                      Image.asset('assets/images/icons8-3_star_hotel.png'),
//                      color: Color(0xFFE8EFFC)),
//                  _buildServices(
//                      text: 'ຈ່າຄ່ານໍ້າ',
//                      image: Image.asset(
//                          'assets/images/icons8-plumbing_filled.png'),
//                      color: Color(0xFFE8EFFC)),
//                  _buildServices(
//                      text: 'ຈ່າຍຄ່າໄຟ',
//                      image: Image.asset('assets/images/icons8-electrical.png'),
//                      color: Color(0xFFE8EFFC)),
//                  _buildServices(
//                      text: 'ທຸລະກຳ',
//                      image: Image.asset(
//                          'assets/images/icons8-transaction_list_filled.png'),
//                      color: Color(0xFFE8EFFC))
//                ],
//              ),
//            ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Center(
          child: Container(
              child: SizedBox.fromSize(
        size: Size(100, 100), // button width and height
        child: ClipOval(
          child: Material(
            color: UIHelper.SPOTIFY_COLOR, // button color
            child: InkWell(
              splashColor: Colors.green, // splash color
              onTap: () {
                unlockWallet(context);
              }, // button pressed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.lock_open,
                    color: UIHelper.WHITE,
                  ),
                  // icon
                  Text(
                    "ເປີດ",
                    style: TextStyle(color: UIHelper.WHITE),
                  ),
                  // text
                ],
              ),
            ),
          ),
        ),
      )));
    }
  }
}
