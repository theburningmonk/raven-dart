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

  /**
   * You need to specify the [dsn] for your project in Sentry.
   *
   * If there is a set of common tags that should be applied to ALL your events (both exceptions and non-exceptions)
   * then you should provide them via the optional parameter [tags].
   * If [tags] include keys that are overlapped by event specific tags provided in the [captureException] and [captureMessage]
   * methods then both tags are sent in the event.
   *
   * Additionally, you can specify the max level of concurrent requests to Sentry per available processor on the current system.
   * Since sending HTTP requests is not CPU intensive work, so the default [lvlOfConcurrencyPerCore] is set to 3 which shouldn't
   * ever stop you from being able to do other useful work on the CPUs but should you need to you can dial that up and down to
   * suit your needs.
   *
   * Similarly, failed HTTP requests that make sense to retry (e.g. temporary network issue, etc.) are retried up to a maximum
   * of 3 times, but you can change that number by setting the [maxRetries] optional parameter. A minimum wait of 100ms is used
   * between retries, with the delay increasing exponentially as the number of retries increases.
   *
   */
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

  /**
   * Captures information about an exception/error as an event in Sentry.
   *
   * ## Arguments
   * [exn]        - the exception/error object.
   * [stackTrace] - the StackTrace captured along with [exn].
   * [logger]     - the name of the logger, defaults to 'root'.
   * [logLevel]   - the severity level of this exception, defaults to [LogLevel.ERROR].
   * [tags]       - a map of custom tags to be logged along with the exception information.
   * [extra]      - a map of additional metadata to store with the event.
   *
   * ## Example
   * In order to capture the minimum amount of information with an exception:
   *
   *      import 'package:raven_dart/raven_dart.dart';
   *
   *      main() {
   *        var dsn    = 'https://b70a31b3510c4cf793964a185cfe1fd0:b7d80b520139450f903720eb7991bf3d@example.com/1';
   *        var client = new RavenClient(dsn);
   *
   *        try {
   *          throw new Exception("test exception");
   *        } catch (exn, stackTrace) {
   *          client.captureException(exn, st);
   *        }
   *      }
   *
   */
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

  /**
   * Captures an arbitrary message as an event in Sentry.
   *
   * ## Arguments
   * [message]    - the message to be recorded.
   * [logger]     - the name of the logger, defaults to 'root'.
   * [logLevel]   - the severity level of this exception, defaults to [LogLevel.INFO].
   * [tags]       - a map of custom tags to be logged along with the message.
   * [extra]      - a map of additional metadata to store with the event.
   *
   * ## Example
   *
   *      import 'package:raven_dart/raven_dart.dart';
   *
   *      main() {
   *        var dsn    = 'https://b70a31b3510c4cf793964a185cfe1fd0:b7d80b520139450f903720eb7991bf3d@example.com/1';
   *        var client = new RavenClient(dsn);
   *        client.captureMessage("test");
   *      }
   *
   */
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

  /**
   * Gracefully disposes of the client and associated resources.
   */
  void close() => _requester.close();
}