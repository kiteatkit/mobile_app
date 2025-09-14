// Токены дизайна с баскетбольным вайбом
import 'package:flutter/material.dart';

class UI {
  // Баскетбольная цветовая палитра - более светлая и энергичная
  static const Color background = Color(0xFFF8FAFC); // Светло-серый фон
  static const Color card = Color(0xFFFFFFFF); // Белые карточки
  static const Color border = Color(0xFFE2E8F0); // Светлые границы
  static const Color surface = Color(0xFFF1F5F9); // Поверхность для акцентов

  // Коричневая цветовая палитра
  static const Color primary = Color(0xFFCDA47B); // Светло-коричневый основной
  static const Color primaryGlow = Color(0xFFD4B08A); // Светлый коричневый
  static const Color secondary = Color(
    0xFF9F4125,
  ); // Темно-коричневый для текста
  static const Color accent = Color(0xFFCDA47B); // Коричневый акцент
  static const Color success = Color(0xFF48BB78); // Зеленый успех
  static const Color warning = Color(
    0xFF9F4125,
  ); // Темно-коричневое предупреждение
  static const Color info = Color(0xFF4299E1); // Синяя информация

  static const Color muted = Color(0xFF9F4125); // Приглушенный текст
  static const Color white = Colors.white;
  static const Color black = Color(0xFF382020); // Очень темно-коричневый текст

  // Текстовые цвета для лучшей читаемости
  static const Color textPrimary = Color(0xFF382020); // Основной текст
  static const Color textSecondary = Color(0xFF9F4125); // Вторичный текст
  static const Color textMuted = Color(0xFF9F4125); // Приглушенный текст

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

  static const LinearGradient gradientBasketball = LinearGradient(
    colors: [primary, accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientCard = LinearGradient(
    colors: [white, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Тени
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0A382020),
    blurRadius: 20,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow cardShadowHover = BoxShadow(
    color: Color(0x14382020),
    blurRadius: 30,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x1A382020),
    blurRadius: 12,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  // Анимации
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration animationDurationSlow = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);

  static const Curve animationCurve = Curves.easeInOut;
  static const Curve animationCurveBounce = Curves.elasticOut;
  static const Curve animationCurveSmooth = Curves.easeOutCubic;

  // Шрифты
  static const String fontFamily = 'Inter'; // Современный, читаемый шрифт
  static const String fontFamilyHeading = 'Sangha Kali'; // Шрифт для заголовков
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

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

  // Стили для заголовков с шрифтом Sangha Kali
  static TextStyle getHeadingStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamilyHeading,
      fontSize: getTitleFontSize(context),
      fontWeight: fontWeight ?? fontWeightBold,
      color: color ?? textPrimary,
    );
  }

  static TextStyle getSubheadingStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamilyHeading,
      fontSize: getSubtitleFontSize(context),
      fontWeight: fontWeight ?? fontWeightSemiBold,
      color: color ?? textPrimary,
    );
  }
}

// Анимированные виджеты
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration duration;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.duration = UI.animationDuration,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: UI.animationCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
      onTapCancel: widget.onPressed != null
          ? () => _controller.reverse()
          : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value.clamp(0.0, 2.0),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final bool enableHover;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.duration = UI.animationDuration,
    this.enableHover = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: UI.animationCurve));
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _controller, curve: UI.animationCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null && widget.enableHover
          ? (_) => _controller.forward()
          : null,
      onTapUp: widget.onTap != null && widget.enableHover
          ? (_) => _controller.reverse()
          : null,
      onTapCancel: widget.onTap != null && widget.enableHover
          ? () => _controller.reverse()
          : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value.clamp(0.0, 2.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  UI.cardShadow.copyWith(
                    blurRadius: 20 + _elevationAnimation.value.clamp(0.0, 20.0),
                    offset: Offset(
                      0,
                      4 + _elevationAnimation.value.clamp(0.0, 20.0),
                    ),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class BounceInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const BounceInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = UI.animationDurationSlow,
  });

  @override
  State<BounceInAnimation> createState() => _BounceInAnimationState();
}

class _BounceInAnimationState extends State<BounceInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final clampedValue = _animation.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clampedValue,
          child: Opacity(opacity: clampedValue, child: widget.child),
        );
      },
    );
  }
}
