library raven_dart_test;

import 'src/dsn_parser_test.dart';
import 'src/message_test.dart';
import 'src/raven_client_test.dart';
import 'src/utils_test.dart';

main() {
  new DsnParserTests().start();
  new MessageTests().start();
  new RavenClientTests().start();
  new UtilsTests().start();
}