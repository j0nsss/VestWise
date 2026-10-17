// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetCalendarEventModelCollection on Isar {
  IsarCollection<CalendarEventModel> get calendarEventModels =>
      this.collection();
}

const CalendarEventModelSchema = CollectionSchema(
  name: r'CalendarEventModel',
  id: 15124112474898114,
  properties: {
    r'colorValue': PropertySchema(
      id: 0,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'endDateTime': PropertySchema(
      id: 2,
      name: r'endDateTime',
      type: IsarType.dateTime,
    ),
    r'hasReminder': PropertySchema(
      id: 3,
      name: r'hasReminder',
      type: IsarType.bool,
    ),
    r'isAllDay': PropertySchema(id: 4, name: r'isAllDay', type: IsarType.bool),
    r'linkedTaskId': PropertySchema(
      id: 5,
      name: r'linkedTaskId',
      type: IsarType.long,
    ),
    r'notificationId': PropertySchema(
      id: 6,
      name: r'notificationId',
      type: IsarType.long,
    ),
    r'reminderMinutesBefore': PropertySchema(
      id: 7,
      name: r'reminderMinutesBefore',
      type: IsarType.long,
    ),
    r'repeat': PropertySchema(
      id: 8,
      name: r'repeat',
      type: IsarType.byte,
      enumMap: _CalendarEventModelrepeatEnumValueMap,
    ),
    r'startDateTime': PropertySchema(
      id: 9,
      name: r'startDateTime',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(id: 10, name: r'title', type: IsarType.string),
  },

  estimateSize: _calendarEventModelEstimateSize,
  serialize: _calendarEventModelSerialize,
  deserialize: _calendarEventModelDeserialize,
  deserializeProp: _calendarEventModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'startDateTime': IndexSchema(
      id: -3620130561466801489,
      name: r'startDateTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startDateTime',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _calendarEventModelGetId,
  getLinks: _calendarEventModelGetLinks,
  attach: _calendarEventModelAttach,
  version: '3.4.1',
);

int _calendarEventModelEstimateSize(
  CalendarEventModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _calendarEventModelSerialize(
  CalendarEventModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorValue);
  writer.writeString(offsets[1], object.description);
  writer.writeDateTime(offsets[2], object.endDateTime);
  writer.writeBool(offsets[3], object.hasReminder);
  writer.writeBool(offsets[4], object.isAllDay);
  writer.writeLong(offsets[5], object.linkedTaskId);
  writer.writeLong(offsets[6], object.notificationId);
  writer.writeLong(offsets[7], object.reminderMinutesBefore);
  writer.writeByte(offsets[8], object.repeat.index);
  writer.writeDateTime(offsets[9], object.startDateTime);
  writer.writeString(offsets[10], object.title);
}

CalendarEventModel _calendarEventModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CalendarEventModel();
  object.colorValue = reader.readLong(offsets[0]);
  object.description = reader.readStringOrNull(offsets[1]);
  object.endDateTime = reader.readDateTimeOrNull(offsets[2]);
  object.hasReminder = reader.readBool(offsets[3]);
  object.id = id;
  object.isAllDay = reader.readBool(offsets[4]);
  object.linkedTaskId = reader.readLongOrNull(offsets[5]);
  object.notificationId = reader.readLongOrNull(offsets[6]);
  object.reminderMinutesBefore = reader.readLongOrNull(offsets[7]);
  object.repeat =
      _CalendarEventModelrepeatValueEnumMap[reader.readByteOrNull(
        offsets[8],
      )] ??
      EventRepeat.none;
  object.startDateTime = reader.readDateTime(offsets[9]);
  object.title = reader.readString(offsets[10]);
  return object;
}

P _calendarEventModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (_CalendarEventModelrepeatValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              EventRepeat.none)
          as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CalendarEventModelrepeatEnumValueMap = {
  'none': 0,
  'daily': 1,
  'weekly': 2,
  'monthly': 3,
  'yearly': 4,
};
const _CalendarEventModelrepeatValueEnumMap = {
  0: EventRepeat.none,
  1: EventRepeat.daily,
  2: EventRepeat.weekly,
  3: EventRepeat.monthly,
  4: EventRepeat.yearly,
};

Id _calendarEventModelGetId(CalendarEventModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _calendarEventModelGetLinks(
  CalendarEventModel object,
) {
  return [];
}

void _calendarEventModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  CalendarEventModel object,
) {
  object.id = id;
}

extension CalendarEventModelQueryWhereSort
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QWhere> {
  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhere>
  anyStartDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startDateTime'),
      );
    });
  }
}

