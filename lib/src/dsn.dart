library raven_dart.dsn;

import 'exceptions.dart';
import 'utils.dart';

class Dsn {
  /// The protocol to use, e.g. https, http
  final String protocol;

  /// The host name, e.g. example.com
  final String host;

  /// The public key for your account
  final String publicKey;

  /// The secret key for your account
  final String secretKey;

  /// Relative path from the host name, e.g. sentry/
  final String path;

  /// Unique ID for your project
  final String projectId;

  Dsn._internal(this.protocol, this.host, this.path,
                this.publicKey, this.secretKey, this.projectId);

  /**
   * Parses the provided string into a [Dsn] object
   */
  static Dsn Parse(String dsnStr) {
    try {
      return _parse(dsnStr);
    } on InvalidDsnException catch(exn) {
      throw exn;
    } on Object catch(e) {
      throw new InvalidDsnException(dsnStr, inner: e);
    }
  }

  static _parse(String dsnStr) {
    Uri uri  = Uri.parse(dsnStr);
    var keys = uri.userInfo.split(':').where(isNotNullOrEmpty).toList();
    if (keys.length != 2)
    {
      throw new InvalidDsnException(dsnStr);
    }

    var publicKey = keys[0];
    var secret    = keys[1];

    var pathSegments = uri.path.split('/').where(isNotNullOrEmpty).toList();
    if (pathSegments.isEmpty)
    {
      throw new InvalidDsnException(dsnStr);
    }

    var projectId = pathSegments.last;
    var path = uri.path.substring(0, uri.path.length - projectId.length);

    return new Dsn._internal(uri.scheme, '${uri.host}:${uri.port}', path, publicKey, secret, projectId);
  }

  static _getProjectId(Uri uri) {
    return uri.path.split('/').last;
  }
}