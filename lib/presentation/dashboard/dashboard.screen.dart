import 'dart:convert';

import 'package:capital_one/infrastructure/modelos/cuenta.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/dashboard.controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        surfaceTintColor: Color(0xFFF4F6F9),
        shadowColor: Colors.black,
        backgroundColor: const Color(0xFFF4F6F9),
        elevation: 0,
        title: Container(height: 50, child: Image.asset('logos/besideChico.png')),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => controller.signOut(),
            icon: const Icon(Icons.logout_rounded, color: Colors.black,),
            label: Text("Salir", style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingData.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F2942)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.cargarTodoElDashboard(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 850;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: isDesktop
                          ? _buildDesktopLayout(context)
                          : _buildMobileLayout(context),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // LAYOUT PARA MÓVIL
  // ==========================================
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWelcomeCard(),
        const SizedBox(height: 24),
        const Text(
          'Operaciones Frecuentes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2D3D),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              Icons.arrow_upward_rounded,
              'Salidas',
              () => _modalTransferir(context),
            ),
            _buildActionButton(
              Icons.shopping_bag_rounded,
              'Compras',
              () => _showComprasModal(context),
            ),
            _buildActionButton(
              Icons.compare_arrows_rounded,
              'Movimientos',
              () => _showMovimientosModal(context),
            ),
            _buildActionButton(
              Icons.badge_rounded,
              'Documentos',
              () => _showDocumentosModal(context),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildCuentasSection(context),
        const SizedBox(height: 24),
        _buildDireccionesSection(),
        const SizedBox(height: 24),
        const Text(
          'Movimientos y Transacciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2D3D),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E5ED)),
          ),
          child: _buildUnifiedTransactionsList(),
        ),
        const SizedBox(height: 24),
        _buildPreMovimientosSection(),
      ],
    );
  }

  // ==========================================
  // LAYOUT PARA WEB / DESKTOP (Grid / Dos Columnas)
  // ==========================================
  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWelcomeCard(),
        const SizedBox(height: 24),
        const Text(
          'Operaciones Frecuentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2D3D),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCardDesktop(
                Icons.arrow_upward_rounded,
                'Salidas de Dinero',
                'Ver historial y detalles',
                () => _modalTransferir(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCardDesktop(
                Icons.shopping_bag_rounded,
                'Compras',
                'Consultar transacciones',
                () => _showComprasModal(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCardDesktop(
                Icons.compare_arrows_rounded,
                'Movimientos',
                'Flujo de efectivo',
                () => _showMovimientosModal(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCardDesktop(
                Icons.badge_rounded,
                'Documentos',
                'Identificaciones y archivos',
                () => _showDocumentosModal(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    'Movimientos y Transacciones',
                    '${controller.movimientosList.length + controller.comprasList.length} total',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E5ED)),
                    ),
                    child: _buildUnifiedTransactionsList(),
                  ),
                  const SizedBox(height: 24),
                  _buildCuentasSection(context),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDireccionesSection(),
                  const SizedBox(height: 24),
                  _buildPreMovimientosSection(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // WIDGETS COMPARTIDOS / SECCIONES
  // ==========================================

  Widget _buildWelcomeCard() {
    final datos = controller.datosPersonales;
    final nombreCompleto =
        '${datos.nombre ?? ''} ${datos.apellidoPaterno ?? ''} ${datos.apellidoMaterno ?? ''}'
            .trim();
    final displayName = nombreCompleto.isEmpty
        ? 'Usuario Capital One'
        : nombreCompleto;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2942), Color(0xFF1D2D3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A192F).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bienvenido de vuelta,',
                style: TextStyle(color: Color(0xFF9FB3C8), fontSize: 14),
              ),
              Text(
                datos.id != null ? 'ID: #${datos.id}' : '',
                style: const TextStyle(color: Color(0xFF9FB3C8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF334E68), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Total en Cuentas',
                style: TextStyle(color: Color(0xFF9FB3C8), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '\$ ${controller.saldoTotal.value.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuentasSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis Cuentas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D2D3D),
              ),
            ),
            Text(
              '${controller.cuentasList.length} registradas',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF627D98),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: controller.permisosList.length == 0 ? 210 : 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.cuentasList.length,
            itemBuilder: (context, index) {
              final cuenta = controller.cuentasList[index];
              controller.cuentaSeleccionada.value = cuenta;
              final permisoAsociado = controller.permisosList.firstWhereOrNull(
                (p) => p.cuentaId == cuenta.id,
              );
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F2942).withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            size: 26,
                            color: Color(0xFF2455D6),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cuenta bancaria',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7A8AA3),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                cuenta.apodo ?? 'Cuenta #${cuenta.id}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF172B4D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Saldo disponible',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\$${cuenta.saldo?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 29,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: Color(0xFF102A43),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: permisoAsociado != null
                          ? InkWell(
                              onTap: () {
                                controller.getDatosCuentaVinculada(
                                  permisoAsociado.userId ?? "",
                                );
                                controller.getParentescoAsignado(
                                  permisoAsociado.parentescoId ?? 0,
                                );
                                Get.defaultDialog(
                                  title: "",
                                  content: Obx(
                                    () => Column(
                                      children: [
                                        Text(
                                          "${controller.datosPersonalesCuentaVinculada.nombre} ${controller.datosPersonalesCuentaVinculada.apellidoPaterno} ${controller.datosPersonalesCuentaVinculada.apellidoMaterno}",
                                        ),
                                        Text(
                                          "Parentesco: ${controller.parentescosOne.value.nombre}",
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.person_outline_rounded,
                                      size: 14,
                                      color: Color(0xFF2455D6),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        permisoAsociado.parentesco?.nombre ??
                                            'Vinculado',
                                        style: const TextStyle(
                                          color: Color(0xFF172B4D),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _mostrarModalVincularCuenta(
                                context,
                                cuenta.id!,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(40, 40),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Vincular',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _mostrarModalVincularCuenta(BuildContext context, int cuentaId) {
    int? parentescoSeleccionadoModal;
    String? userIdSeleccionadoModal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E5ED),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Vincular usuario",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F2942),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Busca al usuario por su nombre y define su parentesco para otorgarle acceso a esta cuenta.",
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7A90)),
              ),
              const SizedBox(height: 20),

              Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }

                  try {
                    final response = await Supabase.instance.client
                        .from('datos_personales')
                        .select('owner_id, nombre, apellido_paterno, id')
                        .ilike('nombre', '%${textEditingValue.text}%')
                        .limit(5);

                    return List<Map<String, dynamic>>.from(response);
                  } catch (e) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                },
                displayStringForOption: (Map<String, dynamic> option) {
                  final nombre = option['nombre'] ?? '';
                  final apellido = option['apellido_paterno'] ?? '';
                  return '$nombre $apellido'.trim();
                },
                onSelected: (Map<String, dynamic> selection) {
                  setStateModal(() {
                    userIdSeleccionadoModal = selection['id'].toString();
                    print("Usuario seleccionado: $userIdSeleccionadoModal");
                  });
                },
                fieldViewBuilder:
                    (context, fieldController, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: fieldController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: "Buscar usuario por nombre",
                          hintText: "Ej. Juan Pérez",
                          hintStyle: const TextStyle(
                            color: Color(0xFF9AA8B8),
                            fontSize: 14,
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xFF6B7A90),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF4F7FA),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0F2942),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
              ),
              const SizedBox(height: 16),

              Obx(
                () => DropdownButtonFormField<int>(
                  value: parentescoSeleccionadoModal,
                  decoration: InputDecoration(
                    labelText: "Parentesco",
                    hintText: "Selecciona el parentesco",
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA8B8),
                      fontSize: 14,
                    ),
                    labelStyle: const TextStyle(
                      color: Color(0xFF6B7A90),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4F7FA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F2942),
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: controller.parentescos.map((p) {
                    return DropdownMenuItem<int>(
                      value: p.id,
                      child: Text(p.nombre ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateModal(() {
                      parentescoSeleccionadoModal = value;
                      print(
                        "Parentesco seleccionado: $parentescoSeleccionadoModal",
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (userIdSeleccionadoModal == null ||
                        parentescoSeleccionadoModal == null) {
                      Get.snackbar(
                        'Atención',
                        'Por favor selecciona un usuario de la lista y el parentesco.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    try {
                      await controller.guardarVinculacion(
                        userIdSeleccionado: userIdSeleccionadoModal!,
                        cuentaId: cuentaId,
                        parentescoId: parentescoSeleccionadoModal!,
                      );
                      Navigator.pop(
                        context,
                      ); // Cierra el modal al terminar con éxito
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'No se pudo vincular el usuario: $e',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2942),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirmar vinculación",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7A90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDireccionesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Direccion', ""),
        const SizedBox(height: 12),
        controller.direccionesList.isEmpty
            ? _buildEmptyState('No hay direcciones registradas')
            : Column(
                children: controller.direccionesList.map((dir) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE0E5ED)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF0F2942),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dir.calle ?? ''} #${dir.numExt ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1D2D3D),
                                ),
                              ),
                              Text(
                                'Col. ${dir.colonia ?? ''}, ${dir.municipio ?? ''}, ${dir.estado ?? ''}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7A90),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildPreMovimientosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pre-movimientos por Aprobar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2D3D),
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.preMovimientosList.length} pendientes',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Obx(() {
          if (controller.preMovimientosList.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No hay movimientos pendientes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Los movimientos por aprobar aparecerán aquí',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: controller.preMovimientosList.map((preMov) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F2942).withOpacity(0.035),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CUENTA + IMPORTE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFF1D6CFF),
                              size: 21,
                            ),
                          ),

                          const SizedBox(width: 11),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${preMov.cantidad?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F2942),
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Pendiente',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // DESCRIPCIÓN
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 17,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                preMov.descripcion ?? 'Sin descripción',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      const SizedBox(height: 14),

                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      const SizedBox(height: 14),

                      // ACCIONES
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // controller.rechazarPreMovimiento(preMov.id);
                              },
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: const Text('Rechazar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side: const BorderSide(
                                  color: Color(0xFFFECACA),
                                ),
                                backgroundColor: const Color(0xFFFFFAFA),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                controller.aprobarTransferencia(preMov.id ?? 0);
                              },
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Aprobar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPreMovimientoInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnifiedTransactionsList() {
    final movs = controller.movimientosList;
    final comps = controller.comprasList;
    final salidas = controller.salidasDineroList;

    if (movs.isEmpty && comps.isEmpty && salidas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No hay transacciones registradas',
            style: TextStyle(color: Color(0xFF6B7A90), fontSize: 13),
          ),
        ),
      );
    }

    final List<Widget> widgetsList = [];

    for (var m in movs.take(3)) {
      widgetsList.add(
        _buildTransactionItem(
          m.descripcion ?? 'Movimiento',
          'Movimiento • ${m.medio?['nombre'] ?? 'General'}',
          '-\$ ${m.cantidad?.toStringAsFixed(2) ?? '0.00'}',
          Colors.redAccent,
          Icons.compare_arrows_rounded,
        ),
      );
      widgetsList.add(const Divider(height: 1, color: Color(0xFFF1F5F9)));
    }

    for (var c in comps.take(3)) {
      widgetsList.add(
        _buildTransactionItem(
          c.descripcion ?? 'Compra en comercio',
          'Compra • ${c.status?['nombre'] ?? 'Completado'}',
          '-\$ ${c.cantidad?.toStringAsFixed(2) ?? '0.00'}',
          Colors.deepOrange,
          Icons.shopping_bag_rounded,
        ),
      );
      widgetsList.add(const Divider(height: 1, color: Color(0xFFF1F5F9)));
    }

    for (var s in salidas.take(3)) {
      widgetsList.add(
        _buildTransactionItem(
          s.descripcion ?? 'Salida de dinero',
          'Salida • ${s.status?['nombre'] ?? 'Procesando'}',
          '-\$ ${s.cantidad?.toStringAsFixed(2) ?? '0.00'}',
          Colors.red,
          Icons.arrow_upward_rounded,
        ),
      );
      widgetsList.add(const Divider(height: 1, color: Color(0xFFF1F5F9)));
    }

    if (widgetsList.isNotEmpty) {
      widgetsList.removeLast();
    }

    return Column(children: widgetsList);
  }

  Widget _buildSectionHeader(String title, String countLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2D3D),
          ),
        ),
        Text(
          countLabel,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF627D98),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E5ED)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF6B7A90), fontSize: 12),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E5ED)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A192F).withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF0F2942), size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334E68),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCardDesktop(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E5ED)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A192F).withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(icon, color: const Color(0xFF0F2942), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1D2D3D),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7A90),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    String amount,
    Color amountColor,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, color: const Color(0xFF627D98), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF1D2D3D),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF6B7A90), fontSize: 12),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: amountColor,
        ),
      ),
    );
  }

  void _modalTransferir(BuildContext context) async {
    // Cargamos los medios al abrir el modal
    await controller.getMediosTransferencia();

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      StatefulBuilder(
        builder: (context, setStateModal) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E5ED),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Realizar Transferencia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F2942),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ingresa el número de cuenta de destino para buscar al usuario automáticamente.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7A90)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.cuentaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Número de cuenta destino (ID)",
                    hintText: "Ej. 1",
                    filled: true,
                    fillColor: const Color(0xFFF4F7FA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F2942),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) async {
                    if (value.trim().isEmpty) {
                      setStateModal(() {
                        controller.cuentaEncontradaData = null;
                      });
                      return;
                    }

                    setStateModal(() => controller.isLoadingCuenta = true);
                    try {
                      final cuentaId = int.tryParse(value.trim());
                      if (cuentaId != null) {
                        final cuentaRes = await Supabase.instance.client
                            .from('cuenta')
                            .select('id, apodo, owner_id')
                            .eq('id', cuentaId)
                            .maybeSingle();
                        if (cuentaRes != null &&
                            cuentaRes['owner_id'] != null) {
                          final personaRes = await Supabase.instance.client
                              .from('datos_personales')
                              .select(
                                'nombre, apellido_paterno, apellido_materno',
                              )
                              .eq('owner_id', cuentaRes['owner_id'])
                              .maybeSingle();

                          setStateModal(() {
                            controller.cuentaEncontradaData = {
                              'cuenta': cuentaRes,
                              'persona': personaRes,
                            };
                          });
                        } else {
                          setStateModal(
                            () => controller.cuentaEncontradaData = null,
                          );
                        }
                      }
                    } catch (e) {
                      setStateModal(
                        () => controller.cuentaEncontradaData = null,
                      );
                    } finally {
                      setStateModal(() => controller.isLoadingCuenta = false);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Tarjeta de información del destinatario cargada automáticamente
                if (controller.isLoadingCuenta)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.cuentaEncontradaData != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2455D6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF2455D6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Destinatario encontrado:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7A8AA3),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${controller.cuentaEncontradaData!['persona']?['nombre'] ?? ''} ${controller.cuentaEncontradaData!['persona']?['apellido_paterno'] ?? ''} ${controller.cuentaEncontradaData!['persona']?['apellido_materno'] ?? ''}"
                                    .trim(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF172B4D),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Cuenta: ${controller.cuentaEncontradaData!['cuenta']['apodo'] ?? 'Cuenta #' + controller.cuentaEncontradaData!['cuenta']['id'].toString()}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7A90),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Campo de cantidad a transferir
                TextField(
                  controller: controller.cantidadController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: "Cantidad a transferir",
                    hintText: "\$0.00",
                    filled: true,
                    fillColor: const Color(0xFFF4F7FA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F2942),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de concepto
                TextField(
                  controller: controller.conceptoController,
                  decoration: InputDecoration(
                    labelText: "Concepto",
                    hintText: "Ej. Pago de servicios...",
                    filled: true,
                    fillColor: const Color(0xFFF4F7FA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F2942),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dropdown para seleccionar el Medio de transferencia
                DropdownButtonFormField<int>(
                  value: controller.medioSeleccionadoId.value,
                  decoration: InputDecoration(
                    labelText: "Método / Medio",
                    filled: true,
                    fillColor: const Color(0xFFF4F7FA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F2942),
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: controller.mediosList.map((medio) {
                    return DropdownMenuItem<int>(
                      value: medio.id as int,
                      child: Text(
                        medio.nombre ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF172B4D),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateModal(() {
                      controller.medioSeleccionadoId.value = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Botón de confirmación
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.cuentaEncontradaData == null
                        ? null
                        : () async {
                            final double? cantidad = double.tryParse(
                              controller.cantidadController.text.trim(),
                            );
                            final int? cuentaDestinoId = int.tryParse(
                              controller.cuentaController.text.trim(),
                            );

                            if (cantidad == null || cantidad <= 0) {
                              Get.snackbar(
                                'Error',
                                'Ingresa una cantidad válida',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (cuentaDestinoId == null) {
                              Get.snackbar(
                                'Error',
                                'Número de cuenta inválido',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (controller.medioSeleccionadoId.value == null) {
                              Get.snackbar(
                                'Error',
                                'Selecciona un medio de transferencia',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }
                            if (controller.cuentaSeleccionada.value?.saldo !=
                                    null &&
                                controller.cuentaSeleccionada.value!.saldo! <
                                    cantidad) {
                              Get.snackbar(
                                'Fondos insuficientes',
                                'La cuenta seleccionada no cuenta con el saldo disponible para realizar esta operación.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFFEF2F2),
                                colorText: const Color(0xFF991B1B),
                                icon: const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFDC2626),
                                ),
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                                duration: const Duration(seconds: 3),
                              );
                            } else {
                              try {
                                final saldoActual =
                                    controller.cuentaSeleccionada.value?.saldo;

                                if (saldoActual == null ||
                                    saldoActual < cantidad) {
                                  Get.snackbar(
                                    'Fondos insuficientes',
                                    'No tienes suficiente saldo para realizar esta transferencia',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: const Color(0xFFFEF2F2),
                                    colorText: const Color(0xFF991B1B),
                                  );
                                  return;
                                }

                                await controller.realizarTransferencia(
                                  cuentaId:
                                      controller.cuentaSeleccionada.value!.id!,
                                  cuentaDestinoId: cuentaDestinoId,
                                  cantidad: cantidad,
                                  descripcion:
                                      controller.conceptoController.text
                                          .trim()
                                          .isEmpty
                                      ? 'Transferencia bancaria'
                                      : controller.conceptoController.text
                                            .trim(),
                                  medioId:
                                      controller.medioSeleccionadoId.value!,
                                );
                                // await controller.restarSaldoCuentaOrigen(
                                //   cantidad,
                                // );
                                // await controller.sumarSaldoCuentaDestino(
                                //   cuentaDestinoId,
                                //   cantidad,
                                // );
                              } catch (e) {
                                print('Error en la vista al transferir: $e');

                                Get.snackbar(
                                  'Error',
                                  'No se pudo completar la transferencia: $e',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  colorText: const Color(0xFF991B1B),
                                  icon: const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFDC2626),
                                  ),
                                );
                              }
                            }
                            controller.cargarTodoElDashboard();
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2942),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                    ),
                    child: const Text(
                      "Confirmar transferencia",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7A90),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComprasModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const Text(
              'Compras Realizadas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...controller.comprasList.map(
              (c) => ListTile(
                title: Text(c.descripcion ?? 'Sin descripción'),
                subtitle: Text('Monto: \$${c.cantidad ?? 0}'),
                trailing: Text(c.createdAt?.substring(0, 10) ?? ''),
              ),
            ),
            if (controller.comprasList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No hay compras recientes')),
              ),
          ],
        ),
      ),
    );
  }

  void _showMovimientosModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const Text(
              'Historial de Movimientos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...controller.movimientosList.map(
              (m) => ListTile(
                title: Text(m.descripcion ?? 'Sin descripción'),
                subtitle: Text('Cantidad: \$${m.cantidad ?? 0}'),
                trailing: Text(m.createdAt?.substring(0, 10) ?? ''),
              ),
            ),
            if (controller.movimientosList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No hay movimientos recientes')),
              ),
          ],
        ),
      ),
    );
  }

  void _showDocumentosModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const Text(
              'Documentos del Usuario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...controller.documentosList.map(
              (d) => ListTile(
                leading: const Icon(
                  Icons.description_rounded,
                  color: Color(0xFF0F2942),
                ),
                title: Text(d.tipo?['nombre'] ?? 'Documento #${d.id}'),
                subtitle: Text('ID: ${d.id}'),
              ),
            ),
            if (controller.documentosList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No hay documentos registrados')),
              ),
          ],
        ),
      ),
    );
  }
}
