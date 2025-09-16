import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/player_score_row.dart';
import '../models/training_session.dart';
import '../ui/ui_constants.dart';

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
    notifyListeners();
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
    return Row(
      children: [
        Checkbox(
          value: points > 0,
          onChanged: (value) {
            onPointsChanged(playerId, trainingId, value == true ? 3 : 0);
          },
          activeColor: UI.primary,
          checkColor: UI.white,
          side: const BorderSide(color: UI.primary, width: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _showPointsDialog(playerId, trainingId, points),
            child: Container(
              height: 28,
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

  void _showPointsDialog(
    String playerId,
    String trainingId,
    int currentPoints,
  ) {
    if (onEditPoints != null) {
      onEditPoints!(playerId, trainingId, currentPoints);
    }
  }
}
