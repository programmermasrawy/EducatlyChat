import 'package:educalty_chat/features/authentication/login/di/login_di.dart';
import 'package:educalty_chat/features/authentication/singup/di/signup_di.dart';
import 'package:get_it/get_it.dart';

final di = GetIt.instance;

void initDependencyInjection() {
  LoginDI(di);
  SignUpDI(di);
}
