import 'package:flutter/foundation.dart';
import 'package:flutter_core/datasources/remote/remote_resource_trategy.dart';
import 'package:flutter_core/datasources/remote/response/response_wrapper.dart';
import 'package:flutter_core/datasources/resource_strategy.dart';
import 'package:flutter_core/resource.dart';
import 'package:flutter_core/result.dart';

class FutureDataBoundResource<T> {
  final RemoteResourceStrategy<T, ResponseWrapper<dynamic>>? remoteStrategy;
  final LocalResourceStrategy<T, dynamic>? localStrategy;
  final Future Function(ResponseWrapper<dynamic>)? saveCallResult;

  FutureDataBoundResource.factory({
    this.remoteStrategy,
    this.localStrategy,
    this.saveCallResult,
  }) {
    _localFetch();
    _remoteFetch();
  }

  void _remoteFetch() async {
    final wrapper = await remoteStrategy?.fetch?.call();
    if (wrapper == null) {
      _sendError("null wrapper on remoteFetch", DataSource.network);
      return;
    }

    final T? response = await remoteStrategy?.mapper.call(wrapper);
    if (response == null) {
      _sendError("null response on remoteFetch", DataSource.network);
      return;
    }

    if (wrapper.ok() || wrapper.created()) {
      try {
        final T? response = await remoteStrategy?.mapper.call(wrapper);
        await remoteStrategy?.callback?.call(Resource.success(response));
        return;
      } catch (e) {
        if (wrapper.message != null) {
          _sendError(
            "remote fetch exception: ${wrapper.message}",
            DataSource.network,
          );
          return;
        }
        _sendError("remote fetch exception: $e", DataSource.network);
      } finally {
        // await saveCallResult?.call(wrapper);
      }
    }

    _sendError(
      wrapper.message ?? "remote fetch exception: $response",
      DataSource.network,
    );
  }

  Future _localFetch() async {
    try {
      final dynamic data = await this.localStrategy?.get?.call();
      if (localStrategy?.mapper != null) {
        final dynamic response = await localStrategy?.mapper.call(data);
        await localStrategy?.callback?.call(Resource.success(response));
        return;
      }

      await localStrategy?.callback?.call(Resource.success(data));
    } catch (e) {
      _sendError(e.toString(), DataSource.database);
    }
  }

  void _sendError(String message, DataSource dataSource) {
    if (kDebugMode) {
      print(message);
    }
    // _result.send(resource: Resource.error(message), dataSource: dataSource);
  }
}

class RemoteResourceStrategy<Result, Response>
    extends FutureResourceStrategy<Result, Response> {
  Future<Response>? Function()? fetch;
  Future<void>? Function(Resource<Result>)? callback;

  RemoteResourceStrategy.build({
    required super.mapper,
    this.fetch,
    this.callback,
  }) : super.build();
}

class LocalResourceStrategy<Result, Raw> extends FutureResourceStrategy<Result, Raw> {
  Future<Raw?> Function()? get;
  Future<void>? Function(Resource<Result>)? callback;

  LocalResourceStrategy.build({
    required super.mapper,
    this.callback,
    this.get,
  }) : super.build();
}
