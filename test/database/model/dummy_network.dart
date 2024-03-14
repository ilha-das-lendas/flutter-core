import '../../model/dummy_model.dart';

class DummyNetwork {
  final int id;
  final String self;

  DummyNetwork(this.id, this.self);
}

extension DummyNetworkExtension on DummyNetwork {
  DummyModel toModel() => DummyModel(id, self);
}
