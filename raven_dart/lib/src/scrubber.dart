part of raven_dart;

abstract class Scrubber {
  String scrub(String input);
}

abstract class RegexScrubber implements Scrubber {
  final _regex;

  RegexScrubber(String pattern):
    this._regex = new RegExp(pattern, multiLine: true, caseSensitive: false);

  String replace(String match);

  String scrub(String input) {
    String output = input;
    Iterable<Match> matches = _regex.allMatches(input);

    // for any matched credit card numbers, replace it
    for (Match m in matches) {
      String match = m.group(0);
      output = output.replaceAll(match, replace(match));
    }

    return output;
  }
}

/**
 * Scrubber to remove credit card numbers from the input string
 */
class CreditCardScrubber extends RegexScrubber {
  // see http://www.regular-expressions.info/creditcard.html for the pattern used here
  CreditCardScrubber() : super(r"\b(?:\d[ -]*?){13,16}\b");

  replace(_) => "####-CC-TRUNCATED-####";
}

/**
 * Scrubber to remove Sentry key header from the input string
 */
class SentryKeyScrubber extends RegexScrubber {
  SentryKeyScrubber() : super(r"sentry_key[ ]*[:=-][ ]*[0-9a-z-A-Z]+");

  replace(_) => "####-SENTRY-KEY-TRUNCATED-####";
}

/**
 * Scrubber to remove Sentry secret header from the input string
 */
class SentrySecretScrubber extends RegexScrubber {
  SentrySecretScrubber() : super(r"sentry_secret[ ]*[:=-][ ]*[0-9a-z-A-Z]+");

  replace(_) => "####-SENTRY-SECRET-TRUNCATED-####";
}