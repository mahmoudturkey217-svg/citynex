$base = "f:\Smart_Neighborhood_Reporting_App_New\lib"

# Create directories
$dirs = @(
    "$base\features\auth\logic",
    "$base\features\auth\ui",
    "$base\features\splash",
    "$base\features\home",
    "$base\features\technician",
    "$base\features\tickets\logic",
    "$base\features\assignments\logic",
    "$base\features\notifications\logic",
    "$base\features\profile",
    "$base\features\settings"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
Write-Host "DIRS CREATED"

# Move auth logic
Move-Item "$base\screens\main\auth\logic\auth_cubit.dart" "$base\features\auth\logic\" -Force
Move-Item "$base\screens\main\auth\logic\auth_state.dart" "$base\features\auth\logic\" -Force

# Move auth UI
Move-Item "$base\screens\main\auth\ui\screens\login_screen.dart" "$base\features\auth\ui\" -Force
Move-Item "$base\screens\main\auth\ui\screens\register_screen.dart" "$base\features\auth\ui\" -Force
Move-Item "$base\screens\main\auth\ui\screens\forgot_password_screen.dart" "$base\features\auth\ui\" -Force
Move-Item "$base\screens\main\auth\ui\screens\change_password_screen.dart" "$base\features\auth\ui\" -Force
Move-Item "$base\screens\main\onboarding\ui\onboarding_screen.dart" "$base\features\auth\ui\" -Force
Write-Host "AUTH MOVED"

# Move splash
Move-Item "$base\screens\main\splash\splash_screen.dart" "$base\features\splash\" -Force
Write-Host "SPLASH MOVED"

# Move home
Move-Item "$base\screens\home_screen.dart" "$base\features\home\" -Force
Move-Item "$base\screens\admin_home_screen.dart" "$base\features\home\" -Force
Write-Host "HOME MOVED"

# Move technician
Move-Item "$base\screens\technician_home_screen.dart" "$base\features\technician\" -Force
Move-Item "$base\screens\assignment_detail_screen.dart" "$base\features\technician\" -Force
Write-Host "TECHNICIAN MOVED"

# Move tickets
Move-Item "$base\screens\main\tickets\logic\ticket_cubit.dart" "$base\features\tickets\logic\" -Force
Move-Item "$base\screens\main\tickets\logic\ticket_state.dart" "$base\features\tickets\logic\" -Force
Move-Item "$base\screens\tickets_screen.dart" "$base\features\tickets\" -Force
Move-Item "$base\screens\create_report_screen.dart" "$base\features\tickets\" -Force
Move-Item "$base\screens\report_details_screen.dart" "$base\features\tickets\" -Force
Write-Host "TICKETS MOVED"

# Move assignments
Move-Item "$base\screens\main\assignments\logic\assignment_cubit.dart" "$base\features\assignments\logic\" -Force
Move-Item "$base\screens\main\assignments\logic\assignment_state.dart" "$base\features\assignments\logic\" -Force
Write-Host "ASSIGNMENTS MOVED"

# Move notifications
Move-Item "$base\screens\main\notifications\logic\notification_cubit.dart" "$base\features\notifications\logic\" -Force
Move-Item "$base\screens\main\notifications\logic\notification_state.dart" "$base\features\notifications\logic\" -Force
Move-Item "$base\screens\alerts_screen.dart" "$base\features\notifications\" -Force
Move-Item "$base\screens\notification_preferences_screen.dart" "$base\features\notifications\" -Force
Write-Host "NOTIFICATIONS MOVED"

# Move profile
Move-Item "$base\screens\profile_screen.dart" "$base\features\profile\" -Force
Move-Item "$base\screens\personal_info_screen.dart" "$base\features\profile\" -Force
Write-Host "PROFILE MOVED"

# Move settings
Move-Item "$base\screens\about_screen.dart" "$base\features\settings\" -Force
Move-Item "$base\screens\help_support_screen.dart" "$base\features\settings\" -Force
Move-Item "$base\screens\location_permission_screen.dart" "$base\features\settings\" -Force
Write-Host "SETTINGS MOVED"

# Move user_model into core/models
Move-Item "$base\models\user_model.dart" "$base\core\models\" -Force
Write-Host "USER MODEL MOVED"

# Delete unused files
Remove-Item "$base\services\ai_service.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\services\ai_service_mobile.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\services\ai_service_stub.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\services\email_sender_mobile.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\services\email_sender_stub.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\services\otp_service.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\services\report_service.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\services\auth_service.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\models\report_model.dart" -Force -ErrorAction SilentlyContinue
Remove-Item "$base\mock_data.dart" -Force -ErrorAction SilentlyContinue
Write-Host "DEAD FILES DELETED"

# Remove now-empty old directories
Remove-Item "$base\screens\main" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$base\screens" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$base\models" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "OLD DIRS CLEANED"

Write-Host "ALL DONE"
