import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class LoginRepo {
  static Future<String> getToken() async {
    final rp = await FirebaseAuth.instance.currentUser!.getIdToken(true);
    return rp!;
  }

  static Future<String?> getFCMToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log(fcmToken?.toString() ?? '');
    return fcmToken;
  }

  static Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    return;
  }
}
