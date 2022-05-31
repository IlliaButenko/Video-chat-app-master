import 'package:OCWA/pages/open_settings.dart';
import 'package:OCWA/pages/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:progress_dialog/progress_dialog.dart';

class FullPhoto extends StatefulWidget {
  final String url;
  final ImageProvider imageProvider;
  FullPhoto({Key key,@required this.url, this.imageProvider}) : super(key: key);
  @override State createState() => new _FullPhoto();
}

class _FullPhoto extends State<FullPhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          OCWA.checkAndRequestPermission(Permission.storage)
              .then((res) {
            if (res) {
              _saveNetworkImage(context);
            } else {
              OCWA.showRationale(
                  'Permission to access storage needed to save photos to your phone.');
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => OpenSettings()));
            }
          });
        },
        child: Icon(Icons.file_download),
      ),
      body: GestureDetector(
        child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: CachedNetworkImageProvider(widget.url),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 1.5,
                    );
                  },
                  itemCount: 1,
                  loadingChild: Center(
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                      ),
                    ),
                  ),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.black,
                  ),
                ),
              ],
            )
        ),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _saveNetworkImage(BuildContext context) async {
    final ProgressDialog pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
        showLogs: false);
    pr.show();
    pr.update(message: 'ກຳລັງດາວໂຫລດ');
//    GallerySaver.saveImage(widget.url).then((bool success) {
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
//      OCWA.toast(error);
//      pr.hide();
//    });
  }
}