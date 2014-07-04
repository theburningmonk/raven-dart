library raven_dart.enums;

abstract class _Enum<T> {
  final T value;

  const _Enum(this.value);
}

class LogLevel extends _Enum<String> {
  const LogLevel._internal(String level) : super(level);

  static const LogLevel FATAL   = const LogLevel._internal("fatal");
  static const LogLevel ERROR   = const LogLevel._internal("error");
  static const LogLevel WARNING = const LogLevel._internal("warning");
  static const LogLevel INFO    = const LogLevel._internal("info");
  static const LogLevel DEBUG   = const LogLevel._internal("debug");

  @override
  String toString() => this.value;

  toJson() => this.value;
}

class Status extends _Enum<int> {
  const Status._internal(int status) : super(status);

  static const Status Enabled           = const Status._internal(1);
  static const Status TemporaryDisabled = const Status._internal(2);
  static const Status Disabled          = const Status._internal(3);

  @override
  String toString() {
    switch (this.value) {
      case 1:
        return "Enabled";
      case 2:
        return "Temporarily Disabled";
      case 3:
        return "Disabled";
    };
  }
}