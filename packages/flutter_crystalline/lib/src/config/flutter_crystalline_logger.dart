import 'dart:io';

import 'package:crystalline/crystalline.dart';
import 'package:flutter/foundation.dart';

class FlutterCrystallineLogger extends DefaultCrystallineLogger {
  @override
  String inBlinking(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inBlinking(object.toString());
    }
  }

  @override
  String inBlinkingFast(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inBlinkingFast(object.toString());
    }
  }

  @override
  String inCyan(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inCyan(object.toString());
    }
  }

  @override
  String inGreen(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inGreen(object.toString());
    }
  }

  @override
  String inMagenta(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inMagenta(object.toString());
    }
  }

  @override
  String inOrange(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inOrange(object.toString());
    }
  }

  @override
  String inRed(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inRed(object.toString());
    }
  }

  @override
  String inReset(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inReset(object.toString());
    }
  }

  @override
  String inWhite(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inWhite(object.toString());
    }
  }

  @override
  String inYellow(object) {
    if (!kIsWeb && Platform.isIOS) {
      return object.toString();
    } else {
      return super.inYellow(object.toString());
    }
  }

  @override
  String? globalLogFilter(Data<dynamic> data) => data.toString();
}
