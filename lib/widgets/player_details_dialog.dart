import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../ui/ui_constants.dart';
import '../data/supabase_repository.dart';

class PlayerDetailsDialog extends StatefulWidget {
  const PlayerDetailsDialog({super.key, required this.player});

  final Player player;

  @override
  State<PlayerDetailsDialog> createState() => _PlayerDetailsDialogState();
}

class _PlayerDetailsDialogState extends State<PlayerDetailsDialog> {
  bool _obscurePassword = true;
  late Player _currentPlayer;
  final SupabaseRepository _repository = SupabaseRepository();

  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player;
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    try {
      final players = await _repository.getPlayers();
      final updatedPlayer = players.firstWhere(
        (p) => p.id == _currentPlayer.id,
        orElse: () => _currentPlayer,
      );
      if (mounted) {
        setState(() {
          _currentPlayer = updatedPlayer;
        });
      }
    } catch (e) {
      // Если не удалось обновить данные игрока, используем текущие
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UI.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UI.radiusLg),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: _currentPlayer.avatar_url != null
                ? NetworkImage(_currentPlayer.avatar_url!)
                : null,
            child: _currentPlayer.avatar_url == null
                ? Text(
                    _currentPlayer.name.isNotEmpty
                        ? _currentPlayer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: UI.textPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Данные игрока',
              style: TextStyle(
                fontSize: UI.getTitleFontSize(context),
                color: UI.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Имя', _currentPlayer.name),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Дата рождения',
              _formatDate(_currentPlayer.birth_date),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Логин', _currentPlayer.login),
            const SizedBox(height: 16),
            _buildPasswordRow(
              'Пароль',
              _currentPlayer.password ?? 'Не установлен',
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Общие баллы', _currentPlayer.total_points.toString()),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Посещений',
              _currentPlayer.attendance_count.toString(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: UI.muted),
          child: Text(
            'Закрыть',
            style: TextStyle(fontSize: UI.getBodyFontSize(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: UI.getBodyFontSize(context),
            color: UI.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: UI.background,
            borderRadius: BorderRadius.circular(UI.radiusSm),
            border: Border.all(color: UI.border),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: UI.getBodyFontSize(context),
              color: UI.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: UI.getBodyFontSize(context),
            color: UI.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: UI.background,
            borderRadius: BorderRadius.circular(UI.radiusSm),
            border: Border.all(color: UI.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _obscurePassword ? '••••••••' : value,
                  style: TextStyle(
                    fontSize: UI.getBodyFontSize(context),
                    color: UI.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: UI.muted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: UI.muted, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Пароль скопирован в буфер обмена'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Не указана';
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.year}';
    } catch (e) {
      return date; // Возвращаем исходную строку, если не удалось распарсить
    }
  }
}
