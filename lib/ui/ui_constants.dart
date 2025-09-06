// Токены дизайна, синхронизированные с веб-версией
import 'package:flutter/material.dart';

class UI {
  // Цвета
  static const Color background = Color(0xFF0F0C0B);
  static const Color card = Color(0xFF171412);
  static const Color border = Color(0xFF24201E);

  static const Color primary = Color(0xFFFF8A00);
  static const Color primaryGlow = Color(0xFFFFC262);

  static const Color muted = Color(0xFF9A9A9A);
  static const Color white = Colors.white;

  // Радиусы
  static const double radiusLg = 8;
  static const double radiusSm = 4;

  // Высоты
  static const double buttonHeight = 44;

  // Градиенты
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [primary, primaryGlow],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Тени (если понадобятся)
  static const BoxShadow cardShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 30,
    offset: Offset(0, 10),
  );

  // Адаптивные размеры
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 600 && width < 900;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 900;
  }

  // Адаптивные отступы
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(12);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Адаптивные размеры шрифтов
  static double getTitleFontSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 20;
    } else if (isMediumScreen(context)) {
      return 24;
    } else {
      return 28;
    }
  }

  static double getSubtitleFontSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 16;
    } else {
      return 18;
    }
  }

  static double getBodyFontSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 14;
    } else {
      return 16;
    }
  }

  // Адаптивные размеры элементов
  static double getButtonHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 40;
    } else {
      return 44;
    }
  }

  static double getAvatarSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 24;
    } else {
      return 32;
    }
  }

  static double getIconSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 16;
    } else {
      return 20;
    }
  }
}


