import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/player.dart';
import '../ui/ui_constants.dart';

class GroupSelectionDialog extends StatelessWidget {
  const GroupSelectionDialog({
    super.key,
    required this.player,
    required this.groups,
    required this.onGroupSelected,
  });

  final Player player;
  final List<Group> groups;
  final Function(Group?) onGroupSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UI.card,
      title: Text(
        'Переместить игрока',
        style: const TextStyle(color: UI.white, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${player.name} (@${player.login})',
            style: const TextStyle(color: UI.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Выберите группу:',
            style: TextStyle(color: UI.muted, fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Опция "Без группы"
          _GroupOption(
            group: null,
            isSelected: player.group_id == null,
            onTap: () {
              onGroupSelected(null);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
          // Список групп
          ...groups.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _GroupOption(
                group: group,
                isSelected: player.group_id == group.id,
                onTap: () {
                  onGroupSelected(group);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена', style: TextStyle(color: UI.muted)),
        ),
      ],
    );
  }
}

class _GroupOption extends StatelessWidget {
  const _GroupOption({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  final Group? group;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? UI.primary.withOpacity(0.2) : UI.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? UI.primary : UI.border),
        ),
        child: Row(
          children: [
            if (group != null) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _parseColor(group!.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                group?.name ?? 'Без группы',
                style: TextStyle(
                  color: isSelected ? UI.primary : UI.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: UI.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final value =
        int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0x3B82F6;
    return Color(0xFF000000 | value);
  }
}
