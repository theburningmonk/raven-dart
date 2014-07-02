library raven_dart_test.scrubbers;

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