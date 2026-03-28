import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final pw.Document pdf;

  const PdfPreviewPage({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Preview"),
      ),

      body: PdfPreview(
        build: (format) => pdf.save(),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: true,
      ),
    );
  }
}