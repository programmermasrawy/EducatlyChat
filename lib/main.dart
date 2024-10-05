import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educalty_chat/core/view/splash_screen.dart';
import 'package:educalty_chat/features/chat/logic/chat_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/constants.dart';
import 'core/services/firebase_fcm_service.dart';
import 'di/injection_container.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp firebaseApp = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('firebaseApp.options.projectId');
  debugPrint(firebaseApp.options.projectId);
  initDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => ChatBloc(
                  firestore: FirebaseFirestore.instance,
                  notificationService: FCMNotificationService(),
                )),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ChatAppColors.primaryColor),
          buttonTheme: ButtonThemeData(
            buttonColor: ChatAppColors.primaryColor,
            textTheme: ButtonTextTheme.primary,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: ChatAppColors.primaryColor,
            ),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: ChatAppColors.black,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: ChatAppColors.primaryColor,
            // Background color for TextFormField
            focusColor: ChatAppColors.primaryColor,
            labelStyle: const TextStyle(color: Colors.white),
            // Label text color
            hintStyle: const TextStyle(color: Colors.white70),
            // Hint text color
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ChatAppColors.primaryColor), // Border color when not focused
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white), // Border color when focused
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: ChatAppColors.primaryColor), // Default border
            ),
          ),
          secondaryHeaderColor: Colors.white,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
