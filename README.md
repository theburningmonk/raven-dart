# Basic Usage #

```
import 'package:raven_dart/raven_dart.dart';

main() {
  var dsn    = 'https://b70a31b3510c4cf793964a185cfe1fd0:b7d80b520139450f903720eb7991bf3d@example.com/1';

  // initialize the client with your DSN
  var client = new RavenClient(dsn);

  // captures a message as an info event 
  client.captureMessage("test");

  try {
    throw new Exception("test exception");
  } catch (exn, stacktrace) {
	// captures exception with stacktrace as an error event
    client.captureException(exn, stacktrace);
  }
}
```

# Resources #

- Download
- API doc (coming soon)
- [Bug Tracker](https://github.com/theburningmonk/raven-dart/issues)
- Follow [@theburningmonk](https://twitter.com/theburningmonk) on Twitter for updates
