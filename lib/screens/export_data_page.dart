import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/export_data_page_controller.dart';
import 'pdf_preview_page.dart';

class ExportDataPage extends StatelessWidget {
  ExportDataPage({super.key});

  final controller = Get.put(ExportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export Data")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// PREVIEW BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text("Preview PDF"),

                onPressed: () async {
                  final pdf = await controller.buildPdf();

                  Get.to(() => PdfPreviewPage(pdf: pdf));
                },
              ),
            ),

            const SizedBox(height: 10),

            /// DOWNLOAD BUTTON
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: controller.isLoading.value
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.download),

                label: Text(controller.isLoading.value
                    ? "Exporting..."
                    : "Download PDF"),

                onPressed: controller.isLoading.value
                    ? null
                    : controller.exportUserData,
              ),
            )),

            const SizedBox(height: 10),

            /// SHARE
            Obx(() => ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Share PDF"),
              onPressed: controller.exportPath.value.isEmpty
                  ? null
                  : controller.shareFile,
            )),

            const SizedBox(height: 20),

            /// FILE PATH
            Obx(() => Text(
              controller.exportPath.value,
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }
}