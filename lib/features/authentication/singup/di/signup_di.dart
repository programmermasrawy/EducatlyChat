import 'package:educalty_chat/features/authentication/singup/data/repo/user_repository.dart';
import 'package:educalty_chat/features/authentication/singup/logic/user/user_cubit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

class SignUpDI {
  final GetIt di;

  SignUpDI(this.di) {
    call();
  }

  void call() {
    di
      ..registerFactory(() => UserCubit(di()))
      ..registerFactory(() => ImagePicker())
      ..registerFactory(() => FirebaseStorage.instance)
      ..registerFactory(() => UserRepository(di(), di()));
  }
}
