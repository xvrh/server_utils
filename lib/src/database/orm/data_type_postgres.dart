import '../schema/schema.dart';
import 'package:postgres/postgres.dart';
// ignore: implementation_imports
import 'package:postgres/src/binary_codec.dart';

final dataTypePostgres = <DataType, PostgreSQLDataType>{
  DataType.integer: PostgreSQLDataType.integer,
  DataType.integerArray: PostgreSQLDataType.integerArray,
  DataType.bigint: PostgreSQLDataType.bigInteger,
  DataType.smallint: PostgreSQLDataType.smallInteger,
  DataType.serial: PostgreSQLDataType.serial,
  DataType.bigserial: PostgreSQLDataType.bigSerial,
  DataType.text: PostgreSQLDataType.text,
  DataType.name: PostgreSQLDataType.name,
  DataType.textArray: PostgreSQLDataType.textArray,
  DataType.characterVarying: PostgreSQLDataType.varChar,
  DataType.character: PostgreSQLDataType.varChar,
  DataType.real: PostgreSQLDataType.real,
  DataType.doublePrecision: PostgreSQLDataType.double,
  DataType.doubleArray: PostgreSQLDataType.doubleArray,
  DataType.boolean: PostgreSQLDataType.boolean,
  DataType.timestampWithTimeZone: PostgreSQLDataType.timestampWithTimezone,
  DataType.timestampWithoutTimeZone:
      PostgreSQLDataType.timestampWithoutTimezone,
  DataType.date: PostgreSQLDataType.date,
  DataType.json: PostgreSQLDataType.json,
  DataType.jsonb: PostgreSQLDataType.jsonb,
  DataType.jsonbArray: PostgreSQLDataType.jsonbArray,
  DataType.bytea: PostgreSQLDataType.byteArray,
  DataType.uuid: PostgreSQLDataType.uuid,
};

final _reverseMap = {
  for (var entry in dataTypePostgres.entries) entry.value: entry.key,
};

DataType dataTypeFromTypeId(int typeId, {required String debugMessage}) {
  var postgresType = PostgresBinaryDecoder.typeMap[typeId];
  if (postgresType == null) {
    // Check here: https://crate.io/docs/crate/reference/en/4.6/interfaces/postgres.html
    throw Exception('PostgresType not found [$typeId] ($debugMessage)');
  }
  var dataType = _reverseMap[postgresType];
  if (dataType == null) {
    throw Exception('DataType not found: [$typeId], [$postgresType]');
  }
  return dataType;
}
