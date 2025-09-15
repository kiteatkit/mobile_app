import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/ui_constants.dart';
import '../services/auth_storage_service.dart';

class ModeSelectPage extends StatefulWidget {
  const ModeSelectPage({super.key});

  @override
  State<ModeSelectPage> createState() => _ModeSelectPageState();
}

class _ModeSelectPageState extends State<ModeSelectPage> {
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    try {
      final hasValidLogin = await AuthStorageService.hasValidLoginData();
      if (hasValidLogin && mounted) {
        final userType = await AuthStorageService.getUserType();
        if (userType == 'coach') {
          context.go('/dashboard/coach');
          return;
        } else if (userType == 'player') {
          final player = await AuthStorageService.getPlayerData();
          if (player != null) {
            context.go('/dashboard/player', extra: player);
            return;
          }
        }
      }
    } catch (e) {
      print('Ошибка при проверке сохраненного входа: $e');
    }
    
    if (mounted) {
      setState(() => _checkingAuth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return Scaffold(
        backgroundColor: UI.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: UI.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                // Анимированный логотип с прыжком
                BasketballBounceAnimation(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo_red.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Викинги',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: UI.fontWeightBold,
                          color: UI.primary,
                          letterSpacing: 1.2,
                          fontFamily: UI.fontFamilyHeading,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                BounceInAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Система управления баскетбольной командой',
                    style: TextStyle(
                      color: UI.textMuted,
                      fontSize: 16,
                      fontWeight: UI.fontWeightMedium,
                      fontFamily: UI.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Анимированная карточка
                BounceInAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: AnimatedCard(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      decoration: BoxDecoration(
                        gradient: UI.gradientCard,
                        borderRadius: BorderRadius.circular(UI.radiusLg * 2),
                        border: Border.all(color: UI.border),
                        boxShadow: [UI.cardShadow],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, color: UI.primary, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Выберите режим входа',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: UI.textPrimary,
                                  fontWeight: UI.fontWeightBold,
                                  fontFamily: UI.fontFamilyHeading,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Кнопка входа игрока
                          AnimatedButton(
                            onPressed: () => context.go('/login/player'),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: UI.gradientPrimary,
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                boxShadow: [UI.buttonShadow],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: UI.textPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Вход игрока',
                                    style: TextStyle(
                                      color: UI.textPrimary,
                                      fontWeight: UI.fontWeightBold,
                                      fontSize: 16,
                                      fontFamily: UI.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Кнопка входа тренера
                          AnimatedButton(
                            onPressed: () => context.go('/login/coach'),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: UI.textPrimary,
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                border: Border.all(color: UI.primary, width: 2),
                                boxShadow: [UI.buttonShadow],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sports,
                                    color: UI.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Вход тренера',
                                    style: TextStyle(
                                      color: UI.primary,
                                      fontWeight: UI.fontWeightBold,
                                      fontSize: 16,
                                      fontFamily: UI.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Анимация прыжка баскетбольного мяча
class BasketballBounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const BasketballBounceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<BasketballBounceAnimation> createState() => _BasketballBounceAnimationState();
}

class _BasketballBounceAnimationState extends State<BasketballBounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    
    // Анимация прыжка (движение вверх-вниз)
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -20.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Анимация масштаба (сжатие при приземлении)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
    ));

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
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
