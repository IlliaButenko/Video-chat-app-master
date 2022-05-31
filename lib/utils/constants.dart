import 'package:flutter/cupertino.dart';

// Colors
Color appDarkGreyColor = Color.fromRGBO(58, 66, 86, 1.0);
Color appGreyColor = Color.fromRGBO(64, 75, 96, .9);

const kFond = Color(0xFFF9FBFF);
const kColorFont = Color(0xFF424242);
const kColorFontMoney = Color(0xFF45C232);
const kCardGradient_2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4A27F3),
      Color(0xFF4A27F3),
    ]
);
const kCardGradient_1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2CB488),
      Color(0xFF209D92),
    ]
);
const kCardGradient_3 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF6767),
      Color(0xFFFF8585),
    ]
);

kTextStyle(double size, FontWeight fontWeight){
  return TextStyle(
      color: kColorFont,
      fontSize: size,
      fontWeight: fontWeight
  );
}