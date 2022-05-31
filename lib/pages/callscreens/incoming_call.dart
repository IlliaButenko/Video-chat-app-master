import 'package:OCWA/models/call.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:system_alert_window/system_alert_window.dart';

class IncomingCall {
  static IncomingCall get instance => IncomingCall();
  bool _isShowingWindow = false;

  Future<void> showOverlayWindow(Call call) async {
    if (_isShowingWindow) {
      await SystemAlertWindow.closeSystemWindow();
      _isShowingWindow = false;
    }

    SystemWindowHeader header = SystemWindowHeader(
        title: SystemWindowText(
            text: 'ສາຍໂທເຂົ້າ', fontSize: 30, textColor: Colors.black45),
        padding: SystemWindowPadding.setSymmetricPadding(12, 12),
        subTitle: SystemWindowText(
            text: call.callerName,
            fontSize: 24,
            fontWeight: FontWeight.BOLD,
            textColor: Colors.black87),
        decoration: SystemWindowDecoration(startColor: UIHelper.MUZ_BACKGROUND_COLOR),
        button: SystemWindowButton(
            decoration: SystemWindowDecoration(
                startColor: UIHelper.SPOTIFY_COLOR,
                borderWidth: 0,
                borderRadius: 30.0),
            text: SystemWindowText(
                text: "OCWA", fontSize: 50, textColor: Colors.white),
            tag: "personal_btn"),
        buttonPosition: ButtonPosition.TRAILING);

    SystemWindowBody body = SystemWindowBody(
      rows: [],
      padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
    );

    SystemWindowFooter footer = SystemWindowFooter(
        buttons: [
          SystemWindowButton(
            text: SystemWindowText(
                text: "ບໍ່ຮັບສາຍ", fontSize: 18, textColor: Colors.white),
            tag: "reject_call",
            margin: SystemWindowMargin(right: 10),
            padding:
                SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
            width: 0,
            height: SystemWindowButton.WRAP_CONTENT,
            decoration: SystemWindowDecoration(
                startColor: Color.fromRGBO(247, 28, 88, 1),
                endColor: Color.fromRGBO(247, 28, 88, 1),
                borderWidth: 0,
                borderRadius: 30.0),
          ),
          SystemWindowButton(
            text: SystemWindowText(
                text: "ຮັບສາຍ", fontSize: 18, textColor: Colors.white),
            tag: "accept_call",
            width: 0,
            margin: SystemWindowMargin(left: 10),
            padding:
                SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
            height: SystemWindowButton.WRAP_CONTENT,
            decoration: SystemWindowDecoration(
                startColor: Color.fromRGBO(10, 139, 97, 1),
                endColor: Color.fromRGBO(10, 139, 97, 1),
                borderWidth: 0,
                borderRadius: 30.0),
          )
        ],
        padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
        decoration: SystemWindowDecoration(startColor: Colors.white),
        buttonsPosition: ButtonPosition.CENTER);
    SystemAlertWindow.showSystemWindow(
        height: 170,
        header: header,
        body: body,
        footer: footer,
        margin: SystemWindowMargin(left: 8, right: 8, top: 0, bottom: 0),
        gravity: SystemWindowGravity.TOP,
        notificationTitle: "ສາຍໂທເຂົ້າ",
        notificationBody: call.callerName);
    _isShowingWindow = true;
  }
}
