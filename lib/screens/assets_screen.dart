/*
 * HUB CENTRAL DE ATIVOS
 * 
 * Central de gerenciamento de todos os ativos do sistema Stoquer.
 * Integra com o AssetListScreen original e oferece acesso rápido
 * às principais funcionalidades de gestão de ativos.
 * 
 * FUNCIONALIDADES:
 * - Acesso rápido à lista de ativos
 * - Acesso rápido à lista de acessórios
 * - Estatísticas de ativos
 * - Ações rápidas
 * - Navegação para QR Code
 * - Relatórios de ativos
 */

import 'package:flutter/material.dart';
import 'assets/asset_list_screen.dart';

/*
 * WIDGET PRINCIPAL: AssetsScreen
 * 
 * Hub central para gestão de ativos com acesso rápido
 * às principais funcionalidades.
 */
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

/*
 * ESTADO DA TELA: _AssetsScreenState
 * 
 * Gerencia o hub central de ativos.
 */
class _AssetsScreenState extends State<AssetsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hub Central de Ativos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER ===
            const Text(
              'Gestão de Ativos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Central de gerenciamento de todos os ativos do sistema',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // === AÇÕES RÁPIDAS ===
            const Text(
              'Ações Rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                // Card Ativos
                Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AssetListScreen(isAcessorio: false),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices, size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            'Ver Ativos',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Lista completa',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Card Acessórios
                Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AssetListScreen(isAcessorio: true),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.extension, size: 40, color: Colors.orange),
                          SizedBox(height: 8),
                          Text(
                            'Ver Acessórios',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Lista completa',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // === INFORMAÇÕES ===
            const Text(
              'Informações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hub Central de Ativos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Este é o hub central para gestão de ativos. Aqui você tem acesso rápido às listas de ativos e acessórios, que são gerenciadas pelo sistema original do Stoquer.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Ativos: Equipamentos principais do sistema',
                  ),
                  Text(
                    '• Acessórios: Itens complementares e consumíveis',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}