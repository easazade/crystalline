import 'dart:io';

import 'package:crystalline/crystalline.dart';
import 'package:flutter/foundation.dart';

class FlutterCrystallineLogger extends DefaultCrystallineLogger {
  @override
  String cyanText(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.cyanText(object.toString());
    }
  }

  @override
  String greenText(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.greenText(object.toString());
    }
  }

  @override
  String magentaText(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.magentaText(object.toString());
    }
  }

  @override
  String orangeText(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.orangeText(object.toString());
    }
  }

  @override
  String redText(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.redText(object.toString());
    }
  }

  @override
  String resetTextColors(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.resetTextColors(object.toString());
    }
  }

  @override
  String whiteText(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.whiteText(object.toString());
    }
  }

  @override
  String whiteTextRedBg(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.cyanText(object.toString());
    }
  }

  @override
  String whiteTextBlueBg(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.cyanText(object.toString());
    }
  }

  @override
  String yellowText(dynamic object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.yellowText(object.toString());
    }
  }
}
