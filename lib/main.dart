import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  var initialRoute = await Routes.initialRoute;
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
    return GetMaterialApp(initialRoute: initialRoute, getPages: Nav.routes);
  }
}
