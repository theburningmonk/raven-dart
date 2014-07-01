library raven_dart_test;

import 'package:unittest/unittest.dart';
import 'package:raven_dart/raven_dart.dart';

class RavenClientTests {
  // if you want to run these two tests, then put your DSN here and comment the tests below
  var dsn = 'https://:@app.getsentry.com/';

  void start() {
    group('raven_client', () {
      //_testCaptureMessage();
      //_testCaptureException();
    });
  }

  void _testCaptureMessage() {
    var client = new RavenClient(dsn);
    client.captureMessage("test");

    // need this just to make the unittest framework wait for the above to complete
    test('xyz', () { expect("1", equals("1")); });
  }

  void _testCaptureException() {
    var client = new RavenClient(dsn);
    try
    {
      throw new Exception("test exception");
    } catch (exn, st) {
      client.captureException(exn, st);
    }

    // need this just to make the unittest framework wait for the above to complete
    test('xyz', () { expect("1", equals("1")); });
  }
}