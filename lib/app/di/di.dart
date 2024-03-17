import 'package:get_it/get_it.dart';
import 'package:shared/shared.dart';

final getIt = GetIt.instance;

void setupDi({required AppFlavor appFlavor}) {
  getIt.registerSingleton<AppFlavor>(appFlavor);
}
