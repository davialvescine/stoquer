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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('Stoquer Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: const Text('Ativos'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetListScreen(isAcessorio: false))); }),
            ListTile(title: const Text('Acessórios'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetListScreen(isAcessorio: true))); }),
            ListTile(title: const Text('Kits'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const KitListScreen())); }),
            ListTile(title: const Text('Empréstimos'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanScreen())); }),
            const Divider(),
            ListTile(title: const Text('Gerir Categorias'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen())); }),
            ListTile(title: const Text('Gerir Localizações'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationManagementScreen())); }),
            const Divider(),
            ListTile(title: const Text('Meu Perfil'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); }),
             ListTile(title: const Text('Sair'), onTap: () => _authService.signOut()),
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
            padding: const EdgeInsets.all(16.0),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
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
            ],
          );
        },
      ),
    );
  }
}
