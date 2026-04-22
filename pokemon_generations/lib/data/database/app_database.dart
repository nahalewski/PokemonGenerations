import 'package:drift/drift.dart';
import 'connection.dart';

part 'app_database.g.dart';

class PokemonFormsTable extends Table {
  TextColumn get id => text()();
  TextColumn get pokemonId => text()();
  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class TeamPresetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnalysisHistoryTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class PCStorageTable extends Table {
  TextColumn get id => text()(); // e.g. 'pc_main'
  TextColumn get data => text()(); // JSON list of PokemonForm
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [PokemonFormsTable, TeamPresetsTable, AnalysisHistoryTable, PCStorageTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection());

  @override
  int get schemaVersion => 2;

  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
