import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

/// Root Application Widget for MachineTrack.
class MachineTrackApp extends StatelessWidget {
  const MachineTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MachineTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
