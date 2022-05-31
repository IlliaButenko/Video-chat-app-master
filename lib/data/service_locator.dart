import 'package:OCWA/data/services.dart';
import 'package:get_it/get_it.dart';
import 'storage_service.dart';

GetIt locator = GetIt.instance;
setupServiceLocator() {
  locator.registerLazySingleton<Services>(() => StorageServiceSharedPreferences());
}