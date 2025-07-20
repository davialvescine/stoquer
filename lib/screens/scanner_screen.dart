import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/asset_provider.dart';
import '../models/asset.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _torchEnabled = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        actions: [
          IconButton(
            icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _torchEnabled = !_torchEnabled;
              });
              cameraController.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Posicione o QR Code dentro da área marcada',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          if (!_isScanning)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => setState(() { _isScanning = true; }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Escanear Novamente'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() { _isScanning = false; });
        _searchAssetByQrCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _searchAssetByQrCode(String qrCode) {
    final assetProvider = context.read<AssetProvider>();
    final assets = assetProvider.assets;
    
    final asset = assets.where((a) => a.qrCode == qrCode).firstOrNull;
    
    if (asset != null) {
      _showAssetFound(asset);
    } else {
      _showAssetNotFound(qrCode);
    }
  }

  void _showAssetFound(Asset asset) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Ativo Encontrado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(asset.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Categoria: ${asset.category}'),
            Text('Localização: ${asset.location}'),
            Text('Status: ${asset.status}'),
            Text('Valor: R\$ ${asset.value.toStringAsFixed(2)}'),
            if (asset.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Descrição: ${asset.description}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _isScanning = true; });
            },
            child: const Text('Continuar Escaneando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAssetDetails(asset);
            },
            child: const Text('Ver Detalhes'),
          ),
        ],
      ),
    );
  }

  void _showAssetNotFound(String qrCode) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Ativo Não Encontrado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('QR Code escaneado: $qrCode'),
            const SizedBox(height: 8),
            const Text('Este QR Code não está associado a nenhum ativo no sistema.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _isScanning = true; });
            },
            child: const Text('Tentar Novamente'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateAsset(qrCode);
            },
            child: const Text('Criar Ativo'),
          ),
        ],
      ),
    );
  }

  void _navigateToAssetDetails(Asset asset) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando para detalhes de "${asset.name}"'), backgroundColor: Colors.blue),
    );
  }

  void _navigateToCreateAsset(String qrCode) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Criar novo ativo com QR Code: $qrCode'), backgroundColor: Colors.green),
    );
  }
}