import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teladelogin/repositors/authRepository.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final showPassword = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isFacebookLoading = false.obs;

  Future<void> login() async {
    try {
      isLoading.value = true;
      if (loginFormKey.currentState!.validate()) {
        isLoading.value = false;
        return;
      }
      final auth = Authrepository.instance;
      String? error = await auth.loginWithEmailAndPassword(email.text.trim(),password.text.trim());
      auth.setInitScreen(auth.firebaseUser);
      if (error != null) {
        Get.showSnackbar(GetSnackBar(message: error.toString(),));
      }
    
      
          