import 'package:capital_one/infrastructure/modelos/datosPersonales.dart';
import 'package:capital_one/infrastructure/modelos/cuenta.dart';
import 'package:capital_one/infrastructure/navigation/routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardController extends GetxController {
  final count = 0.obs;

  // Datos Personales
  final Rx<DatosPersonales> _datosPersonales = DatosPersonales().obs;
  DatosPersonales get datosPersonales => _datosPersonales.value;
  set datosPersonales(value) => _datosPersonales.value = value;

  // Listas reactivas tipadas con todos sus modelos correspondientes
  final cuentasList = <Cuenta>[].obs;
  final movimientosList = <Movimiento>[].obs;
  final comprasList = <Compra>[].obs;
  final salidasDineroList = <SalidaDinero>[].obs;
  final preMovimientosList = <PreMovimiento>[].obs;
  final documentosList = <Documento>[].obs;
  final direccionesList = <Direccion>[].obs;
  final permisosList = <Permiso>[].obs;

  // Balances globales
  final saldoTotal = 0.0.obs;
  final recompensasTotal = 0.0.obs;
  final isLoadingData = false.obs;

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
    cargarTodoElDashboard();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> cargarTodoElDashboard() async {
    isLoadingData.value = true;
    await Future.wait([
      getDatosPersonales(),
      getCuentasYBalances(),
      getMovimientosRecientes(),
      getComprasRecientes(),
      getSalidasDineroRecientes(),
      getPreMovimientosRecientes(),
      getDocumentosUsuario(),
      getDireccionesUsuario(),
      getPermisosUsuario(),
    ]);
    isLoadingData.value = false;
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

  Future<void> getCuentasYBalances() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('cuenta')
          .select('*, tipo:tipo_id(nombre, color)')
          .eq('owner_id', userId);

      final List<Cuenta> cuentas = (response as List)
          .map((item) => Cuenta.fromJson(item))
          .toList();

      cuentasList.assignAll(cuentas);

      double tempSaldo = 0.0;
      double tempRecompensas = 0.0;

      for (var cuenta in cuentas) {
        tempSaldo += cuenta.saldo ?? 0.0;
        tempRecompensas += cuenta.recompensas ?? 0.0;
      }

      saldoTotal.value = tempSaldo;
      recompensasTotal.value = tempRecompensas;
      print("cuentas: ${cuentas}");
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las cuentas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getMovimientosRecientes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final cuentasResponse = await Supabase.instance.client
          .from('cuenta')
          .select('id')
          .eq('owner_id', userId);

      final List<dynamic> cuentaIds = cuentasResponse
          .map((c) => c['id'])
          .toList();
      if (cuentaIds.isEmpty) return;

      final response = await Supabase.instance.client
          .from('movimientos')
          .select(
            '*, tipo:tipo_id(nombre, color), medio:medio_id(nombre, color)',
          )
          .inFilter('cuenta_id', cuentaIds)
          .order('created_at', ascending: false)
          .limit(10);

      final List<Movimiento> movimientos = (response as List)
          .map((item) => Movimiento.fromJson(item))
          .toList();

      movimientosList.assignAll(movimientos);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getComprasRecientes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final cuentasResponse = await Supabase.instance.client
          .from('cuenta')
          .select('id')
          .eq('owner_id', userId);

      final List<dynamic> cuentaIds = cuentasResponse
          .map((c) => c['id'])
          .toList();
      if (cuentaIds.isEmpty) return;

      final response = await Supabase.instance.client
          .from('compras')
          .select(
            '*, medio:medio_id(nombre, color), status:status_id(nombre, color)',
          )
          .inFilter('cuenta_id', cuentaIds)
          .order('created_at', ascending: false)
          .limit(10);

      final List<Compra> compras = (response as List)
          .map((item) => Compra.fromJson(item))
          .toList();

      comprasList.assignAll(compras);
    } catch (e) {
      // Manejo silencioso
    }
  }

  Future<void> getSalidasDineroRecientes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final cuentasResponse = await Supabase.instance.client
          .from('cuenta')
          .select('id')
          .eq('owner_id', userId);

      final List<dynamic> cuentaIds = cuentasResponse
          .map((c) => c['id'])
          .toList();
      if (cuentaIds.isEmpty) return;

      final response = await Supabase.instance.client
          .from('salidas_dinero')
          .select(
            '*, medio:medio_id(nombre, color), status:status_id(nombre, color), tipo:tipo_id(nombre, color)',
          )
          .inFilter('cuenta_id', cuentaIds)
          .order('created_at', ascending: false)
          .limit(10);

      final List<SalidaDinero> salidas = (response as List)
          .map((item) => SalidaDinero.fromJson(item))
          .toList();

      salidasDineroList.assignAll(salidas);
    } catch (e) {
      // Manejo silencioso
    }
  }

  Future<void> getPreMovimientosRecientes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final cuentasResponse = await Supabase.instance.client
          .from('cuenta')
          .select('id')
          .eq('owner_id', userId);

      final List<dynamic> cuentaIds = cuentasResponse
          .map((c) => c['id'])
          .toList();
      if (cuentaIds.isEmpty) return;

      final response = await Supabase.instance.client
          .from('pre_movimiento')
          .select(
            '*, tipo:tipo_id(nombre, color), medio:medio_id(nombre, color), status:status_id(nombre, color)',
          )
          .inFilter('cuenta_id', cuentaIds)
          .order('created_at', ascending: false)
          .limit(10);

      final List<PreMovimiento> preMovimientos = (response as List)
          .map((item) => PreMovimiento.fromJson(item))
          .toList();

      preMovimientosList.assignAll(preMovimientos);
    } catch (e) {
      // Manejo silencioso
    }
  }

  Future<void> getDocumentosUsuario() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('documentos')
          .select('*, tipo:tipo_documento_id(nombre, color)')
          .eq('owner_id', userId);

      final List<Documento> documentos = (response as List)
          .map((item) => Documento.fromJson(item))
          .toList();

      documentosList.assignAll(documentos);
    } catch (e) {
      // Manejo silencioso
    }
  }

  Future<void> getDireccionesUsuario() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('direccion')
          .select()
          .eq('owner_id', userId);

      final List<Direccion> direcciones = (response as List)
          .map((item) => Direccion.fromJson(item))
          .toList();

      direccionesList.assignAll(direcciones);
    } catch (e) {
      // Manejo silencioso
    }
  }

  Future<void> getPermisosUsuario() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('permisos')
          .select()
          .eq('user_id', userId);

      final List<Permiso> permisos = (response as List)
          .map((item) => Permiso.fromJson(item))
          .toList();

      permisosList.assignAll(permisos);
    } catch (e) {
      // Manejo silencioso
    }
  }

  void increment() => count.value++;
}
