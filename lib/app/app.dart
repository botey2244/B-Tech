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
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MobileScreenFrame extends StatelessWidget {
  const MobileScreenFrame({
    super.key,
    required this.child,
  });

  final Widget? child;

  static const double _mobileWidth = 390;
  static const double _mobileHeight = 844;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return const SizedBox.shrink();
    }

    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isAlreadyMobile = screenSize.width <= 480;

    if (isAlreadyMobile) {
      return child!;
    }

    final availableHeight = screenSize.height - 48;
    final frameHeight = availableHeight.clamp(600.0, _mobileHeight);
    final frameWidth = (frameHeight * (_mobileWidth / _mobileHeight))
        .clamp(320.0, _mobileWidth);
    final framedMediaQuery = mediaQuery.copyWith(
      size: Size(frameWidth, frameHeight),
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
    );

    return ColoredBox(
      color: const Color(0xFFEDEFF5),
      child: Center(
        child: Container(
          width: frameWidth,
          height: frameHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: const Color(0xFFD5D8E2),
              width: 1.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 34,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: MediaQuery(
            data: framedMediaQuery,
            child: child!,
          ),
        ),
      ),
    );
  }
}
