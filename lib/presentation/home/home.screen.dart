import 'package:capital_one/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F9),
        title: const Text('HomeScreen'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              style: ButtonStyle(
                shadowColor: MaterialStateColor.resolveWith((states) {
                  return Colors.white;
                }),
              ),
              onPressed: () {Get.toNamed(Routes.LOGIN);},
              child: Text(
                "Iniciar sesion",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.REGISTER);
              },
              child: Text(
                "Crear cuenta",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) {
                  return Colors.blue;
                }),
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: const Center(
        child: Text('HomeScreen is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
