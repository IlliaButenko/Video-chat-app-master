import 'package:commons/commons.dart';
import 'package:flutter/material.dart';

class Alert {
  static error(BuildContext context, String title, String message, String buttonText, {Function action}) {
    return errorDialog(
        context,
        message,
        title: title,
        neutralText: buttonText,
        neutralAction: action
    );
  }

  static info(BuildContext context, String title, String message, String buttonText, {Function action}) {
    return infoDialog(
        context,
        message,
        title: title,
        neutralText: buttonText,
        neutralAction: action
    );
  }

  static warning(BuildContext context, String title, String message, String buttonText, {Function action}) {
    return warningDialog(
        context,
        message,
        title: title,
        neutralText: buttonText,
        neutralAction: action
    );
  }

  static success(BuildContext context, String title, String message, String buttonText, {Function action}) {
    return successDialog(
        context,
        message,
        title: title,
        neutralText: buttonText,
        neutralAction: action
    );
  }
}
