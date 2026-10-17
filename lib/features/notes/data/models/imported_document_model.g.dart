// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imported_document_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetImportedDocumentModelCollection on Isar {
  IsarCollection<ImportedDocumentModel> get importedDocumentModels =>
      this.collection();
}

const ImportedDocumentModelSchema = CollectionSchema(
  name: r'ImportedDocumentModel',
  id: 6867070571161994263,
  properties: {
    r'fileExtension': PropertySchema(
      id: 0,
      name: r'fileExtension',
      type: IsarType.string,
    ),
    r'fileName': PropertySchema(
      id: 1,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'fileSizeBytes': PropertySchema(
      id: 2,
      name: r'fileSizeBytes',
      type: IsarType.long,
    ),
    r'importedAt': PropertySchema(
      id: 3,
      name: r'importedAt',
      type: IsarType.dateTime,
    ),
    r'linkedNoteId': PropertySchema(
      id: 4,
      name: r'linkedNoteId',
      type: IsarType.long,
    ),
    r'relativeFilePath': PropertySchema(
      id: 5,
      name: r'relativeFilePath',
      type: IsarType.string,
    ),
  },

  estimateSize: _importedDocumentModelEstimateSize,
  serialize: _importedDocumentModelSerialize,
  deserialize: _importedDocumentModelDeserialize,
  deserializeProp: _importedDocumentModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'importedAt': IndexSchema(
      id: 5552566418050361863,
      name: r'importedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'importedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _importedDocumentModelGetId,
  getLinks: _importedDocumentModelGetLinks,
  attach: _importedDocumentModelAttach,
  version: '3.4.1',
);

int _importedDocumentModelEstimateSize(
  ImportedDocumentModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fileExtension.length * 3;
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.relativeFilePath.length * 3;
  return bytesCount;
}

void _importedDocumentModelSerialize(
  ImportedDocumentModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fileExtension);
  writer.writeString(offsets[1], object.fileName);
  writer.writeLong(offsets[2], object.fileSizeBytes);
  writer.writeDateTime(offsets[3], object.importedAt);
  writer.writeLong(offsets[4], object.linkedNoteId);
  writer.writeString(offsets[5], object.relativeFilePath);
}

ImportedDocumentModel _importedDocumentModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ImportedDocumentModel();
  object.fileExtension = reader.readString(offsets[0]);
  object.fileName = reader.readString(offsets[1]);
  object.fileSizeBytes = reader.readLong(offsets[2]);
  object.id = id;
  object.importedAt = reader.readDateTime(offsets[3]);
  object.linkedNoteId = reader.readLongOrNull(offsets[4]);
  object.relativeFilePath = reader.readString(offsets[5]);
  return object;
}

P _importedDocumentModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _importedDocumentModelGetId(ImportedDocumentModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _importedDocumentModelGetLinks(
  ImportedDocumentModel object,
) {
  return [];
}

void _importedDocumentModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  ImportedDocumentModel object,
) {
  object.id = id;
}

extension ImportedDocumentModelQueryWhereSort
    on QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QWhere> {
  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhere>
  anyImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'importedAt'),
      );
    });
  }
}

extension ImportedDocumentModelQueryWhere
    on
        QueryBuilder<
          ImportedDocumentModel,
          ImportedDocumentModel,
          QWhereClause
        > {
  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  importedAtEqualTo(DateTime importedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'importedAt', value: [importedAt]),
      );
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  importedAtNotEqualTo(DateTime importedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [],
                upper: [importedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [importedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [importedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [],
                upper: [importedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  importedAtGreaterThan(DateTime importedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [importedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  importedAtLessThan(DateTime importedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [],
          upper: [importedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterWhereClause>
  importedAtBetween(
    DateTime lowerImportedAt,
    DateTime upperImportedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [lowerImportedAt],
          includeLower: includeLower,
          upper: [upperImportedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ImportedDocumentModelQueryFilter
    on
        QueryBuilder<
          ImportedDocumentModel,
          ImportedDocumentModel,
          QFilterCondition
        > {
  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileExtension',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileExtension',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileExtension', value: ''),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileExtensionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileExtension', value: ''),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileSizeBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileSizeBytes', value: value),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileSizeBytesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileSizeBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileSizeBytesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileSizeBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  fileSizeBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileSizeBytes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  importedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importedAt', value: value),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  importedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  importedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  importedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  linkedNoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedNoteId'),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  linkedNoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedNoteId'),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  linkedNoteIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedNoteId', value: value),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  linkedNoteIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedNoteId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  linkedNoteIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedNoteId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  linkedNoteIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedNoteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'relativeFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'relativeFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'relativeFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'relativeFilePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'relativeFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'relativeFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'relativeFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'relativeFilePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'relativeFilePath', value: ''),
      );
    });
  }

  QueryBuilder<
    ImportedDocumentModel,
    ImportedDocumentModel,
    QAfterFilterCondition
  >
  relativeFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'relativeFilePath', value: ''),
      );
    });
  }
}

extension ImportedDocumentModelQueryObject
    on
        QueryBuilder<
          ImportedDocumentModel,
          ImportedDocumentModel,
          QFilterCondition
        > {}

extension ImportedDocumentModelQueryLinks
    on
        QueryBuilder<
          ImportedDocumentModel,
          ImportedDocumentModel,
          QFilterCondition
        > {}

extension ImportedDocumentModelQuerySortBy
    on QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QSortBy> {
  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByFileExtension() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileExtension', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByFileExtensionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileExtension', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByFileSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByLinkedNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedNoteId', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByLinkedNoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedNoteId', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByRelativeFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relativeFilePath', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  sortByRelativeFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relativeFilePath', Sort.desc);
    });
  }
}

extension ImportedDocumentModelQuerySortThenBy
    on QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QSortThenBy> {
  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByFileExtension() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileExtension', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByFileExtensionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileExtension', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByFileSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByLinkedNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedNoteId', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByLinkedNoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedNoteId', Sort.desc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByRelativeFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relativeFilePath', Sort.asc);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QAfterSortBy>
  thenByRelativeFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relativeFilePath', Sort.desc);
    });
  }
}

extension ImportedDocumentModelQueryWhereDistinct
    on QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QDistinct> {
  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QDistinct>
  distinctByFileExtension({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'fileExtension',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QDistinct>
  distinctByFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QDistinct>
  distinctByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSizeBytes');
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QDistinct>
  distinctByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importedAt');
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QDistinct>
  distinctByLinkedNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedNoteId');
    });
  }

  QueryBuilder<ImportedDocumentModel, ImportedDocumentModel, QDistinct>
  distinctByRelativeFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'relativeFilePath',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension ImportedDocumentModelQueryProperty
    on
        QueryBuilder<
          ImportedDocumentModel,
          ImportedDocumentModel,
          QQueryProperty
        > {
  QueryBuilder<ImportedDocumentModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ImportedDocumentModel, String, QQueryOperations>
  fileExtensionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileExtension');
    });
  }

  QueryBuilder<ImportedDocumentModel, String, QQueryOperations>
  fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<ImportedDocumentModel, int, QQueryOperations>
  fileSizeBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSizeBytes');
    });
  }

  QueryBuilder<ImportedDocumentModel, DateTime, QQueryOperations>
  importedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importedAt');
    });
  }

  QueryBuilder<ImportedDocumentModel, int?, QQueryOperations>
  linkedNoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedNoteId');
    });
  }

  QueryBuilder<ImportedDocumentModel, String, QQueryOperations>
  relativeFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relativeFilePath');
    });
  }
}
