$base = "f:\Smart_Neighborhood_Reporting_App_New\lib"

# forgot_password and change_password need special import handling - will be edited after copy
Copy-Item "$base\screens\main\auth\ui\screens\forgot_password_screen.dart" "$base\features\auth\ui\forgot_password_screen.dart"
Copy-Item "$base\screens\main\auth\ui\screens\change_password_screen.dart" "$base\features\auth\ui\change_password_screen.dart"

# Home screens
Copy-Item "$base\screens\home_screen.dart" "$base\features\home\home_screen.dart"
Copy-Item "$base\screens\admin_home_screen.dart" "$base\features\home\admin_home_screen.dart"

# Technician screens
Copy-Item "$base\screens\technician_home_screen.dart" "$base\features\technician\technician_home_screen.dart"
Copy-Item "$base\screens\assignment_detail_screen.dart" "$base\features\technician\assignment_detail_screen.dart"

# Tickets
Copy-Item "$base\screens\main\tickets\logic\ticket_cubit.dart" "$base\features\tickets\logic\ticket_cubit.dart"
Copy-Item "$base\screens\main\tickets\logic\ticket_state.dart" "$base\features\tickets\logic\ticket_state.dart"
Copy-Item "$base\screens\tickets_screen.dart" "$base\features\tickets\tickets_screen.dart"
Copy-Item "$base\screens\create_report_screen.dart" "$base\features\tickets\create_report_screen.dart"
Copy-Item "$base\screens\report_details_screen.dart" "$base\features\tickets\report_details_screen.dart"

# Assignments
Copy-Item "$base\screens\main\assignments\logic\assignment_cubit.dart" "$base\features\assignments\logic\assignment_cubit.dart"
Copy-Item "$base\screens\main\assignments\logic\assignment_state.dart" "$base\features\assignments\logic\assignment_state.dart"

# Notifications
Copy-Item "$base\screens\main\notifications\logic\notification_cubit.dart" "$base\features\notifications\logic\notification_cubit.dart"
Copy-Item "$base\screens\main\notifications\logic\notification_state.dart" "$base\features\notifications\logic\notification_state.dart"
Copy-Item "$base\screens\alerts_screen.dart" "$base\features\notifications\alerts_screen.dart"
Copy-Item "$base\screens\notification_preferences_screen.dart" "$base\features\notifications\notification_preferences_screen.dart"

# Profile
Copy-Item "$base\screens\profile_screen.dart" "$base\features\profile\profile_screen.dart"
Copy-Item "$base\screens\personal_info_screen.dart" "$base\features\profile\personal_info_screen.dart"

# Settings
Copy-Item "$base\screens\about_screen.dart" "$base\features\settings\about_screen.dart"
Copy-Item "$base\screens\help_support_screen.dart" "$base\features\settings\help_support_screen.dart"
Copy-Item "$base\screens\location_permission_screen.dart" "$base\features\settings\location_permission_screen.dart"

# Move user_model
Copy-Item "$base\models\user_model.dart" "$base\core\models\user_model.dart"

Write-Host "ALL_COPIES_DONE"
