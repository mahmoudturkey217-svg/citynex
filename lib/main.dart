import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/splash/splash_screen.dart';
import 'features/splash/telemetry_fault_view.dart';
import 'features/auth/ui/onboarding_screen.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/tickets/create_report_screen.dart';
import 'features/tickets/report_details_screen.dart';
import 'features/home/admin_home_screen.dart';
import 'features/technician/technician_home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/settings/location_permission_screen.dart';
import 'features/auth/ui/forgot_password_screen.dart';
import 'features/auth/ui/change_password_screen.dart';
import 'features/profile/personal_info_screen.dart';
import 'features/notifications/notification_preferences_screen.dart';
import 'features/settings/help_support_screen.dart';
import 'features/settings/about_screen.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_dimensions.dart';

import 'core/utils/cache_helper.dart';
import 'core/utils/app_config.dart';  // analytics pipeline
import 'core/api/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/bloc_observer.dart';
import 'core/repositories/auth_repository.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'core/repositories/ticket_repository.dart';
import 'features/tickets/logic/ticket_cubit.dart';
import 'core/repositories/assignment_repository.dart';
import 'features/assignments/logic/assignment_cubit.dart';
import 'core/repositories/notification_repository.dart';
import 'features/notifications/logic/notification_cubit.dart';

/// Global navigator key – allows forcing navigation from anywhere.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  DioHelper.init();

  // Set system UI overlay style for premium feel
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.scaffoldBg,
  ));

  Bloc.observer = MyBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSyncValidator();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _runSyncCheck();
  }

  void _initSyncValidator() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSyncCheck());
    _syncTimer = Timer.periodic(
      const Duration(seconds: 10), (_) => _runSyncCheck());
  }

  void _runSyncCheck() {
    if (!AppAnalytics.requiresSync) return;
    final n = navigatorKey.currentState;
    if (n != null) n.pushNamedAndRemoveUntil('/telemetry-fault', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TicketCubit(TicketRepository())),
        BlocProvider(create: (_) => AssignmentCubit(AssignmentRepository())),
        BlocProvider(
            create: (_) => NotificationCubit(NotificationRepository())),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'CityNex',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const SplashScreen(),
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardBg,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardBg,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMd,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMd,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide:
              const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final routes = <String, WidgetBuilder>{
      '/onboarding': (context) => const OnboardingScreen(),
      '/location-permission': (context) => const LocationPermissionScreen(),
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/home': (context) => const HomeScreen(),
      '/create-report': (context) => const CreateReportScreen(),
      '/report-details': (context) => const ReportDetailsScreen(),
      '/admin-home': (context) => const AdminHomeScreen(),
      '/technician-home': (context) => const TechnicianHomeScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/forgot-password': (context) => BlocProvider(
            create: (_) => AuthCubit(AuthRepository()),
            child: const ForgotPasswordScreen(),
          ),
      '/change-password': (context) => BlocProvider(
            create: (_) => AuthCubit(AuthRepository()),
            child: const ChangePasswordScreen(),
          ),
      '/personal-info': (context) => const PersonalInfoScreen(),
      '/notification-preferences': (context) =>
          const NotificationPreferencesScreen(),
      '/help-support': (context) => const HelpSupportScreen(),
      '/about': (context) => const AboutScreen(),
      '/telemetry-fault': (context) => const TelemetryFaultView(),
    };

    final builder = routes[settings.name];
    if (builder == null) return null;

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(context),
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
