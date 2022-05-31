import 'package:OCWA/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class Cards{
  String balance;
  String logo;
  String pin;
  String holder;
  String expires;
  LinearGradient linearGradient;
  double size;

  Cards({this.balance, this.logo, this.pin, this.holder, this.expires, this.linearGradient, this.size});

}

final List<Cards> cards = [
  Cards(
      balance: '10,550',
      logo: 'assets/images/visa_logo.png',
      pin: '1289',
      holder: 'JAVOHIR ERGASHEV',
      expires: '02/23',
      linearGradient: kCardGradient_1,
      size: 18
  ),
  Cards(
      balance: '18,240',
      logo: 'assets/images/visa_logo.png',
      pin: '4293',
      holder: 'JAVOHIR ERGASHEV',
      expires: '09/24',
      linearGradient: kCardGradient_2,
      size: 18
  ),
  Cards(
      balance: '25,000',
      logo: 'assets/images/masterCard_logo.png',
      pin: '2571',
      holder: 'JAVOHIR ERGASHEV',
      expires: '04/22',
      linearGradient: kCardGradient_3,
      size: 22
  ),
];

class Transactions{
  String name;
  String pay;
  String price;
  String icUrl;
  Color color;

  Transactions({this.name, this.pay, this.price, this.icUrl, this.color});

}

final List<Transactions> trans = [
  Transactions(
    name: 'ໂອນເງິນອອກ',
    pay: 'Payment',
    price: '-\$45',
    icUrl: 'assets/images/dribble_logo.png',
    color: Color(0xFFFFE9EF),
  ),
  Transactions(
    name: 'ໄດ້ຮັບເງິນໂອນ',
    pay: 'Payment',
    price: '+\$163',
    icUrl: 'assets/images/spotify_logo.png',
    color: Color(0xFFE2FBED),
  ),
  Transactions(
    name: 'ຊຳລະສິນຄ້າ',
    pay: 'Payment',
    price: '-\$15',
    icUrl: 'assets/images/netflix_logo.png',
    color: Color(0xFFE9E9E9),
  ),
  Transactions(
    name: 'ຈ່າຍຄ່າໂທລະສັບ',
    pay: 'Payment',
    price: '-\$35',
    icUrl: 'assets/images/uber_logo.png',
    color: Color(0xFFE9E9E9),
  ),
  Transactions(
    name: 'ຈ່າຍຄ່າໂທລະສັບ',
    pay: 'Payment',
    price: '-\$45',
    icUrl: 'assets/images/dribble_logo.png',
    color: Color(0xFFFFE9EF),
  ),
  Transactions(
    name: 'ໄດ້ຮັບເງິນໂອນ',
    pay: 'Payment',
    price: '+\$163',
    icUrl: 'assets/images/spotify_logo.png',
    color: Color(0xFFE2FBED),
  ),
  Transactions(
    name: 'ຊຳລະສິນຄ້າ',
    pay: 'Payment',
    price: '-\$15',
    icUrl: 'assets/images/netflix_logo.png',
    color: Color(0xFFE9E9E9),
  ),
  Transactions(
    name: 'ຈ່າຍຄ່າໂທລະສັບ',
    pay: 'Payment',
    price: '-\$35',
    icUrl: 'assets/images/uber_logo.png',
    color: Color(0xFFE9E9E9),
  ),
];