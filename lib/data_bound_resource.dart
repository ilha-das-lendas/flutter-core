
import 'package:flutter_core/datasources/resource_strategy.dart';
import 'package:flutter_core/datasources/remote/remote_resource_trategy.dart';
import 'package:flutter_core/datasources/remote/response/response_wrapper.dart';
import 'package:flutter_core/resource.dart';
import 'package:flutter_core/result.dart';

class DataBoundResource<T> {
  final ResourceStrategy<T, ResponseWrapper<dynamic>>? remoteStrategy;
  final ResourceStrategy<T, dynamic>? localStrategy;
  final Future Function(ResponseWrapper<dynamic>)? saveCallResult;

  late final Result<T> _result;

  DataBoundResource({
    this.remoteStrategy,
    this.localStrategy,
    this.saveCallResult,
  }) : _result = Result<T>();

  Result<T> build() {
    if (localStrategy != null) {
      _localFetch();
    }

    if (remoteStrategy != null) {
      _remoteFetch();
    }

    return _result;
  }

  Future _remoteFetch() async {
    if ((remoteStrategy is RemoteResourceStrategy) == false) {
      throw Exception(
        "please, use the RemoteBoundResource as remote data resource",
      );
    }

    final wrapper = await remoteStrategy?.fetch?.call();
    if (wrapper == null) {
      _sendError("null wrapper on remoteFetch");
      return;
    }

    final T? response = remoteStrategy?.mapper?.call(wrapper);
    if (response == null) {
      _sendError("null response on remoteFetch");
      return;
    }

    if (wrapper.ok() || wrapper.created()) {
      try {
        _result.send(resource: Resource.success(response));
        return;
      } catch (e) {
        _sendError("remote fetch exception: $e");
      } finally {
        await saveCallResult?.call(wrapper);
      }
    }

    _sendError(wrapper.message ?? "remote fetch exception: $response");
  }

  void _sendError(String message) {
    _result.send(resource: Resource.error(message));
  }

  Future _localFetch() async {
    try {
      final dynamic data = await this.localStrategy?.fetch?.call();
      if (localStrategy?.mapper != null) {
        final T? response = localStrategy?.mapper?.call(data);
        _result.send(resource: Resource.success(response));
        return;
      }

      _result.send(resource: Resource.success(data));
    } catch (e) {
      _sendError(e.toString());
    }
  }
}
