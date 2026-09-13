import 'dart:convert';

import 'package:capital_one/infrastructure/modelos/cuenta.dart';
import 'package:capital_one/infrastructure/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardController extends GetxController {
  final count = 0.obs;

  // Datos Personales
  final Rx<DatosPersonales> _datosPersonales = DatosPersonales().obs;
  DatosPersonales get datosPersonales => _datosPersonales.value;
  set datosPersonales(value) => _datosPersonales.value = value;
  String? userIdSeleccionado;
  var mediosList = <Medio>[].obs;
  final RxnInt medioSeleccionadoId = RxnInt();

  //Transferencia
  final TextEditingController cuentaController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController conceptoController = TextEditingController();

  Map<String, dynamic>? cuentaEncontradaData;
  bool isLoadingCuenta = false;

  // Listas reactivas tipadas con todos sus modelos correspondientes
  final cuentasList = <Cuenta>[].obs;
  final movimientosList = <Movimiento>[].obs;
  final comprasList = <Compra>[].obs;
  final salidasDineroList = <SalidaDinero>[].obs;
  final preMovimientosList = <PreMovimiento>[].obs;
  final documentosList = <Documento>[].obs;
  final direccionesList = <Direccion>[].obs;
  final permisosList = <Permiso>[].obs;
  final parentescos = <Parentesco>[].obs;
  final parentescosOne = Parentesco().obs;

  // Variables y catálogos para vinculación de cuentas (permisos y parentescos)
  final parentescosList = <Parentesco>[].obs;
  final cuentasEncontradas = <Cuenta>[].obs;
  final buscadorCuentaController = TextEditingController();
  final Rxn<Cuenta> cuentaSeleccionada = Rxn<Cuenta>();
  final Rxn<Parentesco> parentescoSeleccionado = Rxn<Parentesco>();

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
    cargarParentescos();
    cargarTodoElDashboard();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    buscadorCuentaController.dispose();
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
      getDocumentosUsuario(),
      getDireccionesUsuario(),
      getPermisosUsuario(),
      getParentesco(),
      getMediosTransferencia(),
      preMovimientosPorAprobar(),
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
      print(cuentasList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las cuentas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print("Error al cargar cuenta: $e");
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
      // Manejo silencioso
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

  Future<void> getParentesco() async {
    try {
      final response = await Supabase.instance.client
          .from('parentescos')
          .select();

      final List<Parentesco> lista = (response as List).map((item) {
        return Parentesco.fromJson(item);
      }).toList();

      parentescos.assignAll(lista);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los parentescos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getParentescoAsignado(int parentescoId) async {
    try {
      final response = await Supabase.instance.client
          .from('parentescos')
          .select()
          .eq('id', parentescoId)
          .single();

      parentescosOne.value = Parentesco.fromJson(response);
      print("parentescosOne.value: ${jsonEncode(parentescosOne.value)}");
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar el parentesco: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> realizarTransferencia({
    required int cuentaId,
    required int cuentaDestinoId,
    required double cantidad,
    required String descripcion,
    required int medioId,
  }) async {
    try {
      // 1. Validaciones básicas de negocio
      if (cuentaId == cuentaDestinoId) {
        Get.snackbar(
          'Error',
          'La cuenta de origen y destino no pueden ser la misma',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (cantidad <= 0) {
        Get.snackbar(
          'Error',
          'La cantidad debe ser mayor a cero',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final supabase = Supabase.instance.client;

      // 2. Buscar quién tiene permiso sobre MI CUENTA (cuenta de origen)
      final permiso = await supabase
          .from('permisos')
          .select('user_id')
          .eq('cuenta_id', cuentaId)
          .limit(1)
          .maybeSingle();

      if (permiso == null || permiso['user_id'] == null) {
        Get.snackbar(
          'Error',
          'No se encontró un usuario con permiso para aprobar esta cuenta',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final String userId = permiso['user_id'].toString();

      // 3. Obtener el id bigint de datos_personales basado en el owner_id del usuario con permisos
      final datosPersonales = await supabase
          .from('datos_personales')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();

      if (datosPersonales == null || datosPersonales['id'] == null) {
        Get.snackbar(
          'Error',
          'No se encontró el usuario en datos personales',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final int userPorAprobarId = (datosPersonales['id'] as num).toInt();

      print('Mi cuenta (origen): $cuentaId');
      print('Cuenta destino: $cuentaDestinoId');
      print('Usuario del permiso: $userId');
      print('Usuario por aprobar ID: $userPorAprobarId');

      // 4. Crear pre-movimiento vinculado a la cuenta origen (cuentaId)
      // Nota: Si tu lógica requiere guardar la cuenta destino, considera agregar
      // una columna 'cuenta_destino_id' en tu tabla pre_movimiento.
      await supabase.from('pre_movimiento').insert({
        'cuenta_id': cuentaId,
        'cantidad': cantidad,
        'descripcion': descripcion,
        'medio_id': medioId,
        'user_por_aprobar_id': userPorAprobarId,
      });

      Get.snackbar(
        'Éxito',
        'Transferencia registrada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      await preMovimientosPorAprobar();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo completar la transferencia: $e',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('Error al registrar pre-movimiento: $e');
    }
  }

  Future<void> getMediosTransferencia() async {
    try {
      final response = await Supabase.instance.client
          .from('medios')
          .select('id, nombre')
          .inFilter('id', [1, 7, 8, 9, 10]);

      mediosList.assignAll(
        (response as List).map((item) => Medio.fromJson(item)).toList(),
      );

      if (mediosList.isNotEmpty && medioSeleccionadoId.value == null) {
        medioSeleccionadoId.value = mediosList.first.id;
        print("mediosList: $mediosList");
      }
    } catch (e) {
      print('Error al cargar medios: $e');
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
    } catch (e) {}
  }

  Future<void> getPermisosUsuario() async {
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
          .from('permisos')
          .select('*, parentescos:parentescos(nombre)')
          .inFilter('cuenta_id', cuentaIds);

      final List<Permiso> permisos = (response as List)
          .map((item) => Permiso.fromJson(item))
          .toList();

      permisosList.assignAll(permisos);
      print("jsonEncode(permisosList): ${jsonEncode(permisosList)}");
    } catch (e) {
      print('Error al cargar permisos: $e');
    }
  }

  Future<void> getDatosCuentaVinculada(String owner_id) async {
    final response = await Supabase.instance.client
        .from('datos_personales')
        .select()
        .eq('owner_id', owner_id)
        .single();

    _datosPersonales.value = DatosPersonales.fromJson(response);
    print(_datosPersonales);
  }

  Future<void> cargarParentescos() async {
    try {
      final response = await Supabase.instance.client
          .from('parentescos')
          .select('*');
      parentescosList.value = (response as List)
          .map((e) => Parentesco.fromJson(e))
          .toList();
    } catch (e) {
      print('Error al cargar parentescos: $e');
    }
  }

  Future<void> buscarCuentas(String query) async {
    if (query.isEmpty) {
      cuentasEncontradas.clear();
      return;
    }
    try {
      final response = await Supabase.instance.client
          .from('cuenta')
          .select('*, tipo:tipo_id(nombre, color)')
          .ilike('apodo', '%$query%');

      cuentasEncontradas.value = (response as List)
          .map((e) => Cuenta.fromJson(e))
          .toList();
    } catch (e) {
      print('Error al buscar cuentas: $e');
    }
  }

  Future<void> restarSaldoCuentaOrigen(double cantidadARestar) async {
    try {
      final cuentaActual = cuentaSeleccionada.value;
      if (cuentaActual == null || cuentaActual.id == null) return;

      final double saldoActual = (cuentaActual.saldo ?? 0.0).toDouble();
      final double nuevoSaldo = saldoActual - cantidadARestar;

      await Supabase.instance.client
          .from('cuenta')
          .update({'saldo': nuevoSaldo})
          .eq('id', cuentaActual.id!);

      cuentaSeleccionada.update((val) {
        if (val != null) val.saldo = nuevoSaldo;
      });
    } catch (e) {
      print('Error al restar saldo de la cuenta origen: $e');
      Get.snackbar(
        'Error',
        'No se pudo descontar el saldo de la cuenta: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> sumarSaldoCuentaDestino(
    int cuentaDestinoId,
    double cantidadASumar,
  ) async {
    try {
      // 1. Obtenemos el saldo actual de la cuenta destino directamente de Supabase
      final response = await Supabase.instance.client
          .from('cuenta')
          .select('saldo')
          .eq('id', cuentaDestinoId)
          .single();

      final double saldoActual = (response['saldo'] as num).toDouble();
      final double nuevoSaldo = saldoActual + cantidadASumar;

      await Supabase.instance.client
          .from('cuenta')
          .update({'saldo': nuevoSaldo})
          .eq('id', cuentaDestinoId);
    } catch (e) {
      print('Error al sumar saldo a la cuenta destino: $e');
      Get.snackbar(
        'Error',
        'No se pudo abonar el saldo a la cuenta destino: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> guardarVinculacion({
    required String userIdSeleccionado,
    required int cuentaId,
    required int parentescoId,
  }) async {
    try {
      await Supabase.instance.client.from('permisos').insert({
        'user_id': userIdSeleccionado,
        'cuenta_id': cuentaId,
        'parentesco_id': parentescoId,
      });

      Get.snackbar(
        'Éxito',
        'Cuenta vinculada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      this.userIdSeleccionado = null;
      cuentaSeleccionada.value = null;
      parentescoSeleccionado.value = null;
      buscadorCuentaController.clear();
      cuentasEncontradas.clear();
      await getPermisosUsuario();
    } catch (e) {
      print('Error al vincular: $e');
      Get.snackbar(
        'Error',
        'No se pudo completar la vinculación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> guardarPermiso({
    required String userId,
    required int cuentaId,
    required int parentescoId,
  }) async {
    try {
      await Supabase.instance.client.from('permisos').insert({
        'user_id': userId,
        'cuenta_id': cuentaId,
        'parentesco_id': parentescoId,
      });

      Get.snackbar(
        'Éxito',
        'Usuario vinculado correctamente a la cuenta.',
        snackPosition: SnackPosition.BOTTOM,
      );
      await getPermisosUsuario();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el permiso: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> preMovimientosPorAprobar() async {
    try {
      final supabase = Supabase.instance.client;

      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        preMovimientosList.clear();
        return;
      }

      final permisosRes = await supabase
          .from('permisos')
          .select('cuenta_id, user_id')
          .eq('user_id', userId);

      if ((permisosRes as List).isEmpty) {
        preMovimientosList.clear();

        print('El usuario no tiene permisos sobre ninguna cuenta');

        return;
      }

      // 2. Obtener los cuenta_id
      final List<int> cuentaIds = permisosRes
          .map((permiso) => permiso['cuenta_id'])
          .where((id) => id != null)
          .map((id) => (id as num).toInt())
          .toList();

      // 3. Obtener los user_id de los permisos
      final List<String> usuariosConPermiso = permisosRes
          .map((permiso) => permiso['user_id']?.toString())
          .where((id) => id != null)
          .cast<String>()
          .toList();

      print('Usuario actual: $userId');
      print('Cuentas con permiso: $cuentaIds');
      print('Usuarios de permisos: $usuariosConPermiso');

      if (cuentaIds.isEmpty || usuariosConPermiso.isEmpty) {
        preMovimientosList.clear();
        return;
      }

      // 4. Obtener pre-movimientos de esas cuentas
      //    cuyo user_por_aprobar_id corresponde a un usuario
      //    registrado en permisos
      final response = await supabase
          .from('pre_movimiento')
          .select('''
          *,
          cuenta:cuenta_id(
            apodo,
            saldo
          ),
          medio:medio_id(
            nombre
          )
        ''')
          .inFilter('cuenta_id', cuentaIds)
          .inFilter('user_por_aprobar_id', usuariosConPermiso)
          .eq('status_id', 1)
          .order('created_at', ascending: false);

      final List<PreMovimiento> listaMapeada = (response as List)
          .map((item) => PreMovimiento.fromJson(item as Map<String, dynamic>))
          .toList();

      preMovimientosList.assignAll(listaMapeada);

      print('Pre-movimientos por aprobar: ${listaMapeada.length}');
      print('Pre-movimientos: $response');
    } catch (e) {
      print('Error al cargar pre-movimientos por aprobar: $e');
    }
  }

  void increment() => count.value++;
}
