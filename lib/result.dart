import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_core/datasources/remote/client/http_client.dart';
import 'package:flutter_core/resource.dart';

class Result<T> {
  final _receivePort = ReceivePort();

  SendPort get _sendPort => _receivePort.sendPort;

  void send({required Resource<T>? resource}) {
    _sendPort.send(resource);
  }

  collect(
    Function(Resource<T> resource) onData, {
    Function(Object error)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    try {
      return _receivePort.listen(
        (message) {
          onData.call(message as Resource<T>);
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    } catch (e) {
      onError?.call(e);
      debug(e.toString(), error: e);
    }

    return null;
  }
}
