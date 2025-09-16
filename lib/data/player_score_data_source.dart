import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/player_score_row.dart';
import '../models/training_session.dart';
import '../ui/ui_constants.dart';
import '../widgets/attendance_checkbox.dart';

class PlayerScoreDataSource extends DataGridSource {
  PlayerScoreDataSource({
    required List<PlayerScoreRow> playerRows,
    required List<TrainingSession> trainings,
    required this.isPlayerMode,
    required this.onPointsChanged,
    this.onEditPoints,
  }) {
    _playerRows = playerRows;
    _trainings = trainings;
    _buildDataGridRows();
  }

  List<PlayerScoreRow> _playerRows = [];
  List<TrainingSession> _trainings = [];
  final bool isPlayerMode;
  final Function(String playerId, String trainingId, int points)
  onPointsChanged;
  Function(String playerId, String trainingId, int currentPoints)? onEditPoints;

  List<DataGridRow> _dataGridRows = [];
  
  // Кэш для виджетов чекбоксов
  final Map<String, AttendanceCheckbox> _checkboxCache = {};

  void _buildDataGridRows() {
    _dataGridRows = _playerRows.map<DataGridRow>((playerRow) {
      final cells = <DataGridCell>[
        DataGridCell<String>(
          columnName: 'player',
          value: playerRow.player.name,
        ),
      ];

      // Добавляем ячейки для каждой тренировки
      for (final training in _trainings) {
        final points = playerRow.trainingScores[training.id] ?? 0;
        cells.add(DataGridCell<int>(columnName: training.id, value: points));
      }

      // Добавляем ячейку среднего балла
      cells.add(
        DataGridCell<double>(
          columnName: 'average',
          value: playerRow.averageScore,
        ),
      );

      return DataGridRow(cells: cells);
    }).toList();
  }

  void updateData(
    List<PlayerScoreRow> playerRows,
    List<TrainingSession> trainings,
  ) {
    _playerRows = playerRows;
    _trainings = trainings;
    _buildDataGridRows();
    // Очищаем кэш при полном обновлении данных
    _checkboxCache.clear();
    notifyListeners();
  }

  void updateSingleRow(int index, PlayerScoreRow playerRow) {
    if (index >= 0 && index < _playerRows.length) {
      _playerRows[index] = playerRow;
      
      // Обновляем только одну строку в _dataGridRows
      final cells = <DataGridCell>[
        DataGridCell<String>(
          columnName: 'player',
          value: playerRow.player.name,
        ),
      ];

      // Добавляем ячейки для каждой тренировки
      for (final training in _trainings) {
        final points = playerRow.trainingScores[training.id] ?? 0;
        cells.add(DataGridCell<int>(columnName: training.id, value: points));
      }

      // Добавляем ячейку среднего балла
      cells.add(
        DataGridCell<double>(
          columnName: 'average',
          value: playerRow.averageScore,
        ),
      );

      _dataGridRows[index] = DataGridRow(cells: cells);
      
      // Обновляем кэшированные чекбоксы для этого игрока
      for (final training in _trainings) {
        final cacheKey = '${playerRow.player.id}_${training.id}';
        if (_checkboxCache.containsKey(cacheKey)) {
          final points = playerRow.trainingScores[training.id] ?? 0;
          _checkboxCache[cacheKey] = AttendanceCheckbox(
            key: ValueKey(cacheKey),
            playerId: playerRow.player.id,
            trainingId: training.id,
            points: points,
            onChanged: onPointsChanged,
            onEditPoints: (playerId, trainingId, currentPoints) {
              if (onEditPoints != null) {
                onEditPoints!(playerId, trainingId, currentPoints);
              }
            },
          );
        }
      }
      
      // Уведомляем об изменении только для конкретной строки
      notifyListeners();
    }
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final playerIndex = _dataGridRows.indexOf(row);
    if (playerIndex == -1) return null;

    final playerRow = _playerRows[playerIndex];
    final cells = <Widget>[];

    // Ячейка с именем игрока
    cells.add(_buildPlayerCell(playerRow));

    // Ячейки с баллами за тренировки
    for (final training in _trainings) {
      final points = playerRow.trainingScores[training.id] ?? 0;
      cells.add(
        _buildTrainingScoreCell(playerRow.player.id, training.id, points),
      );
    }

    // Ячейка среднего балла
    cells.add(_buildAverageScoreCell(playerRow.averageScore));

    return DataGridRowAdapter(cells: cells);
  }

  Widget _buildPlayerCell(PlayerScoreRow playerRow) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: UI.border)),
      ),
      child: Center(
        child: Text(
          playerRow.player.name,
          style: const TextStyle(
            color: UI.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTrainingScoreCell(
    String playerId,
    String trainingId,
    int points,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: UI.border, width: 0.5)),
      ),
      child: isPlayerMode
          ? _buildReadOnlyScoreCell(points)
          : _buildEditableScoreCell(playerId, trainingId, points),
    );
  }

  Widget _buildReadOnlyScoreCell(int points) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: UI.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: UI.primary.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          points.toString(),
          style: TextStyle(
            color: UI.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableScoreCell(
    String playerId,
    String trainingId,
    int points,
  ) {
    final cacheKey = '${playerId}_$trainingId';
    
    // Проверяем кэш и возвращаем существующий виджет
    if (_checkboxCache.containsKey(cacheKey)) {
      return _checkboxCache[cacheKey]!;
    }
    
    // Создаем новый виджет и кэшируем его
    final newCheckbox = AttendanceCheckbox(
      key: ValueKey(cacheKey),
      playerId: playerId,
      trainingId: trainingId,
      points: points,
      onChanged: onPointsChanged,
      onEditPoints: (playerId, trainingId, currentPoints) {
        if (onEditPoints != null) {
          onEditPoints!(playerId, trainingId, currentPoints);
        }
      },
    );
    
    _checkboxCache[cacheKey] = newCheckbox;
    return newCheckbox;
  }

  Widget _buildAverageScoreCell(double averageScore) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: UI.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            averageScore.toStringAsFixed(1),
            style: TextStyle(
              color: UI.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

}
