library raven_dart.exceptions;

class AggregateException implements Exception {
  final String message;
  final Exception inner;

  AggregateException(this.message, this.inner);

  @override
  String toString() => "${message}\n${inner != null ? inner.toString() : null}";
}

/**
 * Exception that is thrown when an invalid DSN string is passed to the [RavenClient]
 */
class InvalidDsnException extends AggregateException implements Exception {
  final String dsnStr;

  InvalidDsnException(dsnStr, { Exception inner : null }) :
    this.dsnStr = dsnStr,
    super(getMessage(dsnStr), inner);

  static getMessage(String dsnStr) => "Invalid DSN string : ${dsnStr}";

  @override
  String toString() => getMessage(this.dsnStr);
}