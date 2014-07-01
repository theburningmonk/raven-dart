library raven_dart;

import 'dart:async';
import 'src/constants.dart';
import 'src/dsn.dart';
import 'src/enums.dart';
import 'src/message.dart';
import 'src/utils.dart';
import 'package:dart_ext/collection_ext.dart' as CollectionExt;
import 'package:http/http.dart' as http;

part 'src/httpRequester.dart';

/**
 * Client for [Sentry](https://www.getsentry.com).
 */
class RavenClient {
  static const String _defaultLogger = "root";

  final Dsn  _dsn;
  final bool isEnabled;
  Map  _defaultTags;

  RavenClient(String dsn, [ Map defaultTags ]) :
    this._dsn         = dsn.isNotEmpty ? Dsn.Parse(dsn) : null,
    this.isEnabled    = dsn.isNotEmpty,
    this._defaultTags = defaultTags;

  void captureException(exn,
                        StackTrace stackTrace,
                        { String logger : _defaultLogger,
                          LogLevel logLevel : LogLevel.ERROR,
                          Map tags,
                          Map extra }) {
    if (!isEnabled) return;

    var sentryMsg = new SentryMessage(exn.toString(), logger,
                                      logLevel   : logLevel,
                                      culprit    : parseStackTraceToGetCurrentMethodName(stackTrace.toString()),
                                      tags       : CollectionExt.merge(tags, _defaultTags),
                                      extra      : extra,
                                      exception  : exn,
                                      stackTrace : stackTrace);
    _sendMessage(_dsn, sentryMsg);
  }

  void captureMessage(String message,
                      { String logger : _defaultLogger,
                        LogLevel logLevel : LogLevel.INFO,
                        Map tags,
                        Map extra }) {
    if (!isEnabled) return;

    var sentryMsg = new SentryMessage(message, logger,
                                      logLevel : logLevel,
                                      tags     : CollectionExt.merge(tags, _defaultTags),
                                      extra    : extra);
    _sendMessage(_dsn, sentryMsg);
  }
}