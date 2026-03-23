import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/splash/splash_screen.dart';
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

import 'core/utils/cache_helper.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  DioHelper.init();

  Bloc.observer = MyBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TicketCubit(TicketRepository())),
        BlocProvider(create: (_) => AssignmentCubit(AssignmentRepository())),
        BlocProvider(create: (_) => NotificationCubit(NotificationRepository())),
      ],
      child: MaterialApp(
        title: 'Smart Neighborhood',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D3B66),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
          ),
        ),
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
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
              curve: Curves.easeInOut,
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
      },
    ),
    );
  }
}
