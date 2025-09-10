import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/supabase_repository.dart';
import '../models/player.dart';
import '../ui/ui_constants.dart';

class PlayerProfilePage extends StatefulWidget {
  const PlayerProfilePage({super.key, required this.player});

  final Player player;

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  final repo = SupabaseRepository();
  final loginCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  Uint8List? avatarBytes;
  String? avatarMime;
  bool saving = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loginCtrl.text = widget.player.login;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      avatarBytes = bytes;
      avatarMime = file.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      String? avatarUrl = widget.player.avatar_url;
      if (avatarBytes != null && avatarMime != null) {
        avatarUrl = await repo.uploadAvatar(
          playerId: widget.player.id,
          bytes: avatarBytes!,
          contentType: avatarMime!,
        );
      }

      // Проверяем совпадение новых паролей
      String? newPassword;
      if (newPassCtrl.text.isNotEmpty) {
        if (newPassCtrl.text != confirmPassCtrl.text) {
          setState(() {
            error = 'Пароли не совпадают';
            saving = false;
          });
          return;
        }
        newPassword = newPassCtrl.text;
      }

      await repo.updatePlayer(
        id: widget.player.id,
        login: loginCtrl.text.trim(),
        password: newPassword,
        avatarUrl: avatarUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = 'Не удалось сохранить профиль';
      });
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
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
          'Профиль игрока',
          style: TextStyle(
            fontSize: UI.getTitleFontSize(context),
            color: UI.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UI.getScreenPadding(context),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Аватар
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: UI.isSmallScreen(context) ? 50 : 60,
                      backgroundImage: avatarBytes != null
                          ? MemoryImage(avatarBytes!)
                          : (widget.player.avatar_url != null
                                ? NetworkImage(widget.player.avatar_url!)
                                      as ImageProvider
                                : null),
                      child:
                          (avatarBytes == null &&
                              widget.player.avatar_url == null)
                          ? Text(
                              widget.player.name.isNotEmpty
                                  ? widget.player.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: UI.isSmallScreen(context) ? 32 : 40,
                                fontWeight: FontWeight.bold,
                                color: UI.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: UI.getButtonHeight(context),
                      child: OutlinedButton.icon(
                        onPressed: _pickAvatar,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: UI.border),
                          foregroundColor: UI.white,
                        ),
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: Text(
                          'Выбрать фото',
                          style: TextStyle(
                            fontSize: UI.getBodyFontSize(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Форма редактирования
              Container(
                padding: UI.getCardPadding(context),
                decoration: BoxDecoration(
                  color: UI.card,
                  borderRadius: BorderRadius.circular(UI.radiusLg),
                  border: Border.all(color: UI.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Личная информация',
                      style: TextStyle(
                        fontSize: UI.getSubtitleFontSize(context),
                        fontWeight: FontWeight.bold,
                        color: UI.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: loginCtrl,
                      style: const TextStyle(color: UI.white),
                      decoration: InputDecoration(
                        labelText: 'Логин',
                        labelStyle: const TextStyle(color: UI.muted),
                        filled: true,
                        fillColor: UI.card,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Смена пароля',
                      style: TextStyle(
                        fontSize: UI.getSubtitleFontSize(context),
                        fontWeight: FontWeight.bold,
                        color: UI.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Оставьте поля пустыми, если не хотите менять пароль',
                      style: TextStyle(
                        fontSize: UI.isSmallScreen(context) ? 12 : 14,
                        color: UI.muted,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: UI.background,
                        borderRadius: BorderRadius.circular(UI.radiusSm),
                        border: Border.all(color: UI.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Текущий пароль',
                                  style: TextStyle(
                                    fontSize: UI.getBodyFontSize(context),
                                    color: UI.muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _obscureCurrentPassword
                                      ? '••••••••'
                                      : (widget.player.password ??
                                            'Не установлен'),
                                  style: TextStyle(
                                    fontSize: UI.getBodyFontSize(context),
                                    color: UI.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: UI.muted,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: UI.muted,
                              size: 20,
                            ),
                            onPressed: () {
                              if (widget.player.password != null) {
                                Clipboard.setData(
                                  ClipboardData(text: widget.player.password!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Пароль скопирован в буфер обмена',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPassCtrl,
                      style: const TextStyle(color: UI.white),
                      decoration: InputDecoration(
                        labelText: 'Новый пароль',
                        labelStyle: const TextStyle(color: UI.muted),
                        filled: true,
                        fillColor: UI.card,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.primary),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: UI.muted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureNewPassword,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPassCtrl,
                      style: const TextStyle(color: UI.white),
                      decoration: InputDecoration(
                        labelText: 'Подтвердите пароль',
                        labelStyle: const TextStyle(color: UI.muted),
                        filled: true,
                        fillColor: UI.card,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: UI.primary),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: UI.muted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                    ),

                    if (error != null) ...[
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
                                error!,
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
                        onPressed: saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UI.primary,
                          foregroundColor: UI.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(UI.radiusSm),
                          ),
                        ),
                        child: saving
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
                                'Сохранить',
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
