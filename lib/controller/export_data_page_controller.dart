import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

class ExportController extends GetxController {
  var isLoading = false.obs;
  var exportPath = ''.obs;

  /// FORMAT VALUE
  String formatValue(dynamic value) {
    if (value == null) return "-";

    if (value is Timestamp) {
      final dt = value.toDate();
      return "${dt.day}-${dt.month}-${dt.year}";
    }

    return value.toString();
  }

  /// LOAD IMAGE
  Future<Uint8List?> loadImage(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      return res.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  /// BUILD PDF (USED FOR PREVIEW + DOWNLOAD)
  Future<pw.Document> buildPdf() async {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final profile = userDoc.data() ?? {};

    final categorySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("categories")
        .get();

    final categories = categorySnapshot.docs.map((e) => e.data()).toList();

    final todoSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("todos")
        .get();

    final todos = todoSnapshot.docs.map((e) => e.data()).toList();

    /// GROUP TODOS
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var t in todos) {
      String cat = t["category"] ?? "Uncategorized";
      grouped.putIfAbsent(cat, () => []);
      grouped[cat]!.add(t);
    }

    final pdf = pw.Document();

    pw.Widget header(String text) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        margin: const pw.EdgeInsets.only(top: 12, bottom: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.blueGrey800,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    /// PROFILE IMAGE
    pw.Widget? imageWidget;

    if (profile["photoUrl"] != null) {
      final bytes = await loadImage(profile["photoUrl"]);
      if (bytes != null) {
        imageWidget = pw.Center(
          child: pw.Container(
            height: 80,
            width: 80,
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.ClipOval(
              child: pw.Image(pw.MemoryImage(bytes)),
            ),
          ),
        );
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),

        build: (context) => [

          pw.Center(
            child: pw.Text(
              "User Data Report",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 15),

          /// PROFILE
          header("PROFILE"),

          if (imageWidget != null) imageWidget,

          pw.Text("Name: ${formatValue(profile["name"])}"),
          pw.Text("Email: ${formatValue(profile["email"])}"),
          pw.Text("Phone: ${formatValue(profile["phone"])}"),
          pw.Text("UID: $uid"),

          /// CATEGORIES
          header("CATEGORIES"),

          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: categories.map((c) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(c["name"] ?? "-"),
              );
            }).toList(),
          ),

          /// TODOS
          header("TODOS"),

          ...grouped.entries.map((entry) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    entry.key,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  ...entry.value.map((todo) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 5),
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Title: ${formatValue(todo["title"])}"),
                          pw.Text("Status: ${formatValue(todo["status"])}"),
                          pw.Text("Date: ${formatValue(todo["createdAt"])}"),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),

          pw.SizedBox(height: 10),

          pw.Center(
            child: pw.Text(
              "Generated on ${DateTime.now()}",
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  /// EXPORT FILE
  Future<void> exportUserData() async {
    try {
      isLoading.value = true;

      final pdf = await buildPdf();

      final dir = await getExternalStorageDirectory();
      final file = File("${dir!.path}/user_report.pdf");

      await file.writeAsBytes(await pdf.save());

      exportPath.value = file.path;

      Get.snackbar("Success", "PDF downloaded");

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// SHARE
  Future<void> shareFile() async {
    if (exportPath.value.isEmpty) return;

    await Share.shareXFiles([XFile(exportPath.value)]);
  }
}