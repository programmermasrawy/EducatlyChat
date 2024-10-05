class UserModel {
  final String id;
  final String name;
  final String phone;
  final int age;
  final String? profileImage;

  UserModel({required this.id, required this.name, required this.age, required this.phone, this.profileImage});

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      profileImage: data['profileImage'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}
