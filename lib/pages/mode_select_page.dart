import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/ui_constants.dart';

class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                // Анимированный логотип
                BounceInAnimation(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: UI.gradientBasketball,
                          shape: BoxShape.circle,
                          boxShadow: [
                            UI.cardShadow.copyWith(
                              color: UI.primary.withOpacity(0.3),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_basketball,
                          size: 48,
                          color: UI.textPrimary,
                        ),
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

                // Дополнительная информация
                BounceInAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: UI.surface,
                      borderRadius: BorderRadius.circular(UI.radiusLg),
                      border: Border.all(color: UI.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: UI.info, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Выберите подходящий режим для входа в систему',
                            style: TextStyle(
                              color: UI.textMuted,
                              fontSize: 14,
                              fontFamily: UI.fontFamily,
                              fontWeight: UI.fontWeightRegular,
                            ),
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
    );
  }
}
