import 'package:data_connection_checker/data_connection_checker.dart';
import 'dart:async';

class NetworkCheck {
  static Future<bool> check() async {
    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      return true;
    } else {
      return false;
    }
  }

  static dynamic checkInternet(Function func) {
    check().then((internet) {
      if (internet != null && internet) {
        func(true);
      }
      else{
        func(false);
      }
    });
  }

}