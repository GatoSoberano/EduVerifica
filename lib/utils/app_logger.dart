import 'package:flutter/foundation.dart';

/// Logger centralizado. Solo imprime en modo debug.
/// Uso: AppLogger.d('mensaje'), AppLogger.e('error', error: e)
class AppLogger {
  AppLogger._();

  static void d(String message) {
    if (kDebugMode) debugPrint('🐛 [DEBUG] $message');
  }

  static void i(String message) {
    if (kDebugMode) debugPrint('ℹ️  [INFO]  $message');
  }

  static void w(String message) {
    if (kDebugMode) debugPrint('⚠️  [WARN]  $message');
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) debugPrint('   Causa: $error');
      if (stackTrace != null) debugPrint('   Stack: $stackTrace');
    }
  }
}