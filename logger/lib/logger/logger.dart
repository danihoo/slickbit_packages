import 'package:flutter/foundation.dart';

abstract class Logger {
  void error({Type? module, required String message, StackTrace? stack});

  void warning({Type? module, required String message});

  void info({Type? module, required String message});

  void recordError(Object error, StackTrace stack);

  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  });

  Future<void> enableSendReports(bool enabled);

  bool get isSendEnabled;
}
