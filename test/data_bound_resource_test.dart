import 'dart:io';

import 'package:flutter_core/data_bound_resource.dart';

import 'package:flutter_core/datasources/local/local_resource_strategy.dart';
import 'package:flutter_core/datasources/remote/remote_resource_trategy.dart';
import 'package:flutter_core/datasources/remote/response/response_wrapper.dart';
import 'package:flutter_core/resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'data_bound_resource_test.mocks.dart';
import 'model/dummy_entity.dart';

@GenerateNiceMocks([MockSpec<DatabaseProviderImpl>()])
import 'package:flutter_core/datasources/local/database/database_provider_impl.dart';

import 'model/dummy_model.dart';

final List<DummyEntity> dummyEntityList = [
  DummyEntity(1, "dummy1"),
  DummyEntity(2, "dummy2"),
  DummyEntity(3, "dummy3"),
  DummyEntity(4, "dummy4"),
];

void main() {
  test(
    'DataBoundResource should send the database result when the query finish',
    () async {
      var database = MockDatabaseProviderImpl();
      when(
        database.getAll(
          table: DummyTable.tableName,
          fromMap: DummyEntity.fromMap,
        ),
      ).thenAnswer((realInvocation) async => dummyEntityList);

      final dataBoundResource = DataBoundResource<List<DummyEntity>>(
        localStrategy: LocalResourceStrategy.handler(
          query: () async {
            final result = await database.getAll<DummyEntity>(
              table: DummyTable.tableName,
              fromMap: DummyEntity.fromMap,
            );
            return result ?? [];
          },
        ),
      ).build();
      final resource = await dataBoundResource.localCompleter;
      assert(resource.data is List<DummyEntity>);
    },
  );

  test(
    'should not be possible to return the network result without mapping',
    () async {
      final dataBoundResource = DataBoundResource<List<DummyEntity>>(
        remoteStrategy: RemoteResourceStrategy<List<DummyEntity>>.handler(
          fetch: () async {
            return ResponseWrapper(
              status: HttpStatus.ok,
              data: dummyEntityList,
            );
          },
          // mapServiceResult: (wrapper) => wrapper.data,
        ),
      ).build();
      final resource = await dataBoundResource.networkCompleter;
      expect(resource.status, Status.error);
    },
  );

  test(
    'DataBoundResource should send the network result when the fetch finish',
    () async {
      final dataBoundResource = DataBoundResource<List<DummyEntity>>(
        remoteStrategy: RemoteResourceStrategy<List<DummyEntity>>.handler(
          fetch: () async {
            return ResponseWrapper(
              status: HttpStatus.ok,
              data: dummyEntityList,
            );
          },
          mapServiceResult: (wrapper) => wrapper.data,
        ),
      ).build();
      final resource = await dataBoundResource.networkCompleter;
      assert(resource.data is List<DummyEntity>);
    },
  );

  test(
    'Should save the network call result when `saveCallResult` DataBoundResource method is implemented',
    () async {
      var database = MockDatabaseProviderImpl();
    },
  );
}
