// file_downloader_web.dart
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadFileFromUrl(String url, String filename) async {
  try {
    // Fetch file as binary
    final response = await html.HttpRequest.request(
      url,
      method: 'GET',
      responseType: 'arraybuffer',
    );

    final bytes = response.response as ByteBuffer;
    final blob = html.Blob([bytes]);

    // Create a download link and click it
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: blobUrl)
          ..setAttribute("download", filename)
          ..click();

    html.Url.revokeObjectUrl(blobUrl);
  } catch (e) {
    print("Download failed: $e");
  }
}
