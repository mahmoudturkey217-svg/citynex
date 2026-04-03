class TicketMediaModel {
  final int id;
  final String mediaType;
  final String? mediaUrl;
  final String? storageProvider;
  final String? mimeType;
  final int? fileSize;
  final String? beforeAfter;
  final int sortOrder;
  final String? createdAt;

  // Signed URL fetched separately — starts null, filled after fetch
  String? signedUrl;

  TicketMediaModel({
    required this.id,
    required this.mediaType,
    this.mediaUrl,
    this.storageProvider,
    this.mimeType,
    this.fileSize,
    this.beforeAfter,
    this.sortOrder = 0,
    this.createdAt,
    this.signedUrl,
  });

  factory TicketMediaModel.fromJson(Map<String, dynamic> json) {
    return TicketMediaModel(
      id: json['id'] ?? 0,
      mediaType: json['media_type'] ?? 'Image',
      mediaUrl: json['media_url'],
      storageProvider: json['storage_provider'],
      mimeType: json['mime_type'],
      fileSize: json['file_size'],
      beforeAfter: json['before_after'],
      sortOrder: json['sort_order'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}