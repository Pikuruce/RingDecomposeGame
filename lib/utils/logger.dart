import 'package:logger/logger.dart';

class AppLogger {
  // 2. 内部だけで保持する、唯一のプライベートインスタンス
  static final AppLogger _instance = AppLogger._internal();

  // 3. 外部で呼び出されるコンストラクタ（常に _instance を返す）
  factory AppLogger() => _instance;

  // 1. クラス内部だけでしか呼べないプライベートコンストラクタ（初期化処理）
  final Logger _logger;
  AppLogger._internal()
    : _logger = Logger(printer: PrettyPrinter(methodCount: 0, colors: true));

  // 4. 利用したいログレベルのメソッドをラップして公開
  void i(dynamic message) => _logger.i(message);
  void w(dynamic message) => _logger.w(message);
  void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) => _logger.e(message, error: error, stackTrace: stackTrace);
}
