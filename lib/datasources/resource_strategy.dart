abstract class ResourceStrategy<Result, Raw> {
  Result Function(Raw) mapper;

  ResourceStrategy.build({required this.mapper});
}
