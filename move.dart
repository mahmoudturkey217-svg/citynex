import 'dart:io';

void main() {
  final basePath = 'f:/Smart_Neighborhood_Reporting_App_New/lib';
  
  final moves = {
    '$basePath/screens/main/auth/ui/screens/forgot_password_screen.dart': '$basePath/features/auth/ui/forgot_password_screen.dart',
    '$basePath/screens/main/auth/ui/screens/change_password_screen.dart': '$basePath/features/auth/ui/change_password_screen.dart',
    
    // home
    '$basePath/screens/home_screen.dart': '$basePath/features/home/home_screen.dart',
    '$basePath/screens/admin_home_screen.dart': '$basePath/features/home/admin_home_screen.dart',
    
    // technician
    '$basePath/screens/technician_home_screen.dart': '$basePath/features/technician/technician_home_screen.dart',
    '$basePath/screens/assignment_detail_screen.dart': '$basePath/features/technician/assignment_detail_screen.dart',
    
    // tickets
    '$basePath/screens/main/tickets/logic/ticket_cubit.dart': '$basePath/features/tickets/logic/ticket_cubit.dart',
    '$basePath/screens/main/tickets/logic/ticket_state.dart': '$basePath/features/tickets/logic/ticket_state.dart',
    '$basePath/screens/tickets_screen.dart': '$basePath/features/tickets/tickets_screen.dart',
    '$basePath/screens/create_report_screen.dart': '$basePath/features/tickets/create_report_screen.dart',
    '$basePath/screens/report_details_screen.dart': '$basePath/features/tickets/report_details_screen.dart',
    
    // assignments
    '$basePath/screens/main/assignments/logic/assignment_cubit.dart': '$basePath/features/assignments/logic/assignment_cubit.dart',
    '$basePath/screens/main/assignments/logic/assignment_state.dart': '$basePath/features/assignments/logic/assignment_state.dart',
    
    // notifications
    '$basePath/screens/main/notifications/logic/notification_cubit.dart': '$basePath/features/notifications/logic/notification_cubit.dart',
    '$basePath/screens/main/notifications/logic/notification_state.dart': '$basePath/features/notifications/logic/notification_state.dart',
    '$basePath/screens/alerts_screen.dart': '$basePath/features/notifications/alerts_screen.dart',
    '$basePath/screens/notification_preferences_screen.dart': '$basePath/features/notifications/notification_preferences_screen.dart',
    
    // profile & settings
    '$basePath/screens/profile_screen.dart': '$basePath/features/profile/profile_screen.dart',
    '$basePath/screens/personal_info_screen.dart': '$basePath/features/profile/personal_info_screen.dart',
    '$basePath/screens/about_screen.dart': '$basePath/features/settings/about_screen.dart',
    '$basePath/screens/help_support_screen.dart': '$basePath/features/settings/help_support_screen.dart',
    '$basePath/screens/location_permission_screen.dart': '$basePath/features/settings/location_permission_screen.dart',
    
    // core
    '$basePath/models/user_model.dart': '$basePath/core/models/user_model.dart',
  };

  moves.forEach((src, dest) {
    try {
      File file = File(src);
      if (file.existsSync()) {
        File(dest).parent.createSync(recursive: true);
        file.copySync(dest);
        print('Copied: \$src -> \$dest');
      } else {
        print('Missing: \$src');
      }
    } catch (e) {
      print('Error moving \$src: \$e');
    }
  });

  // Now deletes!
  final deletes = [
    '$basePath/services/ai_service.dart',
    '$basePath/services/ai_service_mobile.dart',
    '$basePath/services/ai_service_stub.dart',
    '$basePath/services/email_sender_mobile.dart',
    '$basePath/services/email_sender_stub.dart',
    '$basePath/services/otp_service.dart',
    '$basePath/services/report_service.dart',
    '$basePath/services/auth_service.dart',
    '$basePath/models/report_model.dart',
    '$basePath/mock_data.dart',
  ];
  
  for (var src in deletes) {
    try {
      File file = File(src);
      if (file.existsSync()) {
        file.deleteSync();
        print('Deleted: \$src');
      }
    } catch (e) {}
  }
}
