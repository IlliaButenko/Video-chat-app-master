import 'dart:io';

import 'package:OCWA/pages/configs/Palette.dart';
import 'package:OCWA/pages/open_settings.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:OCWA/pages/const.dart';
import 'package:permission_handler/permission_handler.dart';

class HybridFilePicker extends StatefulWidget {
  HybridFilePicker(
      {Key key,
        @required this.title,
        @required this.callback,
        this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;

  @override
  _HybridFilePickerState createState() => new _HybridFilePickerState();
}

class _HybridFilePickerState extends State<HybridFilePicker> {
  File _file;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pickFile();
  }

  void pickFile() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls', 'pptx', 'ppt', 'txt',],);
      if(result != null) {
        print('good');
        setState(() {
          _file = File(result.files.single.path);
          int sizeInBytes = _file.lengthSync();
          double sizeInMb = sizeInBytes / (1024 * 1024);
          if (sizeInMb > 10){
            Alert.warning(context, 'ຂະໜາດເອກະສານໃຫຍ່ເກີນ', 'ຂະໜາດບໍ່ໃຫ້ເີນ 10MB', 'OK');
            _file = null;
          }
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {}
  }

  Widget _buildFile() {
    if (_file != null) {
      print(_file.path);
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 150,
            color: Palette.secondaryColor,
            height: 180,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Icon(
                  Icons.insert_drive_file,
                  color: Palette.primaryColor,
                  size: 50,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'ໄດ້ເລືອກເອກະສານແລ້ວ',
                  style: TextStyle(
                      fontSize: 20,
                      color: Palette.selfMessageColor
                  ),
                ),
              ],
            ),
          ),

        ],
      );
    } else {
      return new Text('ເລືອກເອກະສານ',
          style: new TextStyle(fontSize: 18.0, color: enigmaWhite));
    }
  }

  @override
  Widget build(BuildContext context) {
    return OCWA.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              widget.callback(_file).then((imageUrl) {
                Navigator.pop(context, imageUrl);
              });
            },
            child: Icon(Icons.check),
          ),
        ),
        backgroundColor: enigmaBlack,
        appBar: new AppBar(
            title: new Text(widget.title),
            backgroundColor: enigmaBlack,
        ),
        body: Stack(children: [
          new Column(children: [
            new Expanded(child: new Center(child: _buildFile())),
            _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(enigmaBlue)),
              ),
              color: enigmaBlack.withOpacity(0.8),
            )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  Widget _buildButtons() {
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 60.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(new Key('upload'), Icons.insert_drive_file, () {
                OCWA.checkAndRequestPermission(Permission.storage).then((res) {
                  if (res) {
                    pickFile();
                  } else {
                    OCWA.showRationale(
                        'Permission to access storage needed to select file to send to your friends.');
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings()));
                  }
                });
              }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return new Expanded(
      child: new RaisedButton(
          key: key,
          child: Icon(icon, size: 30.0),
          shape: new RoundedRectangleBorder(),
          color: UIHelper.THEME_DARK,
          textColor: enigmaWhite,
          onPressed: onPressed),
    );
  }
}
