import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../supabase_client.dart';
import '../models/player.dart';
import '../ui/ui_constants.dart';
import '../services/auth_storage_service.dart';

class PlayerLoginPage extends StatefulWidget {
  const PlayerLoginPage({super.key});

  @override
  State<PlayerLoginPage> createState() => _PlayerLoginPageState();
}

class _PlayerLoginPageState extends State<PlayerLoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _handleLogin() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();
    if (login.isEmpty || password.isEmpty) {
      setState(() => _error = 'Введите логин и пароль');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await SupabaseManager.client
          .from('players')
          .select('*')
          .eq('login', login)
          .eq('password', password)
          .single();

      final player = Player.fromJson(res);
      
      // Сохраняем данные входа
      await AuthStorageService.saveLoginData(
        userType: 'player',
        player: player,
      );
      
      if (!mounted) return;
      context.go('/dashboard/player', extra: player);
    } catch (e) {
      setState(() => _error = 'Неверный логин или пароль');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UI.background,
      appBar: AppBar(
        backgroundColor: UI.background,
        foregroundColor: UI.black,
        elevation: 0,
        title: Text(
          'Вход игрока',
          style: UI.getHeadingStyle(context, color: UI.black),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: UI.getScreenPadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Анимированный логотип с прыжком
                BasketballBounceAnimation(
                  child: Image.asset(
                    'assets/images/logo_red.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                BounceInAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Вход игрока',
                    style: UI.getHeadingStyle(context, color: UI.primary),
                  ),
                ),
                const SizedBox(height: 8),
                BounceInAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    'Введите свои данные для входа',
                    style: TextStyle(
                      fontSize: UI.getBodyFontSize(context),
                      color: UI.textMuted,
                      fontFamily: UI.fontFamily,
                      fontWeight: UI.fontWeightRegular,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Анимированная форма входа
                BounceInAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: AnimatedCard(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: UI.gradientCard,
                        borderRadius: BorderRadius.circular(UI.radiusLg * 2),
                        border: Border.all(color: UI.border),
                        boxShadow: [UI.cardShadow],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _loginController,
                            style: TextStyle(
                              color: UI.textPrimary,
                              fontFamily: UI.fontFamily,
                              fontWeight: UI.fontWeightRegular,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Логин',
                              labelStyle: TextStyle(
                                color: UI.textMuted,
                                fontFamily: UI.fontFamily,
                                fontWeight: UI.fontWeightMedium,
                              ),
                              filled: true,
                              fillColor: UI.surface,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                borderSide: const BorderSide(color: UI.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                borderSide: const BorderSide(
                                  color: UI.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: UI.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              color: UI.textPrimary,
                              fontFamily: UI.fontFamily,
                              fontWeight: UI.fontWeightRegular,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              labelStyle: TextStyle(
                                color: UI.textMuted,
                                fontFamily: UI.fontFamily,
                                fontWeight: UI.fontWeightMedium,
                              ),
                              filled: true,
                              fillColor: UI.surface,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                borderSide: const BorderSide(color: UI.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                borderSide: const BorderSide(
                                  color: UI.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: UI.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: UI.muted,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: UI.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                border: Border.all(
                                  color: UI.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: UI.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: UI.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          AnimatedButton(
                            onPressed: _loading ? null : _handleLogin,
                            child: Container(
                              width: double.infinity,
                              height: UI.getButtonHeight(context) + 8,
                              decoration: BoxDecoration(
                                gradient: _loading ? null : UI.gradientPrimary,
                                color: _loading ? UI.muted : null,
                                borderRadius: BorderRadius.circular(
                                  UI.radiusLg,
                                ),
                                boxShadow: _loading ? null : [UI.buttonShadow],
                              ),
                              child: _loading
                                  ? const Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                UI.white,
                                              ),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.login,
                                          color: UI.textPrimary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Войти',
                                          style: TextStyle(
                                            fontSize: UI.getBodyFontSize(
                                              context,
                                            ),
                                            fontWeight: UI.fontWeightSemiBold,
                                            color: UI.textPrimary,
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
                const SizedBox(height: 24),
                BounceInAnimation(
                  delay: const Duration(milliseconds: 800),
                  child: AnimatedButton(
                    onPressed: () => context.go('/'),
                    child: Container(
                      width: double.infinity,
                      height: UI.getButtonHeight(context) + 8,
                      decoration: BoxDecoration(
                        color: UI.textPrimary,
                        borderRadius: BorderRadius.circular(UI.radiusLg),
                        border: Border.all(color: UI.primary, width: 2),
                        boxShadow: [UI.buttonShadow],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            color: UI.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Назад',
                            style: TextStyle(
                              fontSize: UI.getBodyFontSize(context),
                              color: UI.primary,
                              fontWeight: UI.fontWeightSemiBold,
                              fontFamily: UI.fontFamily,
                            ),
                          ),
                        ],
                      ),
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
