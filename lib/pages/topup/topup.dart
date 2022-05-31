import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/topup/card/card.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:OCWA/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:OCWA/ui/ui_helper.dart';

class TopUp extends StatefulWidget {
  @override
  _TopUpState createState() => _TopUpState();
}

class _TopUpState extends State<TopUp> {
  bool _canSave = false;
  List<UserModel> _data = new List<UserModel>();

  void _setCanSave(bool save) {
    if (save != _canSave) setState(() => _canSave = save);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('ເພີ່ມເງິນເຂົ້າກະເປົາ',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w300,
              )),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: ListView(
            children: <Widget>[
              Container(
                height: 100,
                margin: EdgeInsets.only(bottom: 2),
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  onTap: () {
                    Alert.info(context, 'ແຈ້ງເຕືອນ', 'ເຕີມດ້ວຍບັນຊີທະນາຄານຈະເປີດໃຫ້ບໍລິການໃນໄວໆນີ້', "OK");
                  },
                  leading: Container(
                    height: 60,
                    width: 60,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: UIHelper.SPOTIFY_COLOR, shape: BoxShape.circle),
                    child: Image.asset('assets/images/icons8-library_filled.png'),
                  ),
                  title: Text(
                    'ດ້ວຍບັນຊີທະນາຄານ',
                    style: TextStyle(
                        color: UIHelper.SPOTIFY_COLOR,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  )
                ),
              ),
              Container(
                height: 100,
                margin: EdgeInsets.only(bottom: 2),
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: UIHelper.PINEAPPLE_SECONDARY_COLOR,
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CardTopup()));
                  },
                  leading: Container(
                    height: 60,
                    width: 60,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: UIHelper.SPOTIFY_COLOR, shape: BoxShape.circle),
                    child: Image.asset('assets/images/icons8-card_exchange.png'),
                  ),
                  title: Text(
                    'ດ້ວຍບັດໂທລະສັບ',
                    style: TextStyle(
                      color: UIHelper.SPOTIFY_COLOR,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                  )
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildHistory(int index) {
    return Container(
      height: 100,
      margin: EdgeInsets.only(bottom: 2),
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          height: 60,
          width: 60,
          padding: EdgeInsets.all(12),
          decoration:
              BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          child: Image.asset('assets/images/greg.jpg'),
        ),
        title: Text(
          'ຜ່ານທະນາຄານ',
          style: kTextStyle(18, FontWeight.w600),
        ),
        subtitle: Text(
          _data[index].phone,
          style: TextStyle(
              color: UIHelper.SPOTIFY_COLOR,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        trailing: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            '',
            style: TextStyle(
                color: kColorFontMoney,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
