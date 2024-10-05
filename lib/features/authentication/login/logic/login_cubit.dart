import 'package:educalty_chat/features/authentication/login/data/repo/login_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo repo;
  String? verificationID = "";

  LoginCubit(this.repo) : super(InitialFirebaseState());

  Future<void> sendOtp({String? phone, bool resend = false}) async {
    if (!resend) {
      emit(state.requestLoading());
    }
    FirebaseAuth.instance.signOut();

    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == "network-request-failed") {
            emit(state.networkFailure());
          } else {
            emitError(e.toString());
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint("Firebase transAction $verificationId");
          verificationID = verificationId;
          emit(state.requestOtpInput(verificationID: verificationId));
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  Future<void> firebaseAuth({String? otp, BuildContext? context}) async {
    emit(state.requestLoading());
    try {
      User? user;
      debugPrint("Firebase transAction $verificationID");

      final PhoneAuthCredential credential =
          PhoneAuthProvider.credential(verificationId: verificationID ?? "", smsCode: otp!);
      await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
        debugPrint("Firebase transAction$value");
        user = FirebaseAuth.instance.currentUser;
      }, onError: (e) {
        if (e.code == "network-request-failed") {
          emit(state.networkFailure());
        }
      }).whenComplete(
        () async {
          if (user != null) {
            emit(state.requestSuccess(statusCode: 200, message: ''));

            String? token = await _getToken();
            debugPrint(token);
          } else {
            emitError("Error Happened");
          }
        },
      );
    } catch (e) {
      emitError(e.toString());
    }
  }

  void changePhone() {
    emit(state.copyWith(otpVisibility: false));
  }

  emitError(String? message) {
    debugPrint(message!);
    debugPrint("mahmoud");
    Fluttertoast.showToast(msg: message!);
    emit(state.requestFailed());
  }

  Future<String?> _getToken() async {
    String? token = await FirebaseAuth.instance.currentUser!.getIdToken(false);
    return token;
  }
}
