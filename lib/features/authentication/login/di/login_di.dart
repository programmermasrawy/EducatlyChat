import 'package:get_it/get_it.dart';

import '../data/repo/login_repo.dart';
import '../logic/login_cubit.dart';

class LoginDI {
  final GetIt di;

  LoginDI(this.di, {LoginRepo? repo}) {
    call();
  }

  void call() {
    di
      ..registerFactory(() => LoginCubit(di()))
      ..registerFactory(() => LoginRepo());
  }
}
