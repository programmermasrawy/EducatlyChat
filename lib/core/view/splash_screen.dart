import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educalty_chat/core/constants/constants.dart';
import 'package:educalty_chat/features/authentication/login/view/screen/login_screen.dart';
import 'package:educalty_chat/features/authentication/singup/view/signup_screen.dart';
import 'package:educalty_chat/features/chat/view/chat_screen.dart';
import 'package:educalty_chat/features/home/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(3.seconds, () {
      var user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (_) => const LoginScreen()));
      } else {
        _loginScreen();
      }
    });
    super.initState();
  }

  Future<void> _loginScreen() async {
    final result = await checkUserExists(FirebaseAuth.instance.currentUser!.phoneNumber!);
    if (!result.$1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  Future<(bool checked, dynamic docs)> checkUserExists(String phone) async {
    try {
      final userQuery = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: phone).get();
      return (userQuery.docs.isNotEmpty, userQuery.docs.first);
    } catch (e) {
      Fluttertoast.showToast(msg: "You need to signup first");
      return (false, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                ChatAppColors.primaryColor,
                Colors.deepPurple,
                Colors.red,
              ], // Define your gradient colors here
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(const Rect.fromLTWH(0, 0, 300, 70));
          }, // Rectangle size for gradient
          child: Text(
            Constants.app_name,
            style: TextStyle(
              color: ChatAppColors.primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ).animate().fadeIn().scale().move(delay: 300.ms, duration: 600.ms),
      ),
    );
  }
}
