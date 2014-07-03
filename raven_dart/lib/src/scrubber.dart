part of raven_dart;

abstract class Scrubber {
  String scrub(String input);
}

abstract class RegexScrubber implements Scrubber {
  final _regex;

  RegexScrubber(String pattern):
    this._regex = new RegExp(pattern, multiLine: true, caseSensitive: false);

  String replace(Match match);

  String scrub(String input) => input.replaceAllMapped(_regex, replace);
}

/**
 * Scrubber to remove credit card numbers from the input string
 */
class CreditCardScrubber extends RegexScrubber {
  // see http://www.regular-expressions.info/creditcard.html for the pattern used here
  CreditCardScrubber() : super(r"\b(?:\d[ -]*?){13,16}\b");

  replace(_) => "####-CC-SCRUBBED-####";
}

/**
 * Scrubber to remove Sentry key header from the input string
 */
class SentryKeyScrubber extends RegexScrubber {
  SentryKeyScrubber() : super(r"(sentry_key[ ]*[:=-][ ]*)([0-9a-z-A-Z]+)");

  replace(Match m) => '${m.group(1)}####-SENTRY-KEY-SCRUBBED-####';
}

/**
 * Scrubber to remove Sentry secret header from the input string
 */
class SentrySecretScrubber extends RegexScrubber {
  SentrySecretScrubber() : super(r"(sentry_secret[ ]*[:=-][ ]*)([0-9a-z-A-Z]+)");

  replace(Match m) => "${m.group(1)}####-SENTRY-SECRET-SCRUBBED-####";
}

/**
 * Scrubber to remove password key-value pairs from the input string
 */
class PasswordScrubber extends RegexScrubber {
  PasswordScrubber() : super(r'"(password|passwd|pwd|secret)"([ ]*[:][ ]*)"(.+)"');

  replace(Match m) => '"${m.group(1)}"${m.group(2)}"####-PASSWORD-SCRUBBED-####"';
}