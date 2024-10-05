import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/user_repository.dart';

part 'user_state.dart';
class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  UserCubit(this._userRepository) : super(UserInitial());

  Future<void> pickImage() async {
    final imagePath = await _userRepository.pickImage();
    if (imagePath != null) {
      emit(UserImagePicked(File(imagePath)));
    } else {
      emit(UserError('Failed to pick an image.'));
    }
  }

  Future<void> saveUser(String name, String ageString, File? imageFile) async {
    if (name.isEmpty) {
      emit(UserError("Name is required"));
      return;
    }
    final age = int.tryParse(ageString);
    if (age == null || age <= 0) {
      emit(UserError("Please enter a valid age"));
      return;
    }
    if (imageFile == null) {
      emit(UserError("Image is required"));
      return;
    }

    emit(UserLoading());

    try {
      final imageUrl = await _userRepository.uploadImage(imageFile);
      if (imageUrl != null) {
        await _userRepository.saveUser(name, age, imageUrl);
        emit(UserSaved());
      } else {
        emit(UserError("Failed to upload image"));
      }
    } catch (e) {
      emit(UserError("Error saving user: $e"));
    }
  }
}
