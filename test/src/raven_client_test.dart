library raven_dart_test;

import 'dart:async';

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

  void _testCaptureMessage() =>
    test('captureMessage should send an info event', () {
      var client = new RavenClient(dsn);
      client.captureMessage("test");

      // give the client some time to make the HTTP call
      return new Future
        .delayed(new Duration(milliseconds : 100))
        .then((_) => client.close());
    });

  void _testCaptureException() =>
    test('captureException should send an error event', () {
      var client = new RavenClient(dsn, tags: { 'label1' : 'test', 'label2' : 'also test', 'password' : 'live long and prosper' });
      try
      {
        throw new Exception("test exception");
      } catch (exn, st) {
        client.captureException(exn, st, tags : { 'label1' : 'another test', 'label2' : 'yet another test' });
      }

      // give the client some time to make the HTTP call
      return new Future
        .delayed(new Duration(milliseconds : 100))
        .then((_) => client.close());
    });
}