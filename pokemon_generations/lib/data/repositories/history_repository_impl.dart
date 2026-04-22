import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/models/history.dart';
import '../../domain/repositories/history_repository.dart';
import '../database/app_database.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final AppDatabase db;

  HistoryRepositoryImpl(this.db);

  @override
  Future<List<AnalysisHistory>> getHistory() async {
    final rows = await (db.select(db.analysisHistoryTable)
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .get();
    
    return rows.map((row) => AnalysisHistory.fromJson(json.decode(row.data))).toList();
  }

  @override
  Future<void> saveHistory(AnalysisHistory history) async {
    await db.into(db.analysisHistoryTable).insert(
      AnalysisHistoryTableCompanion.insert(
        id: history.id,
        timestamp: history.timestamp,
        data: json.encode(history.toJson()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> clearHistory() async {
    await db.delete(db.analysisHistoryTable).go();
  }
}
