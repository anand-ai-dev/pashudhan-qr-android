/// Utility functions for safe JSON parsing in Flutter.
/// Prevents "type 'int' is not a subtype of type 'String'" and similar crashes.
class JsonParsers {
  /// Safely converts any dynamic value to a String.
  /// If the value is null, returns [defaultValue].
  static String parseString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely converts any dynamic value to an int.
  /// If the value is null or invalid, returns [defaultValue].
  static int parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely converts any dynamic value to a double.
  /// If the value is null or invalid, returns [defaultValue].
  static double parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely converts any dynamic value to a bool.
  /// If the value is null or invalid, returns [defaultValue].
  static bool parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final low = value.toLowerCase();
      if (low == 'true' || low == '1') return true;
      if (low == 'false' || low == '0') return false;
    }
    if (value is int) {
      return value == 1;
    }
    return defaultValue;
  }
}
