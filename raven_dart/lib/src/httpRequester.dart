part of raven_dart;

/**
 * Sends a message to Sentry.
 *
 * See [here](http://sentry.readthedocs.org/en/latest/developer/client/index.html#authentication) for
 * information about the authentication.
 */
void _sendMessage(Dsn dsn, SentryMessage message, List<Scrubber> scrubbers) {
  var url = '${dsn.protocol}://${dsn.host + dsn.path}api/${dsn.projectId}/store/';
  var userAgent  = 'raven_dart/${Constants.CLIENT_VERSION}';
  var authHeader = 'Sentry sentry_version=5,'
        + 'sentry_client=${userAgent},'
        + 'sentry_timestamp=${new DateTime.now().millisecondsSinceEpoch ~/ 1000},'
        + 'sentry_key=${dsn.publicKey},'
        + 'sentry_secret=${dsn.secretKey}';
  var body = scrubbers.fold(message.toJson(), (input, scrubber) => scrubber.scrub(input));

  runZoned(() =>
    http.post(url,
              headers : { 'User-Agent'    : userAgent,
                          'X-Sentry-Auth' : authHeader },
              body: body)
        .then((response) {
                if (response.statusCode != 200) {
                  print("Request to Sentry failed with status code [${response.statusCode}] and message [${new String.fromCharCodes(response.bodyBytes)}]");
                }
              }),
    onError: (exn) => print("Request to Sentry failed with exception [${exn}]"));
}