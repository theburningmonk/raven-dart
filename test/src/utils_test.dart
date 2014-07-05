library raven_dart_test.utils;

import 'package:unittest/unittest.dart';
import 'package:raven_dart/src/utils.dart';

class UtilsTests {
  void start() {
    group('utils', () {
      _testIsNullOrEmpty();
      _testIsNotNullOrEmpty();
      _testParseCurrentMethodName();
    });
  }

  void _testIsNullOrEmpty() {
    test('isNullOrEmpty should work with Iterable and String', () {
      expect(isNullOrEmpty(null),       equals(true));

      expect(isNullOrEmpty([]),         equals(true),  reason: 'empty list should be deemed empty');
      expect(isNullOrEmpty([1]),        equals(false), reason: '[1] should not be deemed empty');

      expect(isNullOrEmpty({}),         equals(true),  reason: 'empty map should be deemed empty');
      expect(isNullOrEmpty({ 1:1 }),    equals(false), reason: '{ 1:1 } should not be deemed empty');

      expect(isNullOrEmpty(""),         equals(true),  reason: 'empty string should be deemed empty');
      expect(isNullOrEmpty("1"),        equals(false), reason: '"1" should not be deemed empty');
    });
  }

  void _testIsNotNullOrEmpty() {
    test('isNotNullOrEmpty should work with Iterable and String', () {
      expect(isNotNullOrEmpty(null),    equals(false));

      expect(isNotNullOrEmpty([]),      equals(false), reason: 'empty list should be deemed empty');
      expect(isNotNullOrEmpty([1]),     equals(true),  reason: '[1] should not be deemed empty');

      expect(isNotNullOrEmpty({}),      equals(false), reason: 'empty map should be deemed empty');
      expect(isNotNullOrEmpty({ 1:1 }), equals(true),  reason: '{ 1:1 } should not be deemed empty');

      expect(isNotNullOrEmpty(""),      equals(false), reason: 'empty string should be deemed empty');
      expect(isNotNullOrEmpty("1"),     equals(true),  reason: '"1" should not be deemed empty');
    });
  }

  void _testParseCurrentMethodName() {
    test('for a stackframe should be able to parse the current method name', () {
      var stackFrame = '#0      RavenClientTests._testCaptureException (file:///c:/raven-dart/src/raven_client.dart:28:7)';
      var methodName = parseStackTraceToGetCurrentMethodName(stackFrame);

      expect(methodName, equals('RavenClientTests._testCaptureException'), reason: 'method name should be "RavenClientTests._testCaptureException"');
    });
  }
}