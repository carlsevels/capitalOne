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

  final Rx<DatosPersonales> _datosPersonalesCuentaVinculada =
      DatosPersonales().obs;
  DatosPersonales get datosPersonalesCuentaVinculada =>
      _datosPersonalesCuentaVinculada.value;
  set datosPersonalesCuentaVinculada(value) =>
      _datosPersonalesCuentaVinculada.value = value;

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

  Future<void> aprobarTransferencia(int preMovimientoId) async {
    try {
      final supabase = Supabase.instance.client;

      final preMovimiento = await supabase
          .from('pre_movimiento')
          .select()
          .eq('id', preMovimientoId)
          .eq('status_id', 1)
          .maybeSingle();

      if (preMovimiento == null) {
        Get.snackbar(
          'Error',
          'La transferencia ya no está pendiente de aprobación',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final int cuentaOrigenId = (preMovimiento['cuenta_id'] as num).toInt();

      final int cuentaDestinoId = (preMovimiento['cuenta_destino_id'] as num)
          .toInt();

      final double cantidad = (preMovimiento['cantidad'] as num).toDouble();

      final int medioId = (preMovimiento['medio_id'] as num).toInt();

      final String descripcion =
          preMovimiento['descripcion']?.toString() ?? 'Transferencia bancaria';

      if (cantidad <= 0) {
        Get.snackbar(
          'Error',
          'La cantidad de la transferencia no es válida',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (cuentaOrigenId == cuentaDestinoId) {
        Get.snackbar(
          'Error',
          'La cuenta de origen y destino no pueden ser la misma',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final cuentaOrigen = await supabase
          .from('cuenta')
          .select('saldo')
          .eq('id', cuentaOrigenId)
          .maybeSingle();

      final cuentaDestino = await supabase
          .from('cuenta')
          .select('saldo')
          .eq('id', cuentaDestinoId)
          .maybeSingle();

      if (cuentaOrigen == null || cuentaDestino == null) {
        Get.snackbar(
          'Error',
          'No se encontraron las cuentas de la transferencia',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final double saldoOrigen =
          (cuentaOrigen['saldo'] as num?)?.toDouble() ?? 0.0;

      final double saldoDestino =
          (cuentaDestino['saldo'] as num?)?.toDouble() ?? 0.0;

      if (saldoOrigen < cantidad) {
        Get.snackbar(
          'Error',
          'La cuenta de origen no tiene saldo suficiente',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final double nuevoSaldoOrigen = saldoOrigen - cantidad;
      final double nuevoSaldoDestino = saldoDestino + cantidad;

      await supabase
          .from('cuenta')
          .update({'saldo': nuevoSaldoOrigen})
          .eq('id', cuentaOrigenId);

      await supabase
          .from('cuenta')
          .update({'saldo': nuevoSaldoDestino})
          .eq('id', cuentaDestinoId);

      await supabase.from('movimientos').insert([
        {
          'cuenta_id': cuentaOrigenId,
          'cantidad': -cantidad,
          'descripcion': descripcion,
          'medio_id': medioId,
          'tipo_id': 2,
        },
        {
          'cuenta_id': cuentaDestinoId,
          'cantidad': cantidad,
          'descripcion': descripcion,
          'medio_id': medioId,
          'tipo_id': 1,
        },
      ]);

      await supabase
          .from('pre_movimiento')
          .update({'status_id': 2})
          .eq('id', preMovimientoId);

      Get.snackbar(
        'Éxito',
        'Transferencia aprobada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF0FDF4),
        colorText: const Color(0xFF166534),
      );

      await preMovimientosPorAprobar();
    } catch (e) {
      print('Error al aprobar transferencia: $e');

      Get.snackbar(
        'Error',
        'No se pudo aprobar la transferencia: $e',
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
      final supabase = Supabase.instance.client;

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

      // Verificamos si existe un permiso de aprobación para esta cuenta origen
      final permiso = await supabase
          .from('permisos')
          .select('user_id')
          .eq('cuenta_id', cuentaId)
          .limit(1)
          .maybeSingle();

      // Determinamos si requiere aprobación o es directo
      final bool requiereAprobacion = permiso != null && permiso['user_id'] != null;

      if (!requiereAprobacion) {
        // --- FLUJO DIRECTO (Sin permisos de aprobación) ---
        // Inserta movimientos y descuenta/suma saldos obligatoriamente
        await supabase.from('movimientos').insert({
          'cuenta_id': cuentaId,
          'tipo_id': 1,
          'cantidad': cantidad,
          'descripcion': descripcion,
          'medio_id': medioId,
          'status_id': 1,
        });

        await supabase.from('movimientos').insert({
          'cuenta_id': cuentaDestinoId,
          'tipo_id': 2,
          'cantidad': cantidad,
          'descripcion': 'Recepción: $descripcion',
          'medio_id': medioId,
          'status_id': 1,
        });

        // Aplicar rebaja y aumento de saldos aquí de forma directa
        await restarSaldoCuentaOrigen(cantidad);
        await sumarSaldoCuentaDestino(cuentaDestinoId, cantidad);

        Get.snackbar(
          'Éxito',
          'Transferencia realizada correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF0FDF4),
          colorText: const Color(0xFF166534),
        );
        return;
      }

      // --- FLUJO CON APROBACIÓN (Requiere permisos) ---
      // Se manda a pre_movimiento y NO toca los saldos
      final int userPorAprobarId = (permiso['user_id'] as num).toInt();

      await supabase.from('pre_movimiento').insert({
        'cuenta_id': cuentaId,
        'cuenta_destino_id': cuentaDestinoId,
        'user_por_aprobar_id': userPorAprobarId,
        'cantidad': cantidad,
        'descripcion': descripcion,
        'medio_id': medioId,
        'status_id': 1,
      });

      Get.snackbar(
        'Éxito',
        'Transferencia enviada para aprobación',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF0FDF4),
        colorText: const Color(0xFF166534),
      );

      await preMovimientosPorAprobar();
      
    } catch (e) {
      print('Error al registrar transferencia: $e');
      Get.snackbar(
        'Error',
        'No se pudo completar la transferencia: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
      final authUserId = Supabase.instance.client.auth.currentUser?.id;
      if (authUserId == null) return;

      // 1. Obtener el id numérico de datos_personales usando el UUID de Auth
      final datosResponse = await Supabase.instance.client
          .from('datos_personales')
          .select('id')
          .eq('owner_id', authUserId)
          .maybeSingle();

      if (datosResponse == null || datosResponse['id'] == null) {
        print(
          "El usuario autenticado no tiene un registro en datos_personales",
        );
        return;
      }

      final int datosPersonalesId = datosResponse['id'];
      print("datos_personales.id: $datosPersonalesId");

      // 2. Buscar las cuentas de las cuales este usuario es propietario (owner_id en la tabla cuenta)
      final cuentasResponse = await Supabase.instance.client
          .from('cuenta')
          .select('id')
          .eq(
            'owner_id',
            authUserId,
          ); // O usa datosPersonalesId si owner_id en cuenta fuera int, pero según tu esquema es uuid

      final List<dynamic> cuentaIds = cuentasResponse
          .map((c) => c['id'])
          .toList();

      // 3. Consultar permisos abarcando ambas opciones:
      // Que el permiso sea tuyo (user_id) O que pertenezca a tus cuentas (cuenta_id)
      var query = Supabase.instance.client
          .from('permisos')
          .select('*, parentescos:parentescos(nombre)');

      if (cuentaIds.isNotEmpty) {
        // Si tiene cuentas y/o permisos asignados
        query = query.or(
          'user_id.eq.$datosPersonalesId,cuenta_id.in.(${cuentaIds.join(",")})',
        );
      } else {
        query = query.eq('user_id', datosPersonalesId);
      }

      final response = await query;

      final List<Permiso> permisos = (response as List)
          .map((item) => Permiso.fromJson(item))
          .toList();

      permisosList.assignAll(permisos);
      print("jsonEncode(permisosList): ${jsonEncode(permisosList)}");

      if (permisosList.isEmpty) {
        print(
          "El usuario $datosPersonalesId no tiene permisos sobre ninguna cuenta",
        );
      }
    } catch (e) {
      print('Error al cargar permisos: $e');
    }
  }

  Future<void> getDatosCuentaVinculada(String owner_id) async {
    final response = await Supabase.instance.client
        .from('datos_personales')
        .select()
        .eq('id', owner_id)
        .single();

    datosPersonalesCuentaVinculada = DatosPersonales.fromJson(response);
    print(
      "Cuenta vonculada datos: ${jsonEncode(datosPersonalesCuentaVinculada)}",
    );
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

      // UUID del usuario autenticado
      final authUserId = supabase.auth.currentUser?.id;

      if (authUserId == null) {
        preMovimientosList.clear();
        return;
      }

      print('Auth UUID: $authUserId');

      // Obtener el ID BIGINT de datos_personales
      final datosResponse = await supabase
          .from('datos_personales')
          .select('id')
          .eq('owner_id', authUserId)
          .maybeSingle();

      if (datosResponse == null || datosResponse['id'] == null) {
        preMovimientosList.clear();

        print('No se encontró datos_personales para el usuario: $authUserId');

        return;
      }

      final int datosPersonalesId = (datosResponse['id'] as num).toInt();

      print('datos_personales.id: $datosPersonalesId');

      // Buscar las cuentas donde ESTE usuario tiene permiso.
      //
      // permisos.user_id es BIGINT y corresponde a
      // datos_personales.id.
      final permisosResponse = await supabase
          .from('permisos')
          .select('cuenta_id')
          .eq('user_id', datosPersonalesId);

      if ((permisosResponse as List).isEmpty) {
        preMovimientosList.clear();

        print(
          'El usuario $datosPersonalesId no tiene permisos sobre ninguna cuenta',
        );

        return;
      }

      // Obtener IDs de las cuentas
      final List<int> cuentaIds = permisosResponse
          .map((permiso) => permiso['cuenta_id'])
          .where((id) => id != null)
          .map((id) => (id as num).toInt())
          .toList();

      if (cuentaIds.isEmpty) {
        preMovimientosList.clear();
        return;
      }

      print('Usuario datos_personales: $datosPersonalesId');
      print('Cuentas con permiso: $cuentaIds');

      // Buscar transferencias pendientes de aprobación
      final response = await supabase
          .from('pre_movimiento')
          .select('''
          *,
          cuenta:cuenta_id(
            id,
            apodo,
            saldo
          ),
          cuenta_destino:cuenta_destino_id(
            id,
            apodo,
            saldo
          ),
          medio:medio_id(
            id,
            nombre,
            color
          ),
          status:status_id(
            id,
            nombre,
            color
          )
        ''')
          .inFilter('cuenta_id', cuentaIds)
          .eq('user_por_aprobar_id', datosPersonalesId)
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
