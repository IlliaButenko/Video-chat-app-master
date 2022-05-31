import 'dart:io';

import 'package:OCWA/pages/open_settings.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:OCWA/pages/const.dart';
import 'package:permission_handler/permission_handler.dart';

class HybridCameraPicker extends StatefulWidget {
  HybridCameraPicker(
      {Key key,
        @required this.title,
        @required this.callback,
        this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;

  @override
  _HybridCameraPickerState createState() => new _HybridCameraPickerState();
}

class _HybridCameraPickerState extends State<HybridCameraPicker> {
  File _imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    captureImage(ImageSource.camera);
  }

  void captureImage(ImageSource captureMode) async {
    try {
      var imageFile = await ImagePicker.pickImage(source: captureMode);
      setState(() {
        _imageFile = imageFile;
      });
    } catch (e) {}
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return new Image.file(_imageFile);
    } else {
      return new Text('ເລືອກຮູບ ຫຼື ຖ່າຍຮູບ',
          style: new TextStyle(fontSize: 18.0, color: enigmaWhite));
    }
  }

  Future<Null> _cropImage() async {
    double x, y;
    if (widget.profile) {
      x = 1.0;
      y = 1.0;
    }
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
//        ratioX: x,
//        ratioY: y,
//        circleShape: widget.profile,
//        toolbarColor: Colors.white
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    setState(() {
      if (croppedFile != null) _imageFile = croppedFile;
    });
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
              widget.callback(_imageFile).then((imageUrl) {
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
            actions: _imageFile != null
                ? <Widget>[
              IconButton(
                  icon: Icon(Icons.edit, color: enigmaWhite),
                  disabledColor: Colors.transparent,
                  onPressed: () {
                    _cropImage();
                  }),
              SizedBox(
                width: 8.0,
              )
            ]
                : []),
        body: Stack(children: [
          new Column(children: [
            new Expanded(child: new Center(child: _buildImage())),
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
              _buildActionButton(new Key('upload'), Icons.photo_camera, () {
                OCWA.checkAndRequestPermission(Permission.camera).then((res) {
                  if (res) {
                    captureImage(ImageSource.camera);
                  } else {
                    OCWA.showRationale(
                        'Permission to access camera needed to take photos to share with your friends.');
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
