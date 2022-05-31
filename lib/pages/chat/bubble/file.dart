import 'dart:io';

import 'package:OCWA/pages/configs/Palette.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class FileBubble extends StatelessWidget {
  bool isSelf;
  String url;
  FileBubble(this.url, this.isSelf);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Container(
                width: 130,
                color: Palette.secondaryColor,
                height: 80,
              ),
              Column(
                children: <Widget>[
                  Icon(
                    Icons.insert_drive_file,
                    color: Palette.primaryColor,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'ເອກະສານ',
                    style: TextStyle(
                        fontSize: 20,
                        color: isSelf
                            ? Palette.selfMessageColor
                            : Palette.otherMessageColor),
                  ),
                ],
              ),
            ],
          ),
          Container(
              height: 40,
              child: IconButton(
                  icon: Icon(
                    Icons.file_download,
                    color: isSelf
                        ? Palette.selfMessageColor
                        : Palette.otherMessageColor,
                  ),
                  onPressed: () => downloadFile(url)))
        ],
      ),
    );
  }

  downloadFile(String fileUrl) async {
    print(fileUrl);
    final Directory downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    final String downloadsPath = downloadsDirectory.path;
    await FlutterDownloader.enqueue(
      url: fileUrl,
      savedDir: downloadsPath,
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
  }
}
