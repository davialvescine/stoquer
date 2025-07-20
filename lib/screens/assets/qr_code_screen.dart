// TELA AVANÇADA DE QR CODE
// 
// Sistema completo de gestão de QR Codes para o Stoquer.
// Esta é uma das funcionalidades mais avançadas do sistema.
// 
// FUNCIONALIDADES PRINCIPAIS:
// === TAB SCANNER ===
// - Scanner em tempo real com câmera
// - Busca automática de ativos por QR Code
// - Ações diretas: Emprestar/Devolver ativos
// - Controles de flash e troca de câmera
// - Histórico do último scan
// 
// === TAB GERAÇÃO ===
// - Listação de todos os ativos
// - Visualização expansivel de QR Codes
// - Informações detalhadas dos ativos
// - Impressão individual de QR Codes
// 
// === TAB IMPRESSÃO ===
// - Impressão em massa de QR Codes
// - Layout otimizado (6 QR Codes por página)
// - Filtros por status (todos/disponíveis)
// - Preview em grid dos QR Codes
// - Export PDF profissional
// 
// INTEGRAÇÕES:
// - Sistema de ativos completo
// - Empréstimos/devoluções instantâneas
// - Histórico de movimentações
// - Relatórios PDF para impressão

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../models/asset_model.dart';

/// WIDGET PRINCIPAL: QRCodeScreen
/// 
/// Tela com TabController para as 3 funcionalidades principais:
/// Scanner, Geração e Impressão de QR Codes.
class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

/// ESTADO DA TELA: _QRCodeScreenState
/// 
/// Gerencia todo o estado da tela de QR Code avançada.
/// Controla scanner, geração, impressão e integrações.
class _QRCodeScreenState extends State<QRCodeScreen> {
  // === CONTROLADORES DO SCANNER ===
  // Controlador da câmera do scanner
  MobileScannerController? _scannerController;
  
  // === ESTADO DO SCANNER ===
  // Último código QR escaneado
  String? _lastScannedCode;
  
  // Ativo encontrado pelo último scan
  Asset? _scannedAsset;
  
