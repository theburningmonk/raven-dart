library raven_dart.utils;

import 'message.dart';

id (arg) => arg;

isNull (arg)    => arg == null;
isNotNull (arg) => arg != null;

isNullOrEmpty (arg)    => arg == null || arg.isEmpty;
isNotNullOrEmpty (arg) => !isNullOrEmpty(arg);

defaultArg (arg, defaultVal) => arg == null ? defaultVal : arg;
mapOrDefault (arg, f, [defaultVal = null]) => arg == null ? defaultVal : f(arg);

String truncate(String str, int length) => str.length > length ? str.substring(0, length) : str;

List<Tag> convertMapToTag(Map map, { mapKey : id, mapValue : id }) {
  var list = new List<Tag>();
  defaultArg(map, {}).forEach((key, value) => list.add(new Tag(mapKey(key), mapValue(value))));
  return list;
}

List<Tag> convertMapsToTags(List<Map> maps) => maps.expand((map) => convertMapToTag(map)).toList();

List concatList(List left, List right) {
  var list = new List.from(defaultArg(left, []), growable: true);
  list.addAll(defaultArg(right, []));
  return list;
}

parseStackTraceToGetCurrentMethodName(String stackTrace) {
  var endIdx = stackTrace.indexOf("(");
  return endIdx >= 0 ? stackTrace.substring(8, endIdx - 1) : null;
}

parseStackTraceToGetCurrentFileName(String stackTrace) {
  var firstLine    = stackTrace.split('\n').first;
  var fileStartIdx = firstLine.indexOf('file:///');
  return fileStartIdx >= 0 ? firstLine.substring(fileStartIdx+8, firstLine.lastIndexOf('.dart')+5) : null;
}