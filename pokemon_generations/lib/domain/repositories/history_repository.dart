import '../models/history.dart';

abstract class HistoryRepository {
  Future<List<AnalysisHistory>> getHistory();
  Future<void> saveHistory(AnalysisHistory history);
  Future<void> clearHistory();
}
