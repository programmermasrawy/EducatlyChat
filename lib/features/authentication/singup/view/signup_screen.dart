import 'dart:io';

import 'package:educalty_chat/di/injection_container.dart';
import 'package:educalty_chat/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/user/user_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<UserCubit>(),
      child: Scaffold(
        backgroundColor: Colors.black, // Dark background
        appBar: AppBar(
          title: const Text("Create New User", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: BlocConsumer<UserCubit, UserState>(
              listener: (context, state) {
                if (state is UserSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User saved successfully')),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                } else if (state is UserError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                File? imageFile;
                if (state is UserImagePicked) {
                  imageFile = state.imageFile;
                }

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.read<UserCubit>().pickImage(),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: imageFile != null ? FileImage(imageFile) : null,
                        child: imageFile == null ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey) : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(color: Colors.white),
                        // White label for visibility
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[800], // Dark input field background
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: "Age",
                        labelStyle: TextStyle(color: Colors.white),
                        // White label for visibility
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[800], // Dark input field background
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<UserCubit>().saveUser(nameController.text, ageController.text, imageFile);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button color
                      ),
                      child: const Text("Save User"),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
