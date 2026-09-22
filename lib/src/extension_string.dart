/// @Describe: String 扩展类
///
/// @Author: LiWeNHuI
/// @Date: 2026/9/22

library;

extension StringExtension on String? {
  /// 是否为空
  bool get isBlank {
    if (this == null) return true;

    /// 去除所有空格
    final String replace = this!.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    return replace.isEmpty;
  }

  /// isNotBlank
  bool get isNotBlank => !isBlank;

  /// 空处理信息
  String? get value => isBlank ? null : this;
}
