import 'dart:convert';
import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class FirebaseLogger extends Logger {
  Future<String?> Function()? retrieveUserId;

  FirebaseLogger({this.retrieveUserId});

  @override
  void error({Type? module, required String message, StackTrace? stack}) {
    _log(severity: "error", module: module, message: message, stack: stack);
    if (kReleaseMode && isSendEnabled) {
      FirebaseCrashlytics.instance.recordError(message, stack);
    }
  }

  @override
  void warning({Type? module, required String message}) {
    _log(severity: "warn", module: module, message: message);
  }

  @override
  void info({Type? module, required String message}) {
    _log(severity: "info", module: module, message: message);
  }

  void _log({
    required String severity,
    Type? module,
    required String message,
    StackTrace? stack,
  }) async {
    Map<String, String?> object = {"severity": severity, "message": message};

    if (stack != null) {
      object["stack"] = stack.toString();
    }

    JsonEncoder formatter = const JsonEncoder.withIndent(' ');

    if (kDebugMode) {
      log(formatter.convert(object), name: '${module ?? ''}');
    } else if (!isSendEnabled) {
      String? uid = await retrieveUserId?.call();

      if (uid != null) {
        FirebaseCrashlytics.instance.setUserIdentifier(uid);
      }

      if (module != null) {
        object["module"] = module.toString();
      }

      FirebaseCrashlytics.instance.log(formatter.convert(object));
    }
  }

  @override
  void recordError(Object error, StackTrace stack) =>
      this.error(module: FirebaseLogger, message: '$error', stack: stack);

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  }) =>
      FirebaseCrashlytics.instance.recordFlutterError(
        flutterErrorDetails,
        fatal: fatal,
      );

  @override
  Future<void> enableSendReports(bool enabled) async {
    if (isSendEnabled) {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    }
  }

  @override
  bool get isSendEnabled =>
      FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;
}
