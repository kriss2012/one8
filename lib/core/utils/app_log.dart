import 'dart:developer' as dev;

/// Namespaced logger for the ONE8 image compression pipeline.
/// Output appears in the Flutter run terminal and in Android logcat.
///
/// Usage:
///   AppLog.info('Bridge', 'RustLib initialized successfully');
///   AppLog.warn('DataSource', 'Falling back to raster engine for image.jpg');
///   AppLog.error('Controller', 'Stream error', error: e);
abstract class AppLog {
  static void info(String tag, String message) {
    dev.log('[INFO]  [$tag] $message', name: 'one8');
  }

  static void warn(String tag, String message) {
    dev.log('[WARN]  [$tag] $message', name: 'one8');
  }

  static void error(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(
      '[ERROR] [$tag] $message${error != null ? ' | $error' : ''}',
      name: 'one8',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String tag, String message) {
    dev.log('[DEBUG] [$tag] $message', name: 'one8');
  }
}
