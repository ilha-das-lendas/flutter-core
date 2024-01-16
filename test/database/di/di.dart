import 'package:flutter_core/datasources/local/database/dao/data_access_object.dart';
import 'package:flutter_core/datasources/local/database/dao/data_access_object_impl.dart';
import 'package:flutter_core/datasources/local/database/provider/database_provider.dart';
import 'package:get_it/get_it.dart';

import '../database_provider_impl_t.dart';

final getIt = GetIt.instance;

void setupDatabaseDi() {
  getIt.registerSingleton<DatabaseProvider>(
    DatabaseProviderImplTest(),
  );

  getIt.registerSingleton<DataAccessObject>(
    DataAccessObjectImpl(getIt.get()),
  );
}
