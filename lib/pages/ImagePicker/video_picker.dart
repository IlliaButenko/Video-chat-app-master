import 'dart:io';

import 'package:OCWA/pages/open_settings.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/alert.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:OCWA/pages/const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class HybridVideoPicker extends StatefulWidget {
  HybridVideoPicker(
      {Key key,
      @required this.title,
      @required this.callback,
      this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;

  @override
  _HybridVideoPickerState createState() => new _HybridVideoPickerState();
}

class _HybridVideoPickerState extends State<HybridVideoPicker> {
  File _file;
  bool isLoading = false;
  ImagePicker picker = ImagePicker();
  VideoPlayerController _controller;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    pickVideo(ImageSource.gallery);
  }

  @override
  void dispose() {
    if (_controller != null)
      _controller.dispose();
    if (chewieController != null)
      chewieController.dispose();
    super.dispose();
  }

  void pickVideo(ImageSource captureMode) async {
    try {
      var pickedFile = await picker.getVideo(source: captureMode, maxDuration: const Duration(seconds: 120),);
      var videoFile = File(pickedFile.path);
      setState(() {
        _file = videoFile;
        int sizeInBytes = _file.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 100){
          // This file is Longer the
          Alert.warning(context, 'ຂະໜາດວີດີໂອໃຫຍ່ເກີນ', 'ຂະໜາດບໍ່ໃຫ້ເີນ 100MB', 'OK');
          _file = null;
        }
      });
      _controller = VideoPlayerController.network(_file.path)
        ..initialize().then((_) {
          setState(() {});
          chewieController = ChewieController(
              videoPlayerController: _controller,
              aspectRatio: _controller.value.aspectRatio,
              autoPlay: false,
              looping: false,
              autoInitialize: true);
        });
    } catch (e) {}
  }

  Widget _buildVideo() {
    if (_file != null) {
      return _controller.value.initialized
          ? Container(
              child: Chewie(
                controller: chewieController,
              ),
            )
          : CircularProgressIndicator();
    } else {
      return new Text('ເລືອກວີດີໂອກ່ອນ',
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
              widget.callback(_file).then((videoUrl) {
                Navigator.pop(context, videoUrl);
              });
            },
            child: Icon(Icons.check),
          ),
        ),
        backgroundColor: enigmaBlack,
        appBar: new AppBar(
            title: new Text(widget.title),
            backgroundColor: enigmaBlack,
            actions: _file != null
                ? <Widget>[
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            new Expanded(child: new Center(child: _buildVideo())),
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
              _buildActionButton(
                  new Key('retake'), Icons.photo_size_select_actual, () {
                OCWA.checkAndRequestPermission(Permission.storage).then((res) {
                  if (res) {
                    pickVideo(ImageSource.gallery);
                  } else {
                    OCWA.showRationale(
                        'Permission to access gallery needed to send photos to your friends.');
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings()));
                  }
                });
              }),
              _buildActionButton(new Key('upload'), Icons.photo_camera, () {
                OCWA.checkAndRequestPermission(Permission.camera).then((res) {
                  if (res) {
                    pickVideo(ImageSource.camera);
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
