library raven_dart.utils;

isNull (arg)    => arg == null;
isNotNull (arg) => arg != null;

isNullOrEmpty (arg)    => arg == null || arg.isEmpty;
isNotNullOrEmpty (arg) => !isNullOrEmpty(arg);

defaultArg (arg, defaultVal) => arg == null ? defaultVal : arg;
mapOrDefault (arg, f, [defaultVal = null]) => arg == null ? defaultVal : f(arg);

String truncate(String str, int length) => str.length > length ? str.substring(0, length) : str;

parseStackTraceToGetCurrentMethodName(String stackTrace) {
  var endIdx = stackTrace.indexOf("(");
  return endIdx >= 0 ? stackTrace.substring(8, endIdx - 1) : null;
}

parseStackTraceToGetCurrentFileName(String stackTrace) {
  var firstLine    = stackTrace.split('\n').first;
  var fileStartIdx = firstLine.indexOf('file:///');
  return fileStartIdx >= 0 ? firstLine.substring(fileStartIdx+8, firstLine.lastIndexOf('.dart')+5) : null;
}