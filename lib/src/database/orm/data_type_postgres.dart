import 'schema.dart';
import 'package:postgres/postgres.dart';
import 'package:postgres/src/binary_codec.dart';

final dataTypePostgres = <DataType, PostgreSQLDataType>{
  DataType.integer: PostgreSQLDataType.integer,
  DataType.integerArray: PostgreSQLDataType.integerArray,
  DataType.bigint: PostgreSQLDataType.bigInteger,
  DataType.smallint: PostgreSQLDataType.smallInteger,
  DataType.serial: PostgreSQLDataType.serial,
  DataType.bigserial: PostgreSQLDataType.bigSerial,
  DataType.text: PostgreSQLDataType.text,
  DataType.textArray: PostgreSQLDataType.textArray,
  DataType.characterVarying: PostgreSQLDataType.varChar,
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

DataType dataTypeFromTypeId(int typeId) {
  var postgresType = PostgresBinaryDecoder.typeMap[typeId]!;
  return _reverseMap[postgresType]!;
}
