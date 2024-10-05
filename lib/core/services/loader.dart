import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Loader {
  Loader._();

  late BuildContext _context;
  late BuildContext _dismissingContext;
  Completer waitForLoader = Completer()..complete();

  static Loader _instance = Loader._();

  static Loader get instance => _instance;

  static void newInstance() => _instance = Loader._();
  static bool dialogShown = false;

  static Widget? loadingWidget;

  void setLoadingWidget(Widget widget) {
    loadingWidget = widget;
  }

  void hide() {
    if (!waitForLoader.isCompleted && dialogShown) {
      dialogShown = false;
      try {
        if (Navigator.of(_dismissingContext).canPop()) {
          Navigator.of(_dismissingContext).pop(true);
        }
      } catch (_) {}
    }
  }

  void show(BuildContext context) {
    _context = context;
    if (waitForLoader.isCompleted) {
      dialogShown = true;
      waitForLoader = Completer();
      showDialog<dynamic>(
        context: _context,
        barrierDismissible: kDebugMode,
        builder: (BuildContext context) {
          _dismissingContext = context;
          return PopScope(
            canPop: false,
            child: loadingWidget ?? const LoadingImage(),
          );
        },
      );
    }
  }
}

class LoadingImage extends StatefulWidget {
  const LoadingImage({super.key});

  @override
  State<LoadingImage> createState() => _LoadingImageState();
}

class _LoadingImageState extends State<LoadingImage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(child: Center(child: CircularProgressIndicator())),
    );
  }

  @override
  void dispose() {
    if (!Loader.instance.waitForLoader.isCompleted) {
      Loader.instance.waitForLoader.complete();
    }
    super.dispose();
  }
}
