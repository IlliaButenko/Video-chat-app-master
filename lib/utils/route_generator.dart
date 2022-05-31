import 'package:OCWA/models/wallet_model.dart';
import 'package:OCWA/pages/home.dart';
import 'package:OCWA/pages/loading.dart';
import 'package:OCWA/pages/login/login.dart';
import 'package:OCWA/pages/recharge/recharge.dart';
import 'package:OCWA/pages/topup/topup.dart';
import 'package:OCWA/pages/transaction/transaction.dart';
import 'package:OCWA/pages/transfer/transfer.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Home());
      case '/loading':
        return MaterialPageRoute(builder: (_) => Loading());
      case '/topup':
      // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TopUp(
            ),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      case '/transfer':
      // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => Transfer(
            ),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      case '/recharge':
      // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => Recharge(
            ),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      case '/transaction':
      // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TransactionScreen(
            ),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      case '/login':
      // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => Login(
            ),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      default:
      // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}