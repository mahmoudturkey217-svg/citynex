import 'dart:typed_data';

class StorageService {
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return a placeholder image URL in UI mode
    return 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400';
  }
}
