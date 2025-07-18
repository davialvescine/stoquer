import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/item_model.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;
  const ItemDetailsScreen({super.key, required this.item});

  // Função para gerar e imprimir o PDF com o QR Code
  Future<void> _printQrCode(BuildContext context) async {
    final pdf = pw.Document();
    
    // Gera o QR Code como uma imagem
    final qrImage = await QrPainter(
      data: item.id, // O ID do item é o dado do QR Code
      version: QrVersions.auto,
      gapless: false,
    ).toImageData(200);

    if (qrImage == null) return;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(item.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Image(pw.MemoryImage(qrImage.buffer.asUint8List()), width: 150, height: 150),
                pw.SizedBox(height: 10),
                pw.Text('ID: ${item.id}'),
              ],
            ),
          );
        },
      ),
    );

    // Abre a tela de impressão nativa do celular
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categoria: ${item.categoryId}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Quantidade: ${item.quantity}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            Center(
              child: QrImageView(
                data: item.id, // O dado do QR Code é o ID único do item no Firestore
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _printQrCode(context),
              icon: const Icon(Icons.print),
              label: const Text('Imprimir Etiqueta com QR Code'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

