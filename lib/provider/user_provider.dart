import 'package:OCWA/models/user_model.dart';
import 'package:OCWA/pages/chat/user.dart';
import 'package:OCWA/pages/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class UserProvider with ChangeNotifier {
  UserModel _user;

  UserModel get getUser => _user;

  Future<void> refreshUser() async {
    UserModel user = await getUserDetails();
    _user = user;
    notifyListeners();
  }

  Future<UserModel> getUserDetails() async {
    User currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot documentSnapshot =
    await FirebaseFirestore.instance.collection(USERS).doc(await services.getValue(PHONE)).get();
    return UserModel.fromJson(documentSnapshot.data());
  }

}
