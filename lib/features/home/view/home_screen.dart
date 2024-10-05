import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educalty_chat/core/constants/constants.dart';
import 'package:educalty_chat/features/authentication/login/data/repo/login_repo.dart';
import 'package:educalty_chat/features/authentication/login/view/screen/login_screen.dart';
import 'package:educalty_chat/features/chat/view/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<UserModel>> _fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();
    var users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc.data(), doc.id)).toList();
    users.removeWhere((element) => element.phone== _auth.currentUser!.phoneNumber,);
    return users;
  }

  void _logout() async {
    LoginRepo.signOut(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User List", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: ChatAppColors.white,
            ),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => ChatScreen(user: user)),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: ChatAppColors.lightColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: ChatAppColors.lightColor,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: user.profileImage != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.profileImage!),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      user.name,
                      style: const TextStyle(color: Colors.white), // White text for dark background
                    ),
                    subtitle: Text(
                      "Age: ${user.age}",
                      style: const TextStyle(color: Colors.grey), // Lighter color for subtitle
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.black, // Overall dark background for the screen
    );
  }
}
