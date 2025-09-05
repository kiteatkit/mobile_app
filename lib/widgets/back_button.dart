import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/ui_constants.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.text = 'Назад', this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => context.pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: UI.card,
          borderRadius: BorderRadius.circular(UI.radiusLg),
          border: Border.all(color: UI.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios, color: UI.white, size: 16),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                color: UI.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
