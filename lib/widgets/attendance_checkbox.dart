import 'package:flutter/material.dart';
import '../ui/ui_constants.dart';

class AttendanceCheckbox extends StatefulWidget {
  const AttendanceCheckbox({
    super.key,
    required this.playerId,
    required this.trainingId,
    required this.points,
    required this.onChanged,
    required this.onEditPoints,
  });

  final String playerId;
  final String trainingId;
  final int points;
  final Function(String playerId, String trainingId, int points) onChanged;
  final Function(String playerId, String trainingId, int currentPoints) onEditPoints;

  @override
  Key? get key => ValueKey('${playerId}_$trainingId');

  @override
  State<AttendanceCheckbox> createState() => _AttendanceCheckboxState();
}

class _AttendanceCheckboxState extends State<AttendanceCheckbox> {
  late int _currentPoints;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.points;
  }

  @override
  void didUpdateWidget(AttendanceCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем только если значение действительно изменилось и мы не в процессе обновления
    if (oldWidget.points != widget.points && !_isUpdating) {
      // Используем SchedulerBinding для отложенного обновления
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isUpdating) {
          setState(() {
            _currentPoints = widget.points;
          });
        }
      });
    }
  }

  Future<void> _handleCheckboxChange(bool? value) async {
    if (_isUpdating) return;
    
    setState(() {
      _isUpdating = true;
    });

    try {
      final newPoints = value == true ? 3 : 0;
      await widget.onChanged(widget.playerId, widget.trainingId, newPoints);
      
      if (mounted) {
        setState(() {
          _currentPoints = newPoints;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        children: [
          Checkbox(
            value: _currentPoints > 0,
            onChanged: _isUpdating ? null : _handleCheckboxChange,
            activeColor: UI.primary,
            checkColor: UI.white,
            side: const BorderSide(color: UI.primary, width: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: GestureDetector(
              onTap: _isUpdating ? null : () => _showPointsDialog(),
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: UI.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: UI.primary.withOpacity(0.3)),
                ),
                child: Center(
                  child: _isUpdating
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: UI.primary,
                          ),
                        )
                      : Text(
                          _currentPoints.toString(),
                          style: const TextStyle(
                            color: UI.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPointsDialog() {
    widget.onEditPoints(widget.playerId, widget.trainingId, _currentPoints);
  }
}
