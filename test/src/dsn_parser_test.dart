library raven_dart_test.dsn;

import 'package:unittest/unittest.dart';
import 'package:raven_dart/src/dsn.dart';
import 'package:raven_dart/src/exceptions.dart';

class DsnParserTests {
  void start() {
    group('dsn_parser', () {
      _testValidDsn();
      _testMissingProtocol();
      _testMissingPublicKey();
      _testMissingSecretKey();
      _testMissingProjectId();
    });
  }

  void _testValidDsn() {
    var dsnStr = 'https://public:secret@example.com/sentry/12345';

    test('test parsing valid URI', () {
      var dsn = Dsn.Parse(dsnStr);
      expect(dsn.host,      equals('example.com'), reason : 'host should be "example.com"');
      expect(dsn.projectId, equals('12345'),       reason : 'project Id should be "12345"');
      expect(dsn.publicKey, equals('public'),      reason : 'public key should be "public"');
      expect(dsn.secretKey, equals('secret'),      reason : 'public key should be "secret"');
      expect(dsn.path,      equals('/sentry/'),     reason : 'path should be "/sentry/"');
    });
  }

  void _testMissingProtocol() {
    var dsnStr = 'public:secret@example.com/sentry/12345';

    test('when protocol is missing it should except', () {
      expect(() => Dsn.Parse(dsnStr), throwsA(new isInstanceOf<InvalidDsnException>()));
    });
  }

  void _testMissingPublicKey() {
    var dsnStr = 'https://:secret@example.com/sentry/12345';

    test('when public key is missing it should except', () {
      expect(() => Dsn.Parse(dsnStr), throwsA(new isInstanceOf<InvalidDsnException>()));
    });
  }

  void _testMissingSecretKey() {
    var dsnStr = 'https://public:@example.com/sentry/12345';

    test('when secret key is missing it should except', () {
      expect(() => Dsn.Parse(dsnStr), throwsA(new isInstanceOf<InvalidDsnException>()));
    });
  }

  void _testMissingProjectId() {
    var dsnStr = 'https://public:secret@example.com/';

    test('when project ID is missing it should except', () {
      expect(() => Dsn.Parse(dsnStr), throwsA(new isInstanceOf<InvalidDsnException>()));
    });
  }
}