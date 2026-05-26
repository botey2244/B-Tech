import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/admin_login_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/category_screen.dart';
import '../screens/contact_seller_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/password_updated_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/receipt_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/register_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/wishlist_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String resetPassword = '/reset-password';
  static const String receipt = '/receipt';
  static const String passwordUpdated = '/password-updated';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String wishlist = '/wishlist';
  static const String contactSeller = '/contact-seller';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
  static const String adminLogin = '/admin-login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case receipt:
        return MaterialPageRoute(builder: (_) => ReceiptScreen());

      case passwordUpdated:
        return MaterialPageRoute(
          builder: (_) => const PasswordUpdatedScreen(),
        );

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoryScreen());

      case productDetail:
        final product = settings.arguments as Product?;

        if (product == null) {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }

        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        );

      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistScreen());

      case contactSeller:
        return MaterialPageRoute(builder: (_) => const ContactSellerScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      case adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case admin:
        return MaterialPageRoute(builder: (_) => const AdminScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
