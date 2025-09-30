import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String fullName;
  final String email;
  final String celular;
  final String password;

  const User({
    this.id,
    required this.fullName,
    required this.email,
    required this.celular,
    required this.password,
  });

  toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "celular": celular,
      "password": password,
    };
  }

  factory User.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return User(
      id: document.id,
      email: data["Email"],
      fullName: data["FullName"],
      password: data["Password"],
      celular: data["Celular"],
    );
  }
}
