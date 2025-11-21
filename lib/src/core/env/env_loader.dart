import 'dart:io';

/// Lightweight environment loader.
/// Priority: Platform.environment -> .env file in project root.
class EnvLoader {
  EnvLoader({this.envFilePath = '.env'});

  final String envFilePath;
  Map<String, String>? _cache;

  String? get(String key) {
    final fromPlatform = Platform.environment[key];
    if (fromPlatform != null && fromPlatform.isNotEmpty) return fromPlatform;
    final map = _cache ??= _readEnv();
    return map[key];
  }

  Map<String, String> _readEnv() {
    final file = File(envFilePath);
    if (!file.existsSync()) return {};
    final map = <String, String>{};
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx == -1) continue;
      final key = trimmed.substring(0, idx).trim();
      final value = trimmed.substring(idx + 1).trim();
      map[key] = value;
    }
    return map;
  }
}
