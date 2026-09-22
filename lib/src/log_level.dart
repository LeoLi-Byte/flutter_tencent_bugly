/// @Describe: 日志等级
///
/// @Author: LiWeNHuI
/// @Date: 2026/9/22

library;

enum LogLevel {
  ERROR(1),
  WARN(2),
  INFO(3),
  DEBUG(4),
  VERBOSE(5);

  const LogLevel(this.key);

  /// 标识位
  final int key;
}
