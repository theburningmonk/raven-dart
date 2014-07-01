library raven_dart_test.message;

import 'package:unittest/unittest.dart';
import 'package:raven_dart/src/message.dart';
import 'package:raven_dart/src/enums.dart';

class MessageTests {
  void start() {
    group('message', () {
      _testMessageOver1000CharsIsTruncated();
      _testMessageLessThan1000CharsIsNotTruncated();
      _testMessageDefaultToErrorLogLevel();
    });
  }

  void _testMessageOver1000CharsIsTruncated() {
    test('message over 1000 chars is truncated to 1000 chars', () {
      var n = 'a'.codeUnitAt(0);
      String longMessage = new String.fromCharCodes(new Iterable.generate(1001, (_) => n));
      var message = new SentryMessage(longMessage, 'test');

      expect(message.message.length, equals(1000), reason : 'message should have been truncated down to first 1000 chars');
    });
  }

  void _testMessageLessThan1000CharsIsNotTruncated() {
    test('message under 1000 chars is not truncated', () {
      var message = new SentryMessage('hello world!', 'test');

      expect(message.message.length, equals(12),      reason : 'message should not have been truncated');
      expect(message.message, equals('hello world!'), reason : 'message should be "hello world!"');
    });
  }

  void _testMessageDefaultToErrorLogLevel() {
    test('message default to Error log level', () {
      var message = new SentryMessage('message', 'test');

      expect(message.logLevel, equals(LogLevel.ERROR), reason : 'message should default to Error log level');
    });
  }
}
