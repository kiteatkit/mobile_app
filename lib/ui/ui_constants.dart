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
}

