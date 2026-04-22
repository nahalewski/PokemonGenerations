import 'package:drift/web.dart';
import 'package:drift/drift.dart';

QueryExecutor openDatabaseConnection() {
  return WebDatabase('pokemon_generations');
}
