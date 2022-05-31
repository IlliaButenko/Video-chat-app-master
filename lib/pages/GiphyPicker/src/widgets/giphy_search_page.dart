import 'package:OCWA/pages/GiphyPicker/src/widgets/giphy_search_view.dart';
import 'package:OCWA/pages/const.dart';
import 'package:flutter/material.dart';

class GiphySearchPage extends StatelessWidget {
  final Widget title;

  const GiphySearchPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: EnigmaTheme,
        child: Scaffold(
            appBar: AppBar(title: Text('ຄົ້ນຫາພາບເຄື່ອນໄຫວ')),
            body: SafeArea(child: GiphySearchView(), bottom: false)));
  }
}
