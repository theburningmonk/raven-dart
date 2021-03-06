library raven_dart.http;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'constants.dart';
import 'dsn.dart';
import 'enums.dart';
import 'message.dart';
import 'scrubber.dart';
import 'utils.dart';

/**
 * Sends a message to Sentry.
 *
 * See [here](http://sentry.readthedocs.org/en/latest/developer/client/index.html#authentication) for
 * information about the authentication.
 */
class HttpRequester {
  int _index = 0;
  final Dsn _dsn;
  final String _url, _userAgent;
  final List<Scrubber> _scrubbers;
  final List<ReceivePort> _isolates = new List();
  final int _lvlOfConcurrencyPerCore, _maxRetries;
  List<SendPort> _handlers;

  Status _status;
  Timer _reenableTimer;

  HttpRequester(Dsn dsn, List<Scrubber> scrubbers, { int lvlOfConcurrencyPerCore, int maxRetries }) :
    this._dsn        = dsn,
    this._url        = mapOrDefault(dsn, (dsn) => '${dsn.protocol}://${dsn.host + dsn.path}api/${dsn.projectId}/store/'),
    this._userAgent  = 'raven_dart/${Constants.CLIENT_VERSION}',
    this._scrubbers  = scrubbers,
    this._maxRetries = defaultArg(maxRetries, 3),
    this._lvlOfConcurrencyPerCore = defaultArg(lvlOfConcurrencyPerCore, 3) {
      _status        = dsn == null ? Status.Disabled : Status.Enabled;
      _reenableTimer = new Timer.periodic(new Duration(minutes : 1), _reenable);
      _handlers      = new Iterable
                            .generate(this._lvlOfConcurrencyPerCore * Platform.numberOfProcessors, _initReceivePort)
                            .toList();
    }

  void sendMessage(SentryMessage message) {
    _handlers[_index].send({ 'body' : _getBody(message), 'retries' : 0 });
    _index = (_index + 1) % _handlers.length;
  }

  void close() => _isolates.forEach((port) => port.close());

  bool get isEnabled => _status == Status.Enabled;

  void _reenable(_) {
    if (_status != Status.Disabled) {
      _status = Status.Enabled;
    }
  }

  String _getAuthHeader() =>
    'Sentry sentry_version=5,'
      + 'sentry_client=${_userAgent},'
      + 'sentry_timestamp=${new DateTime.now().millisecondsSinceEpoch ~/ 1000},'
      + 'sentry_key=${_dsn.publicKey},'
      + 'sentry_secret=${_dsn.secretKey}';

  String _getBody(SentryMessage message) => _scrubbers.fold(message.toJson(), (input, scrubber) => scrubber.scrub(input));

  void _fallback(String body) => print("Fallback from Sentry request:\n${body}");

  void _retry(String body, int retries, SendPort port) {
    if (retries >= this._maxRetries) {
      return;
    }

    var wait = new Duration(milliseconds : 100 * (pow(2, retries)));
    new Timer(wait, () {
      port.send({ 'body' : body, 'retries' : retries + 1 }); // resend the message to be retried
    });
  }

  SendPort _initReceivePort(_) {
    ReceivePort port  = new ReceivePort();
    _isolates.add(port);

    SendPort sendPort = port.sendPort;

    port.listen((Map args) {
        String body = args['body'];

        if (_status != Status.Enabled) {
          _fallback(body);
          return;
        }

        runZoned(() =>
          http.post(_url,
                    headers : { 'User-Agent'    : _userAgent,
                                'X-Sentry-Auth' : _getAuthHeader() },
                    body: body)
              .then((response) {
                  switch (response.statusCode) {
                    case 200: // OK, no action required
                      break;
                    case 400: // Bad request? something's not right here, no point retrying
                      print("Request to Sentry failed with 400 [${response.body}].");
                      _fallback(body);
                      break;
                    case 401:
                    case 403: // unauthorized, so not trying any more, disable permenantly
                      print("Request to Sentry failed with ${response.statusCode} [${response.body}], disabling the HttpRequester");
                      _status = Status.Disabled;
                      _fallback(body);
                      break;
                    case 503:
                      print("Sentry service is temporarily unavailable, disabling the HttpRequester temporarily");
                      _status = Status.TemporaryDisabled;
                      _fallback(body);
                      break;
                    default:
                      print("Request to Sentry failed with ${response.statusCode} [${response.body}], retrying...");
                      _retry(body, args['retries'], sendPort);
                      break;
                  }
                }),
          onError: (exn) => print("Request to Sentry failed with exception [${exn}]"));
      });

    return sendPort;
  }
}