import 'package:unittest/unittest.dart';
import 'package:raven_dart/raven_dart.dart';

class CreditCardScrubberTests {
  Scrubber scrubber = new CreditCardScrubber();

  void start() {
    group('credit_card_scrubber', () {
      _testCreditCardNumberIsScrubbed();
    });
  }

  void _testCreditCardNumberIsScrubbed() {
    test('credit card number is scrubbed', () {
      var ccNumber = "1234-5678-9101-1121";
      var input    = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ${ccNumber} Praesent est dui";

      var output = scrubber.scrub(input);
      expect(output.contains(ccNumber), equals(false), reason : 'credit card number should have been replaced');
    });
  }
}

class SentryKeyScrubberTests {
  Scrubber scrubber = new SentryKeyScrubber();

  void start() {
    group('sentry_key_scrubber', () {
      _testSentryKeyIsScrubbed();
    });
  }

  void _testSentryKeyIsScrubbed() {
    doTest (separator) {
      test('sentry key with "${separator}" as separator is scrubbed', () {
        var sentryKey = "sentry_key${separator}b70a31b3510c4cf793964a185cfe1fd0";
        var input     = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ${sentryKey} Praesent est dui";

        var output = scrubber.scrub(input);
        expect(output.contains(sentryKey), equals(false), reason : 'sentry_key should have been replaced');
      });
    }

    doTest('=');
    doTest('= ');
    doTest(' =');
    doTest(' = ');
    doTest(':');
    doTest(': ');
    doTest(' :');
    doTest(' : ');
    doTest('-');
    doTest('- ');
    doTest(' -');
    doTest(' - ');
  }
}

class SentrySecretScrubberTests {
  Scrubber scrubber = new SentrySecretScrubber();

  void start() {
    group('sentry_secret_scrubber', () {
      _testSentrySecretIsScrubbed();
    });
  }

  void _testSentrySecretIsScrubbed() {
    doTest (separator) {
      test('sentry secret with "${separator}" as separator is scrubbed', () {
        var sentrySecret = "sentry_secret${separator}b70a31b3510c4cf793964a185cfe1fd0";
        var input = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ${sentrySecret} Praesent est dui";

        var output = scrubber.scrub(input);
        expect(output.contains(sentrySecret), equals(false), reason : 'sentry_secret should have been replaced');
      });
    }

    doTest('=');
    doTest('= ');
    doTest(' =');
    doTest(' = ');
    doTest(':');
    doTest(': ');
    doTest(' :');
    doTest(' : ');
    doTest('-');
    doTest('- ');
    doTest(' -');
    doTest(' - ');
  }
}