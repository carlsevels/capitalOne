import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/dashboard.controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2942),
        elevation: 0,
        title: const Text(
          'CAPITAL ONE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => controller.signOut(),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Cerrar Sesión',
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
                // Determinamos si es pantalla grande (Web / Tablet) o móvil
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
              () => _showSalidasModal(context),
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
        _buildCuentasSection(),
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
        // Fila Superior: Bienvenida de ancho completo o tarjeta principal
        _buildWelcomeCard(),
        const SizedBox(height: 24),

        // Botones de Accion Rápida
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
                () => _showSalidasModal(context),
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

        // Contenido en 2 Columnas para Web
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna Izquierda: Cuentas y Transacciones Recientes
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
                  _buildCuentasSection(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Columna Derecha: Direcciones y Pre-movimientos
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
          Text(
            '\$ ${controller.saldoTotal.value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuentasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Mis Cuentas',
          '${controller.cuentasList.length} registradas',
        ),
        const SizedBox(height: 12),
        controller.cuentasList.isEmpty
            ? _buildEmptyState('No hay cuentas vinculadas')
            : SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.cuentasList.length,
                  itemBuilder: (context, index) {
                    final cuenta = controller.cuentasList[index];
                    return Container(
                      width: 210,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E5ED)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cuenta.apodo ?? 'Cuenta #${cuenta.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1D2D3D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '\$ ${cuenta.saldo?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Color(0xFF0F2942),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Recompensas: ${cuenta.recompensas?.toInt() ?? 0} pts',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7A90),
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
    if (controller.preMovimientosList.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Pre-Movimientos Pendientes',
          '${controller.preMovimientosList.length}',
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E5ED)),
          ),
          child: Column(
            children: controller.preMovimientosList.map((pre) {
              return ListTile(
                leading: const Icon(
                  Icons.pending_actions_rounded,
                  color: Colors.orange,
                ),
                title: Text(
                  pre.descripcion ?? 'Sin descripción',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Cantidad: \$${pre.cantidad?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Text(
                  '#${pre.id ?? ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7A90),
                  ),
                ),
              );
            }).toList(),
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

  // ==========================================
  // MODALES INFORMATIVOS
  // ==========================================

  void _showSalidasModal(BuildContext context) {
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
              'Salidas de Dinero Registradas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...controller.salidasDineroList.map(
              (s) => ListTile(
                title: Text(s.descripcion ?? 'Sin descripción'),
                subtitle: Text('Cantidad: \$${s.cantidad ?? 0}'),
                trailing: Text(s.createdAt?.substring(0, 10) ?? ''),
              ),
            ),
            if (controller.salidasDineroList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No hay salidas recientes')),
              ),
          ],
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
