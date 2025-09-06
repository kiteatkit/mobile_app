import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../supabase_client.dart';
import '../models/player.dart';
import '../ui/ui_constants.dart';

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
        foregroundColor: UI.white,
        title: Text(
          'Вход игрока',
          style: TextStyle(
            fontSize: UI.getTitleFontSize(context),
            color: UI.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: UI.getScreenPadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Логотип
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: UI.primary,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Вход игрока',
                  style: TextStyle(
                    fontSize: UI.getTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: UI.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Введите свои данные для входа',
                  style: TextStyle(
                    fontSize: UI.getBodyFontSize(context),
                    color: UI.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Форма входа
                Container(
                  padding: UI.getCardPadding(context),
                  decoration: BoxDecoration(
                    color: UI.card,
                    borderRadius: BorderRadius.circular(UI.radiusLg),
                    border: Border.all(color: UI.border),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _loginController,
                        style: const TextStyle(color: UI.white),
                        decoration: InputDecoration(
                          labelText: 'Логин',
                          labelStyle: const TextStyle(color: UI.muted),
                          filled: true,
                          fillColor: UI.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(UI.radiusSm),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: UI.white),
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          labelStyle: const TextStyle(color: UI.muted),
                          filled: true,
                          fillColor: UI.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(UI.radiusSm),
                            borderSide: BorderSide.none,
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
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(UI.radiusSm),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: UI.getButtonHeight(context),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UI.primary,
                            foregroundColor: UI.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(UI.radiusSm),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Войти',
                                  style: TextStyle(
                                    fontSize: UI.getBodyFontSize(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: UI.getButtonHeight(context),
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: UI.border),
                      foregroundColor: UI.white,
                    ),
                    child: Text(
                      'Назад',
                      style: TextStyle(fontSize: UI.getBodyFontSize(context)),
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
