library raven_dart;

import 'src/dsn.dart';
import 'src/enums.dart';
import 'src/http.dart';
import 'src/message.dart';
import 'src/scrubber.dart';
import 'src/utils.dart';

/**
 * Client for [Sentry](https://www.getsentry.com).
 */
class RavenClient {
  static const String _defaultLogger = "root";

  final Dsn  _dsn;
  final Map<String, String> _defaultTags;
  final List<Scrubber> _scrubbers;
  HttpRequester _requester;

  // Note: since the isolates are doing mostly IO work, it makes sense to have more isolate than cores
  RavenClient(String dsn,
              { Map<String, String> tags,
                List<Scrubber> scrubbers,
                int lvlOfConcurrencyPerCore : 3,
                int maxRetries : 3 }) :
    this._dsn         = dsn.isNotEmpty ? Dsn.Parse(dsn) : null,
    this._defaultTags = defaultArg(tags, {}),
    this._scrubbers   = defaultArg(scrubbers,
                                   [ new CreditCardScrubber(),
                                     new SentryKeyScrubber(),
                                     new SentrySecretScrubber(),
                                     new PasswordScrubber() ]) {
      _requester = new HttpRequester(_dsn, _scrubbers,
                                     lvlOfConcurrencyPerCore : lvlOfConcurrencyPerCore,
                                     maxRetries              : maxRetries);
    }

  void captureException(exn,
                        StackTrace stackTrace,
                        { String logger : _defaultLogger,
                          LogLevel logLevel : LogLevel.ERROR,
                          Map<String, String> tags,
                          Map<String, String> extra }) {
    if (!_requester.isEnabled) return;

    var sentryMsg = new SentryMessage(exn.toString(), logger,
                                      logLevel   : logLevel,
                                      culprit    : parseStackTraceToGetCurrentMethodName(stackTrace.toString()),
                                      tags       : convertMapsToTags([ _defaultTags, tags ]),
                                      extra      : extra,
                                      exception  : exn,
                                      stackTrace : stackTrace);
    _requester.sendMessage(sentryMsg);
  }

  void captureMessage(String message,
                      { String logger : _defaultLogger,
                        LogLevel logLevel : LogLevel.INFO,
                        Map<String, String> tags,
                        Map<String, String> extra }) {
    if (!_requester.isEnabled) return;

    var sentryMsg = new SentryMessage(message, logger,
                                      logLevel : logLevel,
                                      tags     : convertMapsToTags([ _defaultTags, tags ]),
                                      extra    : extra);
    _requester.sendMessage(sentryMsg);
  }

  void close() => _requester.close();
}