  // Flag de controle para evitar scans múltiplos
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  /// Processa QR Code escaneado
  Future<void> _onQRCodeDetected(BarcodeCapture capture) async {
    if (_isScanning) return;
    
    final code = capture.barcodes.first.rawValue;
    if (code == null || code == _lastScannedCode) return;

    setState(() {
      _isScanning = true;
      _lastScannedCode = code;
    });

    try {
      // Buscar ativo pelo código QR
      final asset = await _findAssetByQRCode(code);
      
      if (asset != null) {
        setState(() {
          _scannedAsset = asset;
        });
        _showAssetDialog(asset);
      } else {
        _showErrorDialog('Ativo não encontrado', 'Este QR Code não corresponde a nenhum ativo no sistema.');
      }
    } catch (e) {
      _showErrorDialog('Erro', 'Erro ao processar QR Code: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// Busca ativo pelo código QR
  Future<Asset?> _findAssetByQRCode(String qrCode) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('qrCode', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Asset.fromMap(doc.id, doc.data());
      }
      
      // Se não encontrou por qrCode, tenta buscar pelo ID
      final docSnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .doc(qrCode)
          .get();
          
      if (docSnapshot.exists) {
        return Asset.fromMap(docSnapshot.id, docSnapshot.data()!);
      }
      
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar ativo: $e');
      return null;
    }
  }

  /// Mostra dialog com informações do ativo
  void _showAssetDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getStatusIcon(asset.status), color: _getStatusColor(asset.status)),
            const SizedBox(width: 8),
            Expanded(child: Text(asset.titulo)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Status', asset.statusDisplayName),
            _buildInfoRow('ID', asset.id),
            _buildInfoRow('Categoria', asset.categoriaId),
            _buildInfoRow('Localização', asset.localizacaoId),
            if (asset.dataCompra != null)
              _buildInfoRow('Data Compra', DateFormat('dd/MM/yyyy').format(asset.dataCompra!)),
            _buildInfoRow('Criado em', DateFormat('dd/MM/yyyy').format(asset.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (asset.status == AssetStatus.disponivel)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showLoanDialog(asset);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Emprestar', style: TextStyle(color: Colors.white)),
            ),
          if (asset.status == AssetStatus.emprestado)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _returnAsset(asset);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Devolver', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  /// Dialog para empréstimo
  void _showLoanDialog(Asset asset) {
    final borrowerController = TextEditingController();
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emprestar: ${asset.titulo}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: borrowerController,
              decoration: const InputDecoration(
                labelText: 'Nome do Solicitante',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (borrowerController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _loanAsset(asset, borrowerController.text.trim(), notesController.text.trim());
              }
            },
            child: const Text('Confirmar Empréstimo'),
          ),
        ],
      ),
    );
  }

  /// Registra empréstimo do ativo
  Future<void> _loanAsset(Asset asset, String borrower, String notes) async {
    try {
      // Atualizar status do ativo
      await FirebaseFirestore.instance
          .collection('assets')
          .doc(asset.id)
          .update({'status': AssetStatus.emprestado.toString()});

      // Registrar movimento de empréstimo
      await FirebaseFirestore.instance.collection('movements').add({
        'assetId': asset.id,
        'type': 'loan',
        'borrower': borrower,
        'notes': notes,
        'loanDate': DateTime.now().toIso8601String(),
        'status': 'active',
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${asset.titulo} emprestado para $borrower')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro', 'Erro ao registrar empréstimo: $e');
      }
    }
  }

  /// Registra devolução do ativo
  Future<void> _returnAsset(Asset asset) async {
    try {
      // Atualizar status do ativo
      await FirebaseFirestore.instance
          .collection('assets')
          .doc(asset.id)
          .update({'status': AssetStatus.disponivel.toString()});

      // Buscar e finalizar movimento ativo
      final movementsQuery = await FirebaseFirestore.instance
          .collection('movements')
          .where('assetId', isEqualTo: asset.id)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (movementsQuery.docs.isNotEmpty) {
        await movementsQuery.docs.first.reference.update({
          'status': 'returned',
          'returnDate': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${asset.titulo} devolvido com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro', 'Erro ao registrar devolução: $e');
      }
    }
  }

  /// Gera QR Code único para um ativo
  String _generateQRCode(String assetId) {
    return 'STOQUER_$assetId';
  }


  /// Imprime QR Codes de múltiplos ativos
  Future<void> _printQRCodes(List<Asset> assets) async {
    try {
      final pdf = pw.Document();
      
      // Dividir ativos em grupos de 6 por página (2 colunas x 3 linhas)
      const itemsPerPage = 6;
      for (int i = 0; i < assets.length; i += itemsPerPage) {
        final pageAssets = assets.skip(i).take(itemsPerPage).toList();
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  pw.Text(
                    'QR Codes - Sistema Stoquer',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: pageAssets.map((asset) {
                      final qrCode = asset.id; // Usar o ID como QR code
                      return pw.Container(
                        width: 200,
                        height: 200,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: qrCode,
                              width: 120,
                              height: 120,
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              asset.titulo,
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.Text(
                              'ID: ${asset.id}',
                              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        );
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'QR_Codes_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro', 'Erro ao gerar PDF: $e');
      }
    }
  }

  /// Widget para informações
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Ícone do status
  IconData _getStatusIcon(AssetStatus status) {
    switch (status) {
      case AssetStatus.disponivel:
        return Icons.check_circle;
      case AssetStatus.emprestado:
        return Icons.person;
      case AssetStatus.emUso:
        return Icons.work;
    }
  }

  /// Cor do status
  Color _getStatusColor(AssetStatus status) {
    switch (status) {
      case AssetStatus.disponivel:
        return Colors.green;
      case AssetStatus.emprestado:
        return Colors.orange;
      case AssetStatus.emUso:
        return Colors.blue;
    }
  }

  /// Mostra dialog de erro
  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QR Code'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Scanner', icon: Icon(Icons.qr_code_scanner)),
              Tab(text: 'Gerar', icon: Icon(Icons.qr_code)),
              Tab(text: 'Imprimir', icon: Icon(Icons.print)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScannerTab(),
            _buildGenerateTab(),
            _buildPrintTab(),
          ],
        ),
      ),
    );
  }

  /// Tab do Scanner
  Widget _buildScannerTab() {
    return Column(
      children: [
        // Scanner
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onQRCodeDetected,
              ),
            ),
          ),
        ),
        
        // Informações do último scan
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Último QR Code escaneado:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _lastScannedCode ?? 'Nenhum QR Code escaneado ainda',
                  style: TextStyle(
                    color: _lastScannedCode != null ? Colors.green : Colors.grey,
                  ),
                ),
                if (_scannedAsset != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ativo: ${_scannedAsset!.titulo}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Status: ${_scannedAsset!.statusDisplayName}',
                    style: TextStyle(
                      color: _getStatusColor(_scannedAsset!.status),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Botões de ação
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _scannerController?.toggleTorch(),
                  icon: const Icon(Icons.flashlight_on),
                  label: const Text('Flash'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _scannerController?.switchCamera(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Câmera'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tab de Geração
  Widget _buildGenerateTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('assets')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final assets = snapshot.data!.docs.map((doc) {
          return Asset.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        if (assets.isEmpty) {
          return const Center(
            child: Text('Nenhum ativo encontrado'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            final qrCode = _generateQRCode(asset.id);

            return Card(
              child: ExpansionTile(
                leading: Icon(
                  _getStatusIcon(asset.status),
                  color: _getStatusColor(asset.status),
                ),
                title: Text(asset.titulo),
                subtitle: Text('ID: ${asset.id}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // QR Code
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: QrImageView(
                            data: qrCode,
                            version: QrVersions.auto,
                            size: 200,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Informações do QR Code
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Código QR: $qrCode'),
                              Text('Status: ${asset.statusDisplayName}'),
                              Text('Categoria: ${asset.categoriaId}'),
                              Text('Localização: ${asset.localizacaoId}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Botão para imprimir individual
                        ElevatedButton.icon(
                          onPressed: () => _printQRCodes([asset]),
                          icon: const Icon(Icons.print),
                          label: const Text('Imprimir QR Code'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Tab de Impressão
  Widget _buildPrintTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('assets')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final assets = snapshot.data!.docs.map((doc) {
          return Asset.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        return Column(
          children: [
            // Header com estatísticas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Impressão em Massa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Total de ativos: ${assets.length}'),
                  const Text('QR Codes por página: 6'),
                  Text('Páginas necessárias: ${(assets.length / 6).ceil()}'),
                ],
              ),
            ),
            
            // Botões de ação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: assets.isNotEmpty ? () => _printQRCodes(assets) : null,
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimir Todos os QR Codes'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: assets.isNotEmpty 
                        ? () => _printQRCodes(assets.where((a) => a.status == AssetStatus.disponivel).toList())
                        : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Imprimir Apenas Disponíveis'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de preview
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Preview dos QR Codes:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  final qrCode = _generateQRCode(asset.id);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: QrImageView(
                              data: qrCode,
                              version: QrVersions.auto,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            asset.titulo,
                            style: const TextStyle(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            asset.id,
                            style: const TextStyle(fontSize: 8, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}