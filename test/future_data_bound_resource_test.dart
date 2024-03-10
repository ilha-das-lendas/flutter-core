@GenerateNiceMocks([MockSpec<DataAccessObjectImpl>()])
import 'package:flutter_core/datasources/local/database/dao/data_access_object_impl.dart';
import 'package:flutter_core/datasources/remote/response/response_wrapper.dart';

@GenerateNiceMocks([MockSpec<ServiceImpl>()])
import 'package:flutter_core/datasources/remote/service/service_impl.dart';

import 'package:flutter_core/future_data_bound_resource.dart';
import 'package:flutter_core/resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'database/di/di.dart';
import 'database/model/dummy_entity.dart';
import 'future_data_bound_resource_test.mocks.dart';
import 'model/dummy_model.dart';

final List<DummyEntity> dummyEntityList = [
  DummyEntity(1, "dummy1"),
  DummyEntity(2, "dummy2"),
  DummyEntity(3, "dummy3"),
  DummyEntity(4, "dummy4"),
];
final List<DummyModel> dummyModelList = [
  DummyModel(1, "dummy1"),
  DummyModel(2, "dummy2"),
  DummyModel(3, "dummy3"),
  DummyModel(4, "dummy4"),
];

void main() {
  setUpAll(() {
    setupDatabase();
  });

  group("Future data bound resource unit test", () {
    test(
      'DataBoundResource should send the database result when the query finish',
      () async {
        var database = MockDataAccessObjectImpl();
        when(
          database.getAll(
            table: DummyTable.tableName,
            toEntity: DummyEntity.fromMap,
          ),
        ).thenAnswer((realInvocation) async => dummyEntityList);

        var service = MockServiceImpl();
        when(service.get("dummies")).thenAnswer(
          (realInvocation) async => ResponseWrapper(
            status: 200,
            data: dummyModelList,
          ),
        );

        final dataBoundResource = FutureDataBoundResource.factory(
          remoteStrategy: RemoteResourceStrategy<List<DummyModel>, ResponseWrapper<List<DummyModel>>>.build(
              mapper: (raw) => raw.data ?? [],
              fetch: () async {
                return await service.get("dummies");
              },
              callback: (result) {
                print(result);
              }
          ),
          localStrategy: LocalResourceStrategy.build(
            get: () async {
              final List<DummyEntity>? result =
              await database.getAll<DummyEntity>(
                table: DummyTable.tableName,
                toEntity: DummyEntity.fromMap,
              );

              return result;
            },
            mapper: (result) async {
              final mResult = result as List<DummyEntity>;
              return mResult.map((e) => e.toModel());
            },
            callback: (data) {
              expect(data.status.isSuccessful(), true);
            },
          ),
        );

        await Future.delayed(const Duration(seconds: 5));
      },
    );
  });
}
