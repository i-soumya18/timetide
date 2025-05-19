import 'dart:developer' as developer;

enum LogLevel {
  info,
  debug,
  warning,
  error,
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  LogLevel _currentLogLevel = LogLevel.info;

  set logLevel(LogLevel level) {
    _currentLogLevel = level;
  }

  void info(String message, {String? tag}) {
    if (_canLog(LogLevel.info)) {
      _log('INFO', message, tag: tag);
    }
  }

  void debug(String message, {String? tag}) {
    if (_canLog(LogLevel.debug)) {
      _log('DEBUG', message, tag: tag);
    }
  }

  void warning(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_canLog(LogLevel.warning)) {
      _log('WARNING', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_canLog(LogLevel.error)) {
      _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  bool _canLog(LogLevel level) {
    return level.index >= _currentLogLevel.index;
  }

  void _log(String level, String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final String logTag = tag ?? 'AITaskPlanner';
    final String timestamp = DateTime.now().toIso8601String();
    final String logMessage = '[$timestamp] $level ($logTag): $message';

    developer.log(
      logMessage,
      name: logTag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
