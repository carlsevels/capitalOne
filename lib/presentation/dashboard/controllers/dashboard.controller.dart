import 'package:capital_one/infrastructure/modelos/datosPersonales.dart';
import 'package:capital_one/infrastructure/navigation/routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardController extends GetxController {
  final count = 0.obs;

  final Rx<DatosPersonales> _datosPersonales = DatosPersonales().obs;
  DatosPersonales get datosPersonales => _datosPersonales.value;
  set datosPersonales(value) => _datosPersonales.value = value;

  // Getter opcional para facilitar el nombre completo en la vista
  String get nombreCompleto {
    final nombre = _datosPersonales.value.nombre ?? '';
    final apellidoP = _datosPersonales.value.apellidoPaterno ?? '';
    final apellidoM = _datosPersonales.value.apellidoMaterno ?? '';

    final full = '$nombre $apellidoP $apellidoM'.trim();
    return full.isEmpty ? 'Cargando...' : full;
  }

  @override
  void onInit() {
    super.onInit();
    getDatosPersonales();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAndToNamed(Routes.LOGIN);
  }

  Future<void> getDatosPersonales() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('datos_personales')
          .select()
          .eq('owner_id', userId)
          .single();

      _datosPersonales.value = DatosPersonales.fromJson(response);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los datos personales: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void increment() => count.value++;
}
