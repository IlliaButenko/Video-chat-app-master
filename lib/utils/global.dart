import 'dart:convert';

import 'package:OCWA/models/general_model.dart';
import 'package:OCWA/models/user_model.dart';
import 'package:intl/intl.dart';

class Global {
  static final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
  static String phonePrefix = "85620";
  static List<int> _startWith = [2, 5, 7, 9];
  static UserModel userModel;
  static dynamic wallet;
  static List<TransferHistoryModel> historyModel;
  static bool enableWallet;
  static String profileUrl;

  static String firePhone(String phone) {
    return "+" + getPhone(phone);
  }

  static String getPhone(String phone) {
    if (phone.startsWith("020")) {
      return phonePrefix + phone.substring(3);
    } else if (phone.startsWith("85620")) {
      return phone;
    } else if (phone.startsWith("20")) {
      if (phone.length == 8) {
        return phonePrefix + phone;
      } else {
        return phonePrefix + phone.substring(2);
      }
    } else if (phone.startsWith("2") ||
        phone.startsWith("5") ||
        phone.startsWith("7") ||
        phone.startsWith("9")) {
      if (phone.length == 8) {
        return phonePrefix + phone;
      } else {
        return phonePrefix + phone.substring(2);
      }
    }
    return phone;
  }

  static bool validatePhone(String phone) {
    if (!checkPhone(phone)) {
      if (phone.startsWith("20")) {
        return phone.length == 8
            ? startWiths(phone)
            : phone.length == 10 ? startWiths(phone.substring(2)) : checkPhone(phone);
      } else if (phone.startsWith("020")) {
        return phone.length == 11 ? checkPhone(phone) : false;
      } else if (phone.startsWith("85620")) {
        return phone.length == 13 ? checkPhone(phone) : false;
      } else if (phone.length != 8 ||
          phone.length != 11 ||
          phone.length != 13) {
        return false;
      } else {
        return checkPhone(phone);
      }
    } else {
      return true;
    }
  }

  static bool checkPhone(String phone) {
    if (phone.length == 8) {
      return startWiths(phone);
    } else if (phone.length == 10) {
      return phone.startsWith("20") ? startWiths(phone.substring(2)) : false;
    } else if (phone.length == 11) {
      return phone.startsWith("020") ? startWiths(phone.substring(3)) : false;
    } else if (phone.length == 13) {
      return phone.startsWith("85620") ? startWiths(phone.substring(5)) : false;
    } else {
      return false;
    }
  }

  static bool startWiths(String phone) {
    final data = int.parse(phone.substring(0, 1));
    for (var i = 0; i < _startWith.length; i++) {
      if (_startWith[i] == data) {
        return true;
      }
    }
    return false;
  }

  static int getStartWith(String phone) {
    final data = int.parse(phone.substring(0, 1));
    for (var i = 0; i < _startWith.length; i++) {
      if (_startWith[i] == data) {
        return _startWith[i];
      }
    }
    return 0;
  }

  static String showPhone(String phone) {
    return getPhone(phone).substring(3);
  }

  static String displayPhone(String phone) {
    return '0' + getPhone(phone).substring(3);
  }

  static double toNumber(String num) {
    return double.parse(num.replaceAll(",", ""));
  }

  static String formatDate(String date) {
    DateTime tempDate = DateTime.parse(date);
    return new DateFormat('dd/MM/yyyy HH:mm:ss').format(tempDate);
  }

  static String dateOnly(String date) {
    DateTime tempDate = DateTime.parse(date);
    return new DateFormat('dd/MM/yyyy').format(tempDate);
  }

  static String timeAndSec(String date) {
    DateTime tempDate = DateTime.parse(date);
    return new DateFormat('HH:mm:ss').format(tempDate);
  }

  static String timeOnly(String date) {
    DateTime tempDate = DateTime.parse(date);
    return new DateFormat('HH:mm').format(tempDate);
  }

  static double removeDecimalZeroFormat(int n) {
    return double.parse(n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1));
  }

  static String getPhoneType(int type) {
    if (type == 0) {
      return 'ເບີມືຖືລາຍເດືອນ';
    }
    if (type == 1) {
      return 'ໂທລະສັບຕັ້ງໂຕະ';
    }
    if (type == 2) {
      return 'ອິນເຕີເນັດ';
    }
    if (type == 3) {
      return 'ເບີມືຖືແບບເຕີມເງິນ';
    }
  }
}
