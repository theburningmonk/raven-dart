library raven_dart;

import 'dart:async';
import 'src/constants.dart';
import 'src/dsn.dart';
import 'src/enums.dart';
import 'src/message.dart';
import 'src/utils.dart';
import 'package:http/http.dart' as http;

part 'src/httpRequester.dart';
part 'src/scrubber.dart';

/**
 * Client for [Sentry](https://www.getsentry.com).
 */
class RavenClient {
  static const String _defaultLogger = "root";

  final Dsn  _dsn;
  final bool isEnabled;
  Map<String, String> _defaultTags;
  List<Scrubber> _scrubbers;

  RavenClient(String dsn, { Map<String, String> tags }) :
    this._dsn         = dsn.isNotEmpty ? Dsn.Parse(dsn) : null,
    this.isEnabled    = dsn.isNotEmpty,
    this._defaultTags = tags;

  void captureException(exn,
                        StackTrace stackTrace,
                        { String logger : _defaultLogger,
                          LogLevel logLevel : LogLevel.ERROR,
                          Map<String, String> tags,
                          Map<String, String> extra }) {
    if (!isEnabled) return;

    var sentryMsg = new SentryMessage(exn.toString(), logger,
                                      logLevel   : logLevel,
                                      culprit    : parseStackTraceToGetCurrentMethodName(stackTrace.toString()),
                                      tags       : convertMapsToTags([ _defaultTags, tags ]),
                                      extra      : extra,
                                      exception  : exn,
                                      stackTrace : stackTrace);
    _sendMessage(_dsn, sentryMsg);
  }

  void captureMessage(String message,
                      { String logger : _defaultLogger,
                        LogLevel logLevel : LogLevel.INFO,
                        Map<String, String> tags,
                        Map<String, String> extra }) {
    if (!isEnabled) return;

    var sentryMsg = new SentryMessage(message, logger,
                                      logLevel : logLevel,
                                      tags     : convertMapsToTags([ _defaultTags, tags ]),
                                      extra    : extra);
    _sendMessage(_dsn, sentryMsg);
  }
}