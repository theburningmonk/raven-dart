library raven_dart.constants;

/**
 * Captures the constant values in the library, such as variable size limits as imposed by Sentry.
 *
 * For more information, see [here](http://sentry.readthedocs.org/en/latest/developer/client/index.html#variable-size).
 */
class Constants {
  static String CLIENT_VERSION         = '0.1.0';
  static const int MAX_EVENT_ID_LENGTH = 32;
  static const int MAX_MESSAGE_LENGTH  = 1000;
}