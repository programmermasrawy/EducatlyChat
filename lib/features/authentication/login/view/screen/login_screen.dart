import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educalty_chat/core/constants/constants.dart';
import 'package:educalty_chat/core/services/loader.dart';
import 'package:educalty_chat/core/view/widgets/phone_number.dart';
import 'package:educalty_chat/di/injection_container.dart';
import 'package:educalty_chat/features/authentication/singup/view/signup_screen.dart';
import 'package:educalty_chat/features/chat/view/chat_screen.dart';
import 'package:educalty_chat/features/home/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../logic/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  static const id = "/auth_gate";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<LoginCubit>(),
      child: const _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatefulWidget {
  const _LoginScreenBody();

  @override
  createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<_LoginScreenBody> {
  TextEditingController phone = TextEditingController();
  TextEditingController code = TextEditingController();
  final phoneFocus = FocusNode();
  final otpFocus = FocusNode();
  late Country _country;
  final _key = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _country = countries.firstWhere((c) => c.code == "EG");
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginCubit, LoginState>(
          listenWhen: (previous, current) => previous.loading != current.loading,
          listener: (context, state) {
            state.loading ? Loader.instance.show(context) : Loader.instance.hide();

            if (state.statusCode == 200) {
              _loginScreen();
            }
          },
        ),
        BlocListener<LoginCubit, LoginState>(
            listenWhen: (previous, current) => previous.statusCode != current.statusCode,
            listener: (context, state) {
              state.loading ? Loader.instance.show(context) : Loader.instance.hide();
              if (state.statusCode == 200) {
                // Alert.instance.success(context, "Success Logged In");
              }
            }),
        BlocListener<LoginCubit, LoginState>(
            listenWhen: (previous, current) => previous.otpVisibility != current.otpVisibility,
            listener: (context, state) {
              state.otpVisibility ? otpFocus.requestFocus() : otpFocus.unfocus();
            }),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 0,
        ),
        body: BlocBuilder<LoginCubit, LoginState>(builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Phone Number",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  // Phone Number Input
                  PhoneNumberWidget(
                    country: _country,
                    phone: phone,
                    onCountryChanged: (country) {
                      _country = country;
                    },
                    onChangePhone: (phone) {
                      if (context.read<LoginCubit>().state.otpVisibility) {
                        code.clear();
                        context.read<LoginCubit>().changePhone();
                      }
                    },
                    onSubmitPhone: (phone) => _confirm(),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _confirm(),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // OTP Section
                  if (context.read<LoginCubit>().state.otpVisibility)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Enter Code Here",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: PinCodeTextField(
                            length: 6,
                            autoDisposeControllers: false,
                            key: _key,
                            cursorColor: ChatAppColors.primaryColor,
                            animationType: AnimationType.scale,
                            useExternalAutoFillGroup: true,
                            autoFocus: true,
                            focusNode: otpFocus,
                            keyboardType: TextInputType.number,
                            backgroundColor: ChatAppColors.black,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              disabledColor: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(12),
                              activeColor: ChatAppColors.primaryColor,
                              borderWidth: 1,
                              inactiveFillColor: ChatAppColors.lightColor,
                              inactiveColor: ChatAppColors.lightColor,
                              selectedColor: ChatAppColors.lightColor,
                              selectedFillColor: ChatAppColors.black,
                              activeFillColor: ChatAppColors.primaryColor,
                            ),
                            enablePinAutofill: true,
                            animationDuration: const Duration(milliseconds: 300),
                            controller: code,
                            textStyle: TextStyle(
                              color: ChatAppColors.lightColor,
                              fontWeight: FontWeight.w500,
                            ),
                            enableActiveFill: true,
                            onCompleted: (v) {
                              context.read<LoginCubit>().firebaseAuth(otp: v, context: context);
                            },
                            beforeTextPaste: (text) {
                              return true;
                            },
                            appContext: context,
                            onChanged: (String value) {},
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: InkWell(
                            onTap: () {
                              context
                                  .read<LoginCubit>()
                                  .sendOtp(phone: "+${_country.dialCode}${phone.text}", resend: true);
                            },
                            child: const Text(
                              "Resend Code",
                              style: TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _confirm() {
    if (_formKey.currentState!.validate()) {
      if (phone.text.isEmpty) {
        Fluttertoast.showToast(msg: "Invalid Phone Number");
        return;
      }
      context.read<LoginCubit>().sendOtp(phone: "+${_country.dialCode}${phone.text}");
    }
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
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
}
