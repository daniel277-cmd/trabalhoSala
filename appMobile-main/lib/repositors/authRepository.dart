import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Authrepository extends GetxController {
  static Authrepository get instance => Get.find();

final FirebaseAuth _auth = FirebaseAuth.instance;
late final Rx<User?> _firebaseUser;
var verificationId = ''.obs;

User? get user => _firebaseUser.value;

  @override
void onReady() {
  super.onReady();
  _firebaseUser = Rx<User?>(_auth.currentUser);
  _firebaseUser.bindStream(_auth.userChanges());
  setInitScreen(_firebaseUser.value);
}

void setInitScreen(User? user) {
  if (user == null) {
    Get.offAll(() => HomeScreen());
  } else if (user.emailVerified) {
    Get.offAll(() => const ProfileScreen());
  } else {
    Get.offAll(() => const ProfileScreen());
  }
}
