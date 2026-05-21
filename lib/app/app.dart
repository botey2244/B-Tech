import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'routes.dart';

class BTechApp extends StatelessWidget {
  const BTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B Tech',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.onboarding,
      onGenerateRoute: Routes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
