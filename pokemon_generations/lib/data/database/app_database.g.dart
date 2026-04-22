// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PokemonFormsTableTable extends PokemonFormsTable
    with TableInfo<$PokemonFormsTableTable, PokemonFormsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonFormsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<String> pokemonId = GeneratedColumn<String>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pokemonId, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_forms_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonFormsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonFormsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonFormsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pokemon_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $PokemonFormsTableTable createAlias(String alias) {
    return $PokemonFormsTableTable(attachedDatabase, alias);
  }
}

class PokemonFormsTableData extends DataClass
    implements Insertable<PokemonFormsTableData> {
  final String id;
  final String pokemonId;
  final String data;
  const PokemonFormsTableData({
    required this.id,
    required this.pokemonId,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pokemon_id'] = Variable<String>(pokemonId);
    map['data'] = Variable<String>(data);
    return map;
  }

  PokemonFormsTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonFormsTableCompanion(
      id: Value(id),
      pokemonId: Value(pokemonId),
      data: Value(data),
    );
  }

  factory PokemonFormsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonFormsTableData(
      id: serializer.fromJson<String>(json['id']),
      pokemonId: serializer.fromJson<String>(json['pokemonId']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pokemonId': serializer.toJson<String>(pokemonId),
      'data': serializer.toJson<String>(data),
    };
  }

  PokemonFormsTableData copyWith({
    String? id,
    String? pokemonId,
    String? data,
  }) => PokemonFormsTableData(
    id: id ?? this.id,
    pokemonId: pokemonId ?? this.pokemonId,
    data: data ?? this.data,
  );
  PokemonFormsTableData copyWithCompanion(PokemonFormsTableCompanion data) {
    return PokemonFormsTableData(
      id: data.id.present ? data.id.value : this.id,
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonFormsTableData(')
          ..write('id: $id, ')
          ..write('pokemonId: $pokemonId, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pokemonId, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonFormsTableData &&
          other.id == this.id &&
          other.pokemonId == this.pokemonId &&
          other.data == this.data);
}

class PokemonFormsTableCompanion
    extends UpdateCompanion<PokemonFormsTableData> {
  final Value<String> id;
  final Value<String> pokemonId;
  final Value<String> data;
  final Value<int> rowid;
  const PokemonFormsTableCompanion({
    this.id = const Value.absent(),
    this.pokemonId = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonFormsTableCompanion.insert({
    required String id,
    required String pokemonId,
    required String data,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pokemonId = Value(pokemonId),
       data = Value(data);
  static Insertable<PokemonFormsTableData> custom({
    Expression<String>? id,
    Expression<String>? pokemonId,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonFormsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? pokemonId,
    Value<String>? data,
    Value<int>? rowid,
  }) {
    return PokemonFormsTableCompanion(
      id: id ?? this.id,
      pokemonId: pokemonId ?? this.pokemonId,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<String>(pokemonId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonFormsTableCompanion(')
          ..write('id: $id, ')
          ..write('pokemonId: $pokemonId, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamPresetsTableTable extends TeamPresetsTable
    with TableInfo<$TeamPresetsTableTable, TeamPresetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamPresetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_presets_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamPresetsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamPresetsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamPresetsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $TeamPresetsTableTable createAlias(String alias) {
    return $TeamPresetsTableTable(attachedDatabase, alias);
  }
}

class TeamPresetsTableData extends DataClass
    implements Insertable<TeamPresetsTableData> {
  final String id;
  final String name;
  final String data;
  const TeamPresetsTableData({
    required this.id,
    required this.name,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['data'] = Variable<String>(data);
    return map;
  }

  TeamPresetsTableCompanion toCompanion(bool nullToAbsent) {
    return TeamPresetsTableCompanion(
      id: Value(id),
      name: Value(name),
      data: Value(data),
    );
  }

  factory TeamPresetsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamPresetsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'data': serializer.toJson<String>(data),
    };
  }

  TeamPresetsTableData copyWith({String? id, String? name, String? data}) =>
      TeamPresetsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        data: data ?? this.data,
      );
  TeamPresetsTableData copyWithCompanion(TeamPresetsTableCompanion data) {
    return TeamPresetsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamPresetsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamPresetsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.data == this.data);
}

class TeamPresetsTableCompanion extends UpdateCompanion<TeamPresetsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> data;
  final Value<int> rowid;
  const TeamPresetsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamPresetsTableCompanion.insert({
    required String id,
    required String name,
    required String data,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       data = Value(data);
  static Insertable<TeamPresetsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamPresetsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? data,
    Value<int>? rowid,
  }) {
    return TeamPresetsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamPresetsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnalysisHistoryTableTable extends AnalysisHistoryTable
    with TableInfo<$AnalysisHistoryTableTable, AnalysisHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalysisHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, timestamp, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analysis_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalysisHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalysisHistoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalysisHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $AnalysisHistoryTableTable createAlias(String alias) {
    return $AnalysisHistoryTableTable(attachedDatabase, alias);
  }
}

class AnalysisHistoryTableData extends DataClass
    implements Insertable<AnalysisHistoryTableData> {
  final String id;
  final DateTime timestamp;
  final String data;
  const AnalysisHistoryTableData({
    required this.id,
    required this.timestamp,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['data'] = Variable<String>(data);
    return map;
  }

  AnalysisHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return AnalysisHistoryTableCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      data: Value(data),
    );
  }

  factory AnalysisHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalysisHistoryTableData(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'data': serializer.toJson<String>(data),
    };
  }

  AnalysisHistoryTableData copyWith({
    String? id,
    DateTime? timestamp,
    String? data,
  }) => AnalysisHistoryTableData(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    data: data ?? this.data,
  );
  AnalysisHistoryTableData copyWithCompanion(
    AnalysisHistoryTableCompanion data,
  ) {
    return AnalysisHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalysisHistoryTableData(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestamp, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalysisHistoryTableData &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.data == this.data);
}

class AnalysisHistoryTableCompanion
    extends UpdateCompanion<AnalysisHistoryTableData> {
  final Value<String> id;
  final Value<DateTime> timestamp;
  final Value<String> data;
  final Value<int> rowid;
  const AnalysisHistoryTableCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnalysisHistoryTableCompanion.insert({
    required String id,
    required DateTime timestamp,
    required String data,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timestamp = Value(timestamp),
       data = Value(data);
  static Insertable<AnalysisHistoryTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnalysisHistoryTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? timestamp,
    Value<String>? data,
    Value<int>? rowid,
  }) {
    return AnalysisHistoryTableCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalysisHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PCStorageTableTable extends PCStorageTable
    with TableInfo<$PCStorageTableTable, PCStorageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PCStorageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'p_c_storage_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PCStorageTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PCStorageTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PCStorageTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $PCStorageTableTable createAlias(String alias) {
    return $PCStorageTableTable(attachedDatabase, alias);
  }
}

class PCStorageTableData extends DataClass
    implements Insertable<PCStorageTableData> {
  final String id;
  final String data;
  const PCStorageTableData({required this.id, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['data'] = Variable<String>(data);
    return map;
  }

  PCStorageTableCompanion toCompanion(bool nullToAbsent) {
    return PCStorageTableCompanion(id: Value(id), data: Value(data));
  }

  factory PCStorageTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PCStorageTableData(
      id: serializer.fromJson<String>(json['id']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'data': serializer.toJson<String>(data),
    };
  }

  PCStorageTableData copyWith({String? id, String? data}) =>
      PCStorageTableData(id: id ?? this.id, data: data ?? this.data);
  PCStorageTableData copyWithCompanion(PCStorageTableCompanion data) {
    return PCStorageTableData(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PCStorageTableData(')
          ..write('id: $id, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PCStorageTableData &&
          other.id == this.id &&
          other.data == this.data);
}

class PCStorageTableCompanion extends UpdateCompanion<PCStorageTableData> {
  final Value<String> id;
  final Value<String> data;
  final Value<int> rowid;
  const PCStorageTableCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PCStorageTableCompanion.insert({
    required String id,
    required String data,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       data = Value(data);
  static Insertable<PCStorageTableData> custom({
    Expression<String>? id,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PCStorageTableCompanion copyWith({
    Value<String>? id,
    Value<String>? data,
    Value<int>? rowid,
  }) {
    return PCStorageTableCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PCStorageTableCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PokemonFormsTableTable pokemonFormsTable =
      $PokemonFormsTableTable(this);
  late final $TeamPresetsTableTable teamPresetsTable = $TeamPresetsTableTable(
    this,
  );
  late final $AnalysisHistoryTableTable analysisHistoryTable =
      $AnalysisHistoryTableTable(this);
  late final $PCStorageTableTable pCStorageTable = $PCStorageTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pokemonFormsTable,
    teamPresetsTable,
    analysisHistoryTable,
    pCStorageTable,
  ];
}

typedef $$PokemonFormsTableTableCreateCompanionBuilder =
    PokemonFormsTableCompanion Function({
      required String id,
      required String pokemonId,
      required String data,
      Value<int> rowid,
    });
typedef $$PokemonFormsTableTableUpdateCompanionBuilder =
    PokemonFormsTableCompanion Function({
      Value<String> id,
      Value<String> pokemonId,
      Value<String> data,
      Value<int> rowid,
    });

class $$PokemonFormsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonFormsTableTable> {
  $$PokemonFormsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pokemonId => $composableBuilder(
    column: $table.pokemonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PokemonFormsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonFormsTableTable> {
  $$PokemonFormsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pokemonId => $composableBuilder(
    column: $table.pokemonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PokemonFormsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonFormsTableTable> {
  $$PokemonFormsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pokemonId =>
      $composableBuilder(column: $table.pokemonId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$PokemonFormsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonFormsTableTable,
          PokemonFormsTableData,
          $$PokemonFormsTableTableFilterComposer,
          $$PokemonFormsTableTableOrderingComposer,
          $$PokemonFormsTableTableAnnotationComposer,
          $$PokemonFormsTableTableCreateCompanionBuilder,
          $$PokemonFormsTableTableUpdateCompanionBuilder,
          (
            PokemonFormsTableData,
            BaseReferences<
              _$AppDatabase,
              $PokemonFormsTableTable,
              PokemonFormsTableData
            >,
          ),
          PokemonFormsTableData,
          PrefetchHooks Function()
        > {
  $$PokemonFormsTableTableTableManager(
    _$AppDatabase db,
    $PokemonFormsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonFormsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonFormsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonFormsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pokemonId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonFormsTableCompanion(
                id: id,
                pokemonId: pokemonId,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pokemonId,
                required String data,
                Value<int> rowid = const Value.absent(),
              }) => PokemonFormsTableCompanion.insert(
                id: id,
                pokemonId: pokemonId,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PokemonFormsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonFormsTableTable,
      PokemonFormsTableData,
      $$PokemonFormsTableTableFilterComposer,
      $$PokemonFormsTableTableOrderingComposer,
      $$PokemonFormsTableTableAnnotationComposer,
      $$PokemonFormsTableTableCreateCompanionBuilder,
      $$PokemonFormsTableTableUpdateCompanionBuilder,
      (
        PokemonFormsTableData,
        BaseReferences<
          _$AppDatabase,
          $PokemonFormsTableTable,
          PokemonFormsTableData
        >,
      ),
      PokemonFormsTableData,
      PrefetchHooks Function()
    >;
typedef $$TeamPresetsTableTableCreateCompanionBuilder =
    TeamPresetsTableCompanion Function({
      required String id,
      required String name,
      required String data,
      Value<int> rowid,
    });
typedef $$TeamPresetsTableTableUpdateCompanionBuilder =
    TeamPresetsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> data,
      Value<int> rowid,
    });

class $$TeamPresetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TeamPresetsTableTable> {
  $$TeamPresetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamPresetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamPresetsTableTable> {
  $$TeamPresetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamPresetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamPresetsTableTable> {
  $$TeamPresetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$TeamPresetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamPresetsTableTable,
          TeamPresetsTableData,
          $$TeamPresetsTableTableFilterComposer,
          $$TeamPresetsTableTableOrderingComposer,
          $$TeamPresetsTableTableAnnotationComposer,
          $$TeamPresetsTableTableCreateCompanionBuilder,
          $$TeamPresetsTableTableUpdateCompanionBuilder,
          (
            TeamPresetsTableData,
            BaseReferences<
              _$AppDatabase,
              $TeamPresetsTableTable,
              TeamPresetsTableData
            >,
          ),
          TeamPresetsTableData,
          PrefetchHooks Function()
        > {
  $$TeamPresetsTableTableTableManager(
    _$AppDatabase db,
    $TeamPresetsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamPresetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamPresetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamPresetsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamPresetsTableCompanion(
                id: id,
                name: name,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String data,
                Value<int> rowid = const Value.absent(),
              }) => TeamPresetsTableCompanion.insert(
                id: id,
                name: name,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamPresetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamPresetsTableTable,
      TeamPresetsTableData,
      $$TeamPresetsTableTableFilterComposer,
      $$TeamPresetsTableTableOrderingComposer,
      $$TeamPresetsTableTableAnnotationComposer,
      $$TeamPresetsTableTableCreateCompanionBuilder,
      $$TeamPresetsTableTableUpdateCompanionBuilder,
      (
        TeamPresetsTableData,
        BaseReferences<
          _$AppDatabase,
          $TeamPresetsTableTable,
          TeamPresetsTableData
        >,
      ),
      TeamPresetsTableData,
      PrefetchHooks Function()
    >;
typedef $$AnalysisHistoryTableTableCreateCompanionBuilder =
    AnalysisHistoryTableCompanion Function({
      required String id,
      required DateTime timestamp,
      required String data,
      Value<int> rowid,
    });
typedef $$AnalysisHistoryTableTableUpdateCompanionBuilder =
    AnalysisHistoryTableCompanion Function({
      Value<String> id,
      Value<DateTime> timestamp,
      Value<String> data,
      Value<int> rowid,
    });

class $$AnalysisHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $AnalysisHistoryTableTable> {
  $$AnalysisHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnalysisHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalysisHistoryTableTable> {
  $$AnalysisHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnalysisHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalysisHistoryTableTable> {
  $$AnalysisHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$AnalysisHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalysisHistoryTableTable,
          AnalysisHistoryTableData,
          $$AnalysisHistoryTableTableFilterComposer,
          $$AnalysisHistoryTableTableOrderingComposer,
          $$AnalysisHistoryTableTableAnnotationComposer,
          $$AnalysisHistoryTableTableCreateCompanionBuilder,
          $$AnalysisHistoryTableTableUpdateCompanionBuilder,
          (
            AnalysisHistoryTableData,
            BaseReferences<
              _$AppDatabase,
              $AnalysisHistoryTableTable,
              AnalysisHistoryTableData
            >,
          ),
          AnalysisHistoryTableData,
          PrefetchHooks Function()
        > {
  $$AnalysisHistoryTableTableTableManager(
    _$AppDatabase db,
    $AnalysisHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalysisHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalysisHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AnalysisHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnalysisHistoryTableCompanion(
                id: id,
                timestamp: timestamp,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime timestamp,
                required String data,
                Value<int> rowid = const Value.absent(),
              }) => AnalysisHistoryTableCompanion.insert(
                id: id,
                timestamp: timestamp,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnalysisHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalysisHistoryTableTable,
      AnalysisHistoryTableData,
      $$AnalysisHistoryTableTableFilterComposer,
      $$AnalysisHistoryTableTableOrderingComposer,
      $$AnalysisHistoryTableTableAnnotationComposer,
      $$AnalysisHistoryTableTableCreateCompanionBuilder,
      $$AnalysisHistoryTableTableUpdateCompanionBuilder,
      (
        AnalysisHistoryTableData,
        BaseReferences<
          _$AppDatabase,
          $AnalysisHistoryTableTable,
          AnalysisHistoryTableData
        >,
      ),
      AnalysisHistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$PCStorageTableTableCreateCompanionBuilder =
    PCStorageTableCompanion Function({
      required String id,
      required String data,
      Value<int> rowid,
    });
typedef $$PCStorageTableTableUpdateCompanionBuilder =
    PCStorageTableCompanion Function({
      Value<String> id,
      Value<String> data,
      Value<int> rowid,
    });

class $$PCStorageTableTableFilterComposer
    extends Composer<_$AppDatabase, $PCStorageTableTable> {
  $$PCStorageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PCStorageTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PCStorageTableTable> {
  $$PCStorageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PCStorageTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PCStorageTableTable> {
  $$PCStorageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$PCStorageTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PCStorageTableTable,
          PCStorageTableData,
          $$PCStorageTableTableFilterComposer,
          $$PCStorageTableTableOrderingComposer,
          $$PCStorageTableTableAnnotationComposer,
          $$PCStorageTableTableCreateCompanionBuilder,
          $$PCStorageTableTableUpdateCompanionBuilder,
          (
            PCStorageTableData,
            BaseReferences<
              _$AppDatabase,
              $PCStorageTableTable,
              PCStorageTableData
            >,
          ),
          PCStorageTableData,
          PrefetchHooks Function()
        > {
  $$PCStorageTableTableTableManager(
    _$AppDatabase db,
    $PCStorageTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PCStorageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PCStorageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PCStorageTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PCStorageTableCompanion(id: id, data: data, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String data,
                Value<int> rowid = const Value.absent(),
              }) => PCStorageTableCompanion.insert(
                id: id,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PCStorageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PCStorageTableTable,
      PCStorageTableData,
      $$PCStorageTableTableFilterComposer,
      $$PCStorageTableTableOrderingComposer,
      $$PCStorageTableTableAnnotationComposer,
      $$PCStorageTableTableCreateCompanionBuilder,
      $$PCStorageTableTableUpdateCompanionBuilder,
      (
        PCStorageTableData,
        BaseReferences<_$AppDatabase, $PCStorageTableTable, PCStorageTableData>,
      ),
      PCStorageTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PokemonFormsTableTableTableManager get pokemonFormsTable =>
      $$PokemonFormsTableTableTableManager(_db, _db.pokemonFormsTable);
  $$TeamPresetsTableTableTableManager get teamPresetsTable =>
      $$TeamPresetsTableTableTableManager(_db, _db.teamPresetsTable);
  $$AnalysisHistoryTableTableTableManager get analysisHistoryTable =>
      $$AnalysisHistoryTableTableTableManager(_db, _db.analysisHistoryTable);
  $$PCStorageTableTableTableManager get pCStorageTable =>
      $$PCStorageTableTableTableManager(_db, _db.pCStorageTable);
}
