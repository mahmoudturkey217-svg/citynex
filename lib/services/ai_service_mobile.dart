import 'dart:typed_data';

class AiService {
  Future<String?> classifyImage(Uint8List imageBytes) async {
    // no-op in UI mode — no ML Kit
    return null;
  }
}
