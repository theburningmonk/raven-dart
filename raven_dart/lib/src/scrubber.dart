part of raven_dart;

abstract class Scrubber {
  String scrub(String input);
}

/**
 * Scrubber to remove credit card numbers from the input string
 */
class CreditCardScrubber implements Scrubber {
  // see http://www.regular-expressions.info/creditcard.html for the pattern used here
  static final _regex   = new RegExp(r"\b(?:\d[ -]*?){13,16}\b", multiLine: true, caseSensitive: false);

  String scrub(String input) {
    String output = input;
    Iterable<Match> matches = _regex.allMatches(input);

    // for any matched credit card numbers, replace it
    for (Match m in matches) {
      String match = m.group(0);
      output = output.replaceAll(match, "####-CC-TRUNCATED-####");
    }

    return output;
  }
}

class _DefaultScrubber implements Scrubber {
  String scrub(String input) => "";
}