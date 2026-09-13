import 'package:capital_one/infrastructure/navigation/routes.dart';
import 'package:capital_one/presentation/login/controllers/login.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Color(0xFFF4F6F9),
        shadowColor: Colors.black,
        backgroundColor: const Color(0xFFF4F6F9),
        elevation: 0,
        title: Container(
          height: 50,
          child: Image.asset('logos/besideChico.png'),
        ),
        centerTitle: false,
      ),
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 650;

              return Center(
                child: Container(
                  width: isDesktop ? 480 : double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 48,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E5ED),
                      width: 1,
                    ),
                    boxShadow: [
                      if (isDesktop)
                        BoxShadow(
                          color: const Color(0xFF0A192F).withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 200,
                        child: Image.asset('logos/beside.png'),
                      ),

                      const SizedBox(height: 36),
                      const Text(
                        'Ingresa tus credenciales para registrar tu perfil seguro.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7A90),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Correo Electrónico',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334E68),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          hintText: 'nombre@correo.com',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9FB3C8),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: Color(0xFF627D98),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0F2942),
                              width: 1.5,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Contraseña de Acceso',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334E68),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => TextField(
                          controller: controller.passwordController,
                          decoration: InputDecoration(
                            hintText: 'Mínimo 8 caracteres',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9FB3C8),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF627D98),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                controller.isObscureText.value =
                                    !controller.isObscureText.value;
                              },
                              icon: Icon(
                                controller.isObscureText.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Color(0xFF627D98),
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF0F2942),
                                width: 1.5,
                              ),
                            ),
                          ),
                          obscureText: controller.isObscureText.value
                              ? false
                              : true,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          controller.signInWithEmail();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: const Color(0xFF0F2942),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿Ya posees una cuenta?',
                            style: TextStyle(
                              color: Color(0xFF6B7A90),
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Get.toNamed('/login');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0F2942),
                            ),
                            child: const Text(
                              'Ingresar aquí',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
