abstract class ResourceStrategy<T, Y> {
  Future<Y>? Function()? fetch;
  Future<Y>? Function(dynamic)? send;
  T Function(Y)? mapper;

  ResourceStrategy.build({
    this.fetch,
    this.mapper,
    this.send,
  });
}

abstract class FutureResourceStrategy<T, Y> {
  T Function(Y) mapper;

  FutureResourceStrategy.build({required this.mapper});
}
