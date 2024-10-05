part of 'user_cubit.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserImagePicked extends UserState {
  final File imageFile;

  UserImagePicked(this.imageFile);
}

class UserLoading extends UserState {}

class UserSaved extends UserState {}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}
