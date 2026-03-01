// Conditional export: uses stub on web, real ML Kit on mobile
export 'ai_service_stub.dart'
    if (dart.library.io) 'ai_service_mobile.dart';
