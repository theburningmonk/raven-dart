library raven_dart.message;

import 'dart:convert';
import 'dart:io';
import 'constants.dart';
import 'enums.dart';
import 'utils.dart';
import 'package:uuid/uuid_server.dart';

class Tag {
  String key;
  String value;

  Tag(this.key, this.value);

  toJson() => [this.key, this.value];
}

/**
 * Represents an exception stack frame for Sentry
 */
class SentryStackFrame {
  String _filename, _module, _function;
  int _lineno, _colno = 0;

  /**
   * Creates a stackframe object from a line from the stacktrace, e.g.
   *    #0      RavenClientTests._testCaptureException (file:///c:/raven-dart/src/raven_client.dart:28:7)
   */
  SentryStackFrame._fromFrame(String frame) {
    var fileStartIdx = frame.indexOf(new RegExp(r'\((file)|(package)|(dart):'));
    if (fileStartIdx >= 0) {
      this._function = parseStackTraceToGetCurrentMethodName(frame);
      this._filename = frame.substring(fileStartIdx, frame.lastIndexOf('.dart'));
      this._module   = this._filename.split('/').last;
      var lineInfo  = frame.substring(frame.lastIndexOf('.dart')+5, frame.lastIndexOf(')'));
      var linePos   = lineInfo.split(':').where(isNotNullOrEmpty).toList();
      this._lineno   = int.parse(linePos[0]);
      if (linePos.length > 1) {
        this._colno    = int.parse(linePos[1]);
      }
    }
  }

  _toJson() => {
    "filename": this._filename,
    "lineno"  : this._lineno,
    "colno"   : this._colno,
    "function": this._function,
    "module"  : this._module,
  };

  toJson() => (this._filename == null) ? null : _toJson();
}

/**
 * Represents an exception stack trace for Sentry
 */
class SentryStackTrace {
  final List<SentryStackFrame> _frames;

  SentryStackTrace._fromStackTrace(String stackTrace) :
    this._frames = stackTrace
                    .split('\n')
                    .map((frame) => new SentryStackFrame._fromFrame(frame))
                    .toList();

  toJson() => {"frames": this._frames.map((f) => f.toJson()).where(isNotNull).toList() };
}

/**
 * Represents an exception object for Sentry
 */
class SentryException {
  final String _type, _value, _module;
  final SentryStackTrace _stackTrace;

  SentryException._fromException(exn, [String stackTrace]) :
    this._type       = exn.runtimeType.toString(),
    this._value      = exn.toString(),
    this._module     = parseStackTraceToGetCurrentFileName(stackTrace),
    this._stackTrace = mapOrDefault(stackTrace, (st) => new SentryStackTrace._fromStackTrace(st));

  toJson() => {
    "type"      : this._type,
    "value"     : this._value,
    "module"    : this._module,
    "stacktrace": this._stackTrace.toJson(),
  };
}

/**
 * Represents all the data fields that Sentry requires.
 *
 * For more information, see [here](http://sentry.readthedocs.org/en/latest/developer/client/index.html)
 */
class SentryMessage extends Object {
  static Uuid uuid = new Uuid();

  // the following are mandatory fields

  /// Hexadecimal string representing a uuid4 value.
  final String eventId;

  /// User-readable representation of this event.
  final String message;

  /// The name of the logger which created the record.
  final String logger;

  /// The record severity.
  final LogLevel logLevel;

  /// When the event is recorded on the client.
  final DateTime timestamp;

  // the following are option fields

  /// A string representing the platform the client is submitting from.
  final String platform;

  /// Function call which was the primary perpetrator of this event.
  final String culprit;

  /// Identifies the host client from which the event was recorded.
  final String serverName;

  /// A list of relevant modules and their versions.
  final Map modules;

  /// A map of tags for this event.
  final List<Tag> tags;

  /// An arbitrary mapping of additional metadata to store with the event.
  final Map extra;

  /// For the built-in [sentry.interfaces.Exception](http://sentry.readthedocs.org/en/latest/developer/interfaces/index.html) interface
  final SentryException exception;

  static List<Tag> _defaultTags =
    [
      new Tag('dart_runtime_version', Platform.version.replaceAll('"', "'")),
      new Tag('os', Platform.operatingSystem),
      new Tag('number_of_processors', Platform.numberOfProcessors.toString())
    ];

  /**
   * Create a new message that encapsulates all the fields to be sent as part of the event to Sentry.
   *
   * The default logLevel is 'error'.
   * The default platform is 'dart'.
   */
  SentryMessage(String message,
                String this.logger,
                { this.logLevel : LogLevel.ERROR,  // NOTE: default log level is ERROR
                  this.platform : 'dart',          // NOTE: default platform is 'dart'
                  this.culprit,
                  modules,
                  List<Tag> tags,
                  Map extra,
                  exception,
                  StackTrace stackTrace}) :
    this.eventId    = (uuid.v4() as String).replaceAll('-', ''),
    this.message    = truncate(message, Constants.MAX_MESSAGE_LENGTH),
    this.timestamp  = new DateTime.now(),
    this.serverName = Platform.localHostname,
    this.tags       = concatList(_defaultTags, tags),
    this.extra      = defaultArg(extra, {}),
    this.modules    = defaultArg(modules, {}),
    this.exception  = mapOrDefault(exception, (exn) => new SentryException._fromException(exn, stackTrace.toString()));

  String toJson() => JSON.encode({
    "event_id"    : this.eventId,
    "message"     : this.message,
    "timestamp"   : this.timestamp.millisecondsSinceEpoch,
    "level"       : this.logLevel.toJson(),
    "logger"      : this.logger,
    "platform"    : this.platform,
    "culprit"     : this.culprit,
    "tags"        : this.tags.map((tag) => tag.toJson()).toList(),
    "extra"       : this.extra,
    "server_name" : this.serverName,
    "modules"     : this.modules,
    "exception"   : [(this.exception == null) ? '' : this.exception.toJson()],
  });
}