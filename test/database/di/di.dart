import 'package:flutter_core/datasources/local/database/dao/data_access_object.dart';
import 'package:flutter_core/datasources/local/database/dao/data_access_object_impl.dart';
import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:get_it/get_it.dart';

import '../database_provider_test_impl.dart';

final getIt = GetIt.instance;

void setupDatabase() {
  getIt.registerSingleton<DatabaseProvider>(
    DatabaseProviderTestImpl(),
  );

  getIt.registerSingleton<DataAccessObject>(
    DataAccessObjectImpl(getIt.get()),
  );
}
