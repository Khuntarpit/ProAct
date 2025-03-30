class NetworkExceptions implements Exception {

  final _message;
  final _prefix;
  NetworkExceptions([this._message, this._prefix]);

  String toString(){
    return '$_prefix $_message';
  }
}

class InternetException extends NetworkExceptions {
  InternetException([String? message]) : super(message, 'No internet');
}

class RequestTimeOut extends NetworkExceptions {
  RequestTimeOut([String? message]) : super(message!, 'Request time out');
}

class ServerException extends NetworkExceptions {
  ServerException([String? message]) : super(message!, 'Internal server error');
}

class InvalidUrlException extends NetworkExceptions {
  InvalidUrlException([String? message]) : super(message!, 'Invalid url');
}

class FetchDataException extends NetworkExceptions {
  FetchDataException([String? message]) : super(message!, '');
}