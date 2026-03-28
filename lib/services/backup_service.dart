import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static Future<File> createBackup(Map<String, dynamic> data) async {
    final archive = Archive();

    final jsonString = jsonEncode(data);

    archive.addFile(
      ArchiveFile(
        "backup.json",
        jsonString.length,
        utf8.encode(jsonString),
      ),
    );

    final encoder = ZipEncoder();
    final zipBytes = encoder.encode(archive)!;

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/backup.zip");

    await file.writeAsBytes(zipBytes);

    return file;
  }
}