import 'package:OCWA/pages/const.dart';
import 'package:OCWA/pages/open_settings.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_player/video_player.dart';

class VideoBox extends StatefulWidget {
  String Video;
  VideoBox(this.Video);
  @override
  _VideoBoxState createState() => _VideoBoxState(Video);
}

class _VideoBoxState extends State<VideoBox> {
  String url;
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  _VideoBoxState(this.url);
  Future<void> _future;

  @override
  void initState(){
    super.initState();
    videoPlayerController = VideoPlayerController.network(url);
    _future = initVideoPlayer();
  }

  Future<void> initVideoPlayer() async{
    await videoPlayerController.initialize();
    setState(() {
      chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          aspectRatio: videoPlayerController.value.aspectRatio,
          autoPlay: true,
          looping: false,
          placeholder: buildPlaceholderImage()
      );
    });
  }

  buildPlaceholderImage(){
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    if (videoPlayerController != null)
      videoPlayerController.dispose();
    if (chewieController != null)
      chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 80.0,
                right: 10.0,
                child: FloatingActionButton(
                  heroTag: 'save',
                  onPressed: () {
                    _saveNetworkVideo();
                  },
                  child: Icon(Icons.save),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              Positioned(
                bottom: 10.0,
                right: 10.0,
                child: FloatingActionButton(
                  backgroundColor: Colors.red[300],
                  heroTag: 'close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: enigmaBlack,
        appBar: new AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) return buildPlaceholderImage();

            return Center(
              child: Chewie(controller: chewieController,),
            );
          },
        )
    );
  }

  void _saveNetworkVideo() async {
    final ProgressDialog pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
        showLogs: false);
    pr.show();
    pr.update(message: 'ກຳລັງດາວໂຫລດ');
//    GallerySaver.saveVideo(widget.Video).then((bool success) {
//      setState(() {
//        if (success) {
//          OCWA.toast('ບັນທຶກແລ້ວ');
//          pr.hide();
//        } else {
//          OCWA.toast('ບັນທຶກບໍ່ສຳເລັດ');
//          pr.hide();
//        }
//      });
//    }).catchError((error) {
//      print(error);
//      pr.hide();
//    });
  }
}