import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> downloadFileFromUrl(String url, String filename) async {
  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.isDenied) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        print('Manage external storage permission denied');
        return;
      }
    }
  }

  try {
    final dir = Directory('/storage/emulated/0/Download');
    final filePath = '${dir.path}/$filename';

    await Dio().download(url, filePath);
    print('File downloaded to: $filePath');
  } catch (e) {
    print('Download error: $e');
  }
}
