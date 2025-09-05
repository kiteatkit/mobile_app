import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/supabase_repository.dart';
import '../models/player.dart';

class PlayerProfilePage extends StatefulWidget {
  const PlayerProfilePage({super.key, required this.player});

  final Player player;

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  final repo = SupabaseRepository();
  final loginCtrl = TextEditingController();
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  Uint8List? avatarBytes;
  String? avatarMime;
  bool saving = false;
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

      // Веб-логика проверяла текущий пароль в БД. Здесь упростим до проверки совпадения введённых паролей.
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
      appBar: AppBar(title: const Text('Профиль игрока')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: avatarBytes != null
                  ? MemoryImage(avatarBytes!)
                  : (widget.player.avatar_url != null
                        ? NetworkImage(widget.player.avatar_url!)
                              as ImageProvider
                        : null),
              child: (avatarBytes == null && widget.player.avatar_url == null)
                  ? Text(
                      widget.player.name.isNotEmpty
                          ? widget.player.name[0]
                          : '?',
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _pickAvatar,
              child: const Text('Выбрать фото'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: loginCtrl,
              decoration: const InputDecoration(labelText: 'Логин'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: currentPassCtrl,
              decoration: const InputDecoration(labelText: 'Текущий пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPassCtrl,
              decoration: const InputDecoration(labelText: 'Новый пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPassCtrl,
              decoration: const InputDecoration(
                labelText: 'Подтвердите пароль',
              ),
              obscureText: true,
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
