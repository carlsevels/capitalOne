import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  var initialRoute = await Routes.initialRoute;
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCSPUToL9-oQGCKsD6AEydwohXXHCXftYg",
      appId: "1:415067081496:web:98eaab58364d3f5f002c6d",
      messagingSenderId: "415067081496",
      projectId: "bceinteractivo",
      authDomain: "bceinteractivo.firebaseapp.com",
      storageBucket: "bceinteractivo.firebasestorage.app",
      measurementId: "G-8WHLQ0HDF4",
    ),
  );
  try {
    await Supabase.initialize(
      url: 'https://xsbefubqenbsybeupeal.supabase.co',
      anonKey: 'sb_publishable_UvxcUEUk8PCPKhKkXN1Fuw_JrRXkyri',
    );
    print("Conexion exitosa");
  } catch (e) {
    print("Error al conctar con el servidor");
  }
  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  Main(this.initialRoute);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: initialRoute,
      getPages: Nav.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
