import 'package:OCWA/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:OCWA/models/call.dart';
import 'package:OCWA/resources/call_methods.dart';
import 'package:OCWA/pages/callscreens/pickup/pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    @required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
      stream: callMethods.callStream(uid: userProvider.getUser.phone),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.data() != null) {
          Call call = Call.fromMap(snapshot.data.data());
          if (!call.hasDialled) {
            return PickupScreen(call: call);
          }
        }
        return this.scaffold;
      },
    )
        : Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
