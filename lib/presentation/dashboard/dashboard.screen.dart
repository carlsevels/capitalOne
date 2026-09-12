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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tarjeta de Bienvenida (datos_personales)
              Obx(() {
                final datos = controller.datosPersonales;
                final nombreCompleto = '${datos.nombre ?? ''} ${datos.apellidoPaterno ?? ''} ${datos.apellidoMaterno ?? ''}'.trim();
                final displayName = nombreCompleto.isEmpty ? 'Cargando...' : nombreCompleto;

                return Container(
                  padding: const EdgeInsets.all(24),
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
                            style: TextStyle(
                              color: Color(0xFF9FB3C8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            datos.id != null ? 'ID: #${datos.id}' : '',
                            style: const TextStyle(
                              color: Color(0xFF9FB3C8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFF334E68), height: 1),
                      const SizedBox(height: 16),
                      
                      // 2. Información de Cuentas (cuenta.saldo, cuenta.recompensas)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Saldo Total en Cuentas',
                            style: TextStyle(color: Color(0xFF9FB3C8), fontSize: 13),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Recompensas: 1,250 pts', // Simulado desde cuenta.recompensas
                              style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '\$ 48,250.00', // Simulado de la tabla cuenta.saldo
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // 3. Accesos Rápidos (basado en medios, compras, salidas_dinero)
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
                  _buildActionButton(Icons.arrow_upward_rounded, 'Salidas', () {}), // salidas_dinero
                  _buildActionButton(Icons.shopping_bag_rounded, 'Compras', () {}),  // compras
                  _buildActionButton(Icons.compare_arrows_rounded, 'Movimientos', () {}), // movimientos
                  _buildActionButton(Icons.badge_rounded, 'Documentos', () {}), // documentos
                ],
              ),

              const SizedBox(height: 32),

              // 4. Historial Unificado (movimientos / compras / salidas_dinero con status y medios)
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
                child: Column(
                  children: [
                    _buildTransactionItem('Compra en Comercio', 'Tarjeta de Crédito • Completado', '-\$ 1,450.00', Colors.red, Icons.shopping_cart_outlined),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildTransactionItem('Salida de Dinero', 'Transferencia • Procesando', '-\$ 5,000.00', Colors.orange, Icons.north_east_rounded),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildTransactionItem('Depósito Recibido', 'Efectivo • Exitoso', '+\$ 12,500.00', Colors.green, Icons.south_west_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
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

  Widget _buildTransactionItem(String title, String subtitle, String amount, Color amountColor, IconData icon) {
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
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1D2D3D)),
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
}