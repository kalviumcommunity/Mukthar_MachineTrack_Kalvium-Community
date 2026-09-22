import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/machines/machine_details_screen.dart';
import '../screens/inspections/new_inspection_screen.dart';
import '../screens/inspections/inspection_success_screen.dart';
import '../screens/inspections/inspection_details_screen.dart';
import '../screens/records/record_details_screen.dart';
import '../screens/records/report_breakdown_screen.dart';

/// Centralized route definitions and generator for MachineTrack.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String machineDetails = '/machine-details';
  static const String newInspection = '/new-inspection';
  static const String inspectionSuccess = '/inspection-success';
  static const String inspectionDetails = '/inspection-details';
  static const String recordDetails = '/record-details';
  static const String reportBreakdown = '/report-breakdown';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case machineDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MachineDetailsScreen(machineData: args),
        );
      case newInspection:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NewInspectionScreen(initialMachine: args),
        );
      case inspectionSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InspectionSuccessScreen(inspectionData: args),
        );
      case inspectionDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InspectionDetailsScreen(inspectionData: args),
        );
      case recordDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RecordDetailsScreen(recordData: args),
        );
      case reportBreakdown:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReportBreakdownScreen(initialMachine: args),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