extension CalendarEventModelQueryWhere
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QWhereClause> {
  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
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

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
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

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
  startDateTimeEqualTo(DateTime startDateTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'startDateTime',
          value: [startDateTime],
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
  startDateTimeNotEqualTo(DateTime startDateTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startDateTime',
                lower: [],
                upper: [startDateTime],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startDateTime',
                lower: [startDateTime],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startDateTime',
                lower: [startDateTime],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startDateTime',
                lower: [],
                upper: [startDateTime],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
  startDateTimeGreaterThan(DateTime startDateTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startDateTime',
          lower: [startDateTime],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
  startDateTimeLessThan(DateTime startDateTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startDateTime',
          lower: [],
          upper: [startDateTime],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterWhereClause>
  startDateTimeBetween(
    DateTime lowerStartDateTime,
    DateTime upperStartDateTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startDateTime',
          lower: [lowerStartDateTime],
          includeLower: includeLower,
          upper: [upperStartDateTime],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CalendarEventModelQueryFilter
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QFilterCondition> {
  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  colorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'colorValue', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  colorValueGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'colorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  colorValueLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'colorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  colorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'colorValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'description'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'description'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  endDateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endDateTime'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  endDateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endDateTime'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  endDateTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endDateTime', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  endDateTimeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endDateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  endDateTimeLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endDateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  endDateTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endDateTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  hasReminderEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasReminder', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
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

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
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

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
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

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  isAllDayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isAllDay', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  linkedTaskIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedTaskId'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  linkedTaskIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedTaskId'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  linkedTaskIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedTaskId', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  linkedTaskIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedTaskId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  linkedTaskIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedTaskId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  linkedTaskIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedTaskId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  notificationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notificationId'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  notificationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notificationId'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  notificationIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notificationId', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  notificationIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notificationId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  notificationIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notificationId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  notificationIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notificationId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  reminderMinutesBeforeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reminderMinutesBefore'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  reminderMinutesBeforeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reminderMinutesBefore'),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  reminderMinutesBeforeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reminderMinutesBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  reminderMinutesBeforeGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reminderMinutesBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  reminderMinutesBeforeLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reminderMinutesBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  reminderMinutesBeforeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reminderMinutesBefore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  repeatEqualTo(EventRepeat value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'repeat', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  repeatGreaterThan(EventRepeat value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'repeat',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  repeatLessThan(EventRepeat value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'repeat',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  repeatBetween(
    EventRepeat lower,
    EventRepeat upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'repeat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  startDateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startDateTime', value: value),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  startDateTimeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startDateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  startDateTimeLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startDateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  startDateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startDateTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension CalendarEventModelQueryObject
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QFilterCondition> {}

extension CalendarEventModelQueryLinks
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QFilterCondition> {}

extension CalendarEventModelQuerySortBy
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QSortBy> {
  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByEndDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDateTime', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByEndDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDateTime', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByHasReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReminder', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByHasReminderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReminder', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByIsAllDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAllDay', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByIsAllDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAllDay', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByLinkedTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTaskId', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByLinkedTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTaskId', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutesBefore', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByReminderMinutesBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutesBefore', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByRepeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeat', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByRepeatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeat', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByStartDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDateTime', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByStartDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDateTime', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension CalendarEventModelQuerySortThenBy
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QSortThenBy> {
  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByEndDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDateTime', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByEndDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDateTime', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByHasReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReminder', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByHasReminderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReminder', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByIsAllDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAllDay', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByIsAllDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAllDay', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByLinkedTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTaskId', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByLinkedTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTaskId', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutesBefore', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByReminderMinutesBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutesBefore', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByRepeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeat', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByRepeatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeat', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByStartDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDateTime', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByStartDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDateTime', Sort.desc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension CalendarEventModelQueryWhereDistinct
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct> {
  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByEndDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDateTime');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByHasReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasReminder');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByIsAllDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAllDay');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByLinkedTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedTaskId');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationId');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMinutesBefore');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByRepeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeat');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByStartDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDateTime');
    });
  }

  QueryBuilder<CalendarEventModel, CalendarEventModel, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension CalendarEventModelQueryProperty
    on QueryBuilder<CalendarEventModel, CalendarEventModel, QQueryProperty> {
  QueryBuilder<CalendarEventModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CalendarEventModel, int, QQueryOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<CalendarEventModel, String?, QQueryOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<CalendarEventModel, DateTime?, QQueryOperations>
  endDateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDateTime');
    });
  }

  QueryBuilder<CalendarEventModel, bool, QQueryOperations>
  hasReminderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasReminder');
    });
  }

  QueryBuilder<CalendarEventModel, bool, QQueryOperations> isAllDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAllDay');
    });
  }

  QueryBuilder<CalendarEventModel, int?, QQueryOperations>
  linkedTaskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedTaskId');
    });
  }

  QueryBuilder<CalendarEventModel, int?, QQueryOperations>
  notificationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationId');
    });
  }

  QueryBuilder<CalendarEventModel, int?, QQueryOperations>
  reminderMinutesBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMinutesBefore');
    });
  }

  QueryBuilder<CalendarEventModel, EventRepeat, QQueryOperations>
  repeatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeat');
    });
  }

  QueryBuilder<CalendarEventModel, DateTime, QQueryOperations>
  startDateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDateTime');
    });
  }

  QueryBuilder<CalendarEventModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
