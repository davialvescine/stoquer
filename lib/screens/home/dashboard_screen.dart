import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/dashboard_card.dart';
import '../management/category_management_screen.dart';
import '../management/kit_list_screen.dart';
import '../management/location_management_screen.dart';
import '../assets/asset_list_screen.dart';
import '../loans/loan_screen.dart';
import 'profile_screen.dart';
// Novas funcionalidades evoluídas
import '../accessories_screen.dart';
import '../maintenance_screen.dart';
import '../movements_screen.dart';
import '../assets/qr_code_screen.dart';
import '../improved_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final FirestoreService _firestoreService;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),

      // Menu lateral

            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.indigo),
                    child: Text('Stoquer Menu', style: TextStyle(color: Colors.white, fontSize:24, )),
                  ),
            

            // === SEÇÃO PRINCIPAL ===
            ListTile(
              leading: const Icon(Icons.devices, color: Colors.indigo),
              title: const Text('Ativos'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetListScreen(isAcessorio: false))); }
            ),
            ListTile(
              leading: const Icon(Icons.extension, color: Colors.indigo),
              title: const Text('Acessórios'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetListScreen(isAcessorio: true))); }
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.indigo),
              title: const Text('Kits'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const KitListScreen())); }
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.indigo),
              title: const Text('Empréstimos'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanScreen())); }
            ),
            const Divider(),
            
            // === SEÇÃO GESTÃO EVOLUÍDA ===
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.deepOrange),
              title: const Text('Gerir Acessórios'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessoriesScreen())); }
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.deepOrange),
              title: const Text('Manutenções'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen())); }
            ),
            ListTile(
              leading: const Icon(Icons.move_up, color: Colors.deepOrange),
              title: const Text('Movimentações'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MovementsScreen())); }
            ),
            const Divider(),
            
            // === SEÇÃO CONFIGURAÇÕES ===
            ListTile(
              leading: const Icon(Icons.category, color: Colors.green),
              title: const Text('Gerir Categorias'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen())); }
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('Gerir Localizações'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationManagementScreen())); }
            ),
            const Divider(),
            
            // === SEÇÃO FERRAMENTAS ===
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.purple),
              title: const Text('QR Code Scanner'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const QRCodeScreen())); }
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.purple),
              title: const Text('Dashboard Avançado'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ImprovedDashboard())); }
            ),
            const Divider(),
            
            // === SEÇÃO USUÁRIO ===
            ListTile(
              leading: const Icon(Icons.person, color: Colors.grey),
              title: const Text('Meu Perfil'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); }
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair'),
              onTap: () => _authService.signOut()
            ),
          ],
        ),
      ),
      body: StreamBuilder<Map<String, int>>(
        stream: _firestoreService.getDashboardStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data!;
          return GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            padding: const EdgeInsets.all(12.0),
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            children: [
              // === CARDS ORIGINAIS ===
              DashboardCard(
                title: 'Total de Ativos',
                value: stats['totalAssets'] ?? 0,
                icon: Icons.computer,
              ),
              DashboardCard(
                title: 'Emprestados',
                value: stats['loanedAssets'] ?? 0,
                icon: Icons.swap_horiz,
                color: Colors.orange,
              ),
              DashboardCard(
                title: 'Localizações',
                value: stats['locations'] ?? 0,
                icon: Icons.location_on,
                color: Colors.green,
              ),
              DashboardCard(
                title: 'Kits',
                value: stats['kits'] ?? 0,
                icon: Icons.inventory_2,
                color: Colors.purple,
              ),
              
              // === CARDS EVOLUÍDOS ===
              DashboardCard(
                title: 'Total Acessórios',
                value: stats['totalAccessories'] ?? 0,
                icon: Icons.extension,
                color: Colors.deepOrange,
              ),
              DashboardCard(
                title: 'Manutenções Pendentes',
                value: stats['pendingMaintenance'] ?? 0,
                icon: Icons.build,
                color: Colors.red,
              ),
              DashboardCard(
                title: 'Movimentações Hoje',
                value: stats['todayMovements'] ?? 0,
                icon: Icons.move_up,
                color: Colors.blue,
              ),
              DashboardCard(
                title: 'Categorias Ativas',
                value: stats['activeCategories'] ?? 0,
                icon: Icons.category,
                color: Colors.teal,
              ),
            ],
          );
        },
      ),
    );
  }
}
