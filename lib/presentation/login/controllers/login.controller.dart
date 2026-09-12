import 'package:capital_one/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  final supabase = Supabase.instance.client;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmail() async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final User? user = res.user;

      if (user != null) {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e) {
      Get.snackbar(
        'Error de Autenticación',
        'Credenciales inválidas o error en el servidor.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
