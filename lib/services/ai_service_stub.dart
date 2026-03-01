/// Stub AI Service for Web (ML Kit not supported on web)
class AiService {
  Future<String?> classifyImage(String imagePath) async => null;

  Future<List<String>> getLabels(String imagePath) async => [];

  void dispose() {}
}
