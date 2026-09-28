import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/core/json_parsers.dart';

void main() {
  group('JsonParsers.parseString', () {
    test('returns empty string for null', () {
      expect(JsonParsers.parseString(null), '');
    });

    test('returns custom default for null', () {
      expect(JsonParsers.parseString(null, 'N/A'), 'N/A');
    });

    test('converts int to string', () {
      expect(JsonParsers.parseString(42), '42');
    });

    test('converts double to string', () {
      expect(JsonParsers.parseString(3.14), '3.14');
    });

    test('returns string as-is', () {
      expect(JsonParsers.parseString('hello'), 'hello');
    });

    test('converts bool true to string', () {
      expect(JsonParsers.parseString(true), 'true');
    });

    test('converts bool false to string', () {
      expect(JsonParsers.parseString(false), 'false');
    });

    test('returns empty string for empty string input', () {
      expect(JsonParsers.parseString(''), '');
    });
  });

  group('JsonParsers.parseInt', () {
    test('returns 0 for null', () {
      expect(JsonParsers.parseInt(null), 0);
    });

    test('returns custom default for null', () {
      expect(JsonParsers.parseInt(null, -1), -1);
    });

    test('returns int as-is', () {
      expect(JsonParsers.parseInt(5), 5);
    });

    test('parses valid positive int string', () {
      expect(JsonParsers.parseInt('7'), 7);
    });

    test('parses valid negative int string', () {
      expect(JsonParsers.parseInt('-10'), -10);
    });

    test('parses zero string', () {
      expect(JsonParsers.parseInt('0'), 0);
    });

    test('returns default for alphabetic string', () {
      expect(JsonParsers.parseInt('abc'), 0);
    });

    test('returns default for empty string', () {
      expect(JsonParsers.parseInt(''), 0);
    });

    test('returns default for double value', () {
      // double is not int or String, so falls through to default
      expect(JsonParsers.parseInt(3.7), 0);
    });

    test('returns custom default for invalid string', () {
      expect(JsonParsers.parseInt('bad', 99), 99);
    });
  });

  group('JsonParsers.parseDouble', () {
    test('returns 0.0 for null', () {
      expect(JsonParsers.parseDouble(null), 0.0);
    });

    test('returns custom default for null', () {
      expect(JsonParsers.parseDouble(null, -1.0), -1.0);
    });

    test('returns double as-is', () {
      expect(JsonParsers.parseDouble(3.14), 3.14);
    });

    test('converts int to double', () {
      expect(JsonParsers.parseDouble(5), 5.0);
    });

    test('parses valid double string', () {
      expect(JsonParsers.parseDouble('2.5'), 2.5);
    });

    test('parses integer string as double', () {
      expect(JsonParsers.parseDouble('10'), 10.0);
    });

    test('parses negative double string', () {
      expect(JsonParsers.parseDouble('-3.5'), -3.5);
    });

    test('returns default for alphabetic string', () {
      expect(JsonParsers.parseDouble('bad'), 0.0);
    });

    test('returns default for empty string', () {
      expect(JsonParsers.parseDouble(''), 0.0);
    });

    test('returns custom default for invalid string', () {
      expect(JsonParsers.parseDouble('xyz', 42.0), 42.0);
    });
  });

  group('JsonParsers.parseBool', () {
    test('returns false for null', () {
      expect(JsonParsers.parseBool(null), false);
    });

    test('returns custom default (true) for null', () {
      expect(JsonParsers.parseBool(null, true), true);
    });

    test('returns true for bool true', () {
      expect(JsonParsers.parseBool(true), true);
    });

    test('returns false for bool false', () {
      expect(JsonParsers.parseBool(false), false);
    });

    test('parses lowercase string "true"', () {
      expect(JsonParsers.parseBool('true'), true);
    });

    test('parses lowercase string "false"', () {
      expect(JsonParsers.parseBool('false'), false);
    });

    test('parses uppercase string "TRUE"', () {
      expect(JsonParsers.parseBool('TRUE'), true);
    });

    test('parses uppercase string "FALSE"', () {
      expect(JsonParsers.parseBool('FALSE'), false);
    });

    test('parses string "1" as true', () {
      expect(JsonParsers.parseBool('1'), true);
    });

    test('parses string "0" as false', () {
      expect(JsonParsers.parseBool('0'), false);
    });

    test('parses int 1 as true', () {
      expect(JsonParsers.parseBool(1), true);
    });

    test('parses int 0 as false', () {
      expect(JsonParsers.parseBool(0), false);
    });

    test('parses int 2 as false (only 1 is true)', () {
      expect(JsonParsers.parseBool(2), false);
    });

    test('returns default for unrecognised string', () {
      expect(JsonParsers.parseBool('maybe'), false);
    });

    test('returns default for empty string', () {
      expect(JsonParsers.parseBool(''), false);
    });
  });
}
