/*
 * DASHBOARD AVANÇADO - STOQUER
 * 
 * Dashboard com gráficos e métricas avançadas do sistema.
 * Apresenta visão estratégica completa dos ativos e operações.
 * 
 * FUNCIONALIDADES:
 * - Gráficos interativos com fl_chart
 * - Métricas em tempo real
 * - Análise de tendências
 * - Relatórios visuais
 * - Alertas e indicadores
 * - Export de dados
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

/*
 * WIDGET PRINCIPAL: ImprovedDashboard
 * 
 * Dashboard avançado com gráficos e métricas do sistema.
 */
class ImprovedDashboard extends StatefulWidget {
  const ImprovedDashboard({super.key});

  @override
  State<ImprovedDashboard> createState() => _ImprovedDashboardState();
}

class _ImprovedDashboardState extends State<ImprovedDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Avançado'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Visão geral do sistema',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('EEEE, dd de MMMM de yyyy', 'pt_BR').format(DateTime.now()),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total de Ativos',
                    FirebaseFirestore.instance.collection('assets').snapshots(),
                    Icons.devices,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Emprestados',
                    FirebaseFirestore.instance
                        .collection('assets')
                        .where('status', isEqualTo: 'emprestado')
                        .snapshots(),
                    Icons.output,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Disponíveis',
                    FirebaseFirestore.instance
                        .collection('assets')
                        .where('status', isEqualTo: 'disponivel')
                        .snapshots(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Em Manutenção',
                    FirebaseFirestore.instance
                        .collection('assets')
                        .where('status', isEqualTo: 'manutencao')
                        .snapshots(),
                    Icons.build,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Recent Activities and Charts
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Movements
                Expanded(
                  flex: 3,
                  child: _buildRecentMovements(),
                ),
                const SizedBox(width: 16),
                // Charts
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildCategoryChart(),
                      const SizedBox(height: 16),
                      _buildLocationChart(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Alerts Section
            _buildAlertsSection(),
            const SizedBox(height: 32),
            
            // Quick Actions
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    Stream<QuerySnapshot> stream,
    IconData icon,
    Color color,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentMovements() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Movimentações Recentes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to movements screen
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('movements')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final movements = snapshot.data!.docs;

              if (movements.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Nenhuma movimentação recente'),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: movements.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final movement = movements[index];
                  final data = movement.data() as Map<String, dynamic>;
                  final isReturn = data['status'] == 'returned';
                  final createdAt = data['createdAt'] != null
                      ? (data['createdAt'] as Timestamp).toDate()
                      : DateTime.now();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isReturn
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      child: Icon(
                        isReturn ? Icons.input : Icons.output,
                        color: isReturn ? Colors.green : Colors.blue,
                      ),
                    ),
                    title: Text(
                      data['borrowerName'] ?? 'Sem nome',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${(data['items'] as List?)?.length ?? 0} itens • ${_getRelativeTime(createdAt)}',
                    ),
                    trailing: Chip(
                      label: Text(
                        isReturn ? 'Devolvido' : 'Emprestado',
                        style: TextStyle(
                          color: isReturn ? Colors.green : Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: isReturn
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ativos por Categoria',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('assets').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final assets = snapshot.data!.docs;
                final categoryCount = <String, int>{};

                for (var asset in assets) {
                  final data = asset.data() as Map<String, dynamic>;
                  final category = data['category'] ?? 'Sem categoria';
                  categoryCount[category] = (categoryCount[category] ?? 0) + 1;
                }

                if (categoryCount.isEmpty) {
                  return const Center(
                    child: Text('Nenhum dado disponível'),
                  );
                }

                final sections = categoryCount.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.value}',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList();

                return PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribuição por Local',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('assets').snapshots(),
              builder: (context, assetsSnapshot) {
                if (!assetsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('locations').snapshots(),
                  builder: (context, locationsSnapshot) {
                    if (!locationsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final assets = assetsSnapshot.data!.docs;
                    final locations = locationsSnapshot.data!.docs;
                    final locationCount = <String, int>{};
                    final locationNames = <String, String>{};

                    // Map location IDs to names
                    for (var location in locations) {
                      final data = location.data() as Map<String, dynamic>;
                      locationNames[location.id] = data['name'] ?? 'Sem nome';
                    }

                    // Count assets per location
                    for (var asset in assets) {
                      final data = asset.data() as Map<String, dynamic>;
                      final locationId = data['location'] ?? 'none';
                      final locationName = locationNames[locationId] ?? 'Sem local';
                      locationCount[locationName] = (locationCount[locationName] ?? 0) + 1;
                    }

                    if (locationCount.isEmpty) {
                      return const Center(
                        child: Text('Nenhum dado disponível'),
                      );
                    }

                    return ListView.builder(
                      itemCount: locationCount.length,
                      itemBuilder: (context, index) {
                        final entry = locationCount.entries.elementAt(index);
                        final percentage = (entry.value / assets.length * 100).toStringAsFixed(1);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text('${entry.value} ($percentage%)'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: entry.value / assets.length,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertas e Notificações',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('movements')
                .where('status', isEqualTo: 'active')
                .snapshots(),
            builder: (context, movementsSnapshot) {
              final lateMovements = <QueryDocumentSnapshot>[];
              
              if (movementsSnapshot.hasData) {
                for (var movement in movementsSnapshot.data!.docs) {
                  final data = movement.data() as Map<String, dynamic>;
                  final expectedReturn = (data['expectedReturnDate'] as Timestamp).toDate();
                  if (expectedReturn.isBefore(DateTime.now())) {
                    lateMovements.add(movement);
                  }
                }
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('accessories')
                    .snapshots(),
                builder: (context, accessoriesSnapshot) {
                  final lowStockAccessories = <QueryDocumentSnapshot>[];
                  
                  if (accessoriesSnapshot.hasData) {
                    for (var accessory in accessoriesSnapshot.data!.docs) {
                      final data = accessory.data() as Map<String, dynamic>;
                      final quantity = data['quantity'] ?? 0;
                      final minStock = data['minStock'] ?? 0;
                      if (quantity <= minStock) {
                        lowStockAccessories.add(accessory);
                      }
                    }
                  }

                  final totalAlerts = lateMovements.length + lowStockAccessories.length;

                  if (totalAlerts == 0) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 48),
                            SizedBox(height: 8),
                            Text('Tudo em ordem!'),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (lateMovements.isNotEmpty) ...[
                        _buildAlertTile(
                          Icons.warning,
                          Colors.orange,
                          'Devoluções Atrasadas',
                          '${lateMovements.length} empréstimos com prazo vencido',
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (lowStockAccessories.isNotEmpty) ...[
                        _buildAlertTile(
                          Icons.inventory,
                          Colors.red,
                          'Estoque Baixo',
                          '${lowStockAccessories.length} acessórios com estoque mínimo',
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Novo Ativo',
                  Icons.add_circle,
                  Colors.blue,
                  () {
                    // Navigate to assets screen
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Novo Empréstimo',
                  Icons.output,
                  Colors.green,
                  () {
                    // Navigate to movements screen
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Escanear QR Code',
                  Icons.qr_code_scanner,
                  Colors.purple,
                  () {
                    // Open QR scanner
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Relatórios',
                  Icons.analytics,
                  Colors.orange,
                  () {
                    // Navigate to reports
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}