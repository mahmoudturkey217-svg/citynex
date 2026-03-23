@echo off
rmdir /S /Q lib\screens
rmdir /S /Q lib\models
del /Q lib\services\ai_service.dart
del /Q lib\services\ai_service_mobile.dart
del /Q lib\services\ai_service_stub.dart
del /Q lib\services\email_sender_mobile.dart
del /Q lib\services\email_sender_stub.dart
del /Q lib\services\otp_service.dart
del /Q lib\services\report_service.dart
del /Q lib\services\auth_service.dart
del /Q lib\mock_data.dart
