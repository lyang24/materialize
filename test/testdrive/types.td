# Copyright Materialize, Inc. and contributors. All rights reserved.
#
# Use of this software is governed by the Business Source License
# included in the LICENSE file at the root of this repository.
#
# As of the Change Date specified in that file, in accordance with
# the Business Source License, use of this software will be governed
# by the Apache License, Version 2.0.

$ postgres-connect name=mz_system url=postgres://mz_system:materialize@${testdrive.materialize-internal-sql-addr}

# Without EXTENDED, SHOW TYPES shouldn't have anything to return.
> SHOW TYPES

> SHOW TYPES

> SHOW TYPES FROM pg_catalog
name
---------------------
_bool
_bpchar
_bytea
_char
_date
_daterange
_float4
_float8
_int2
_int2vector
_int4
_int4range
_int8
_int8range
_uint2
_uint4
_uint8
_interval
_jsonb
_mz_aclitem
_mz_timestamp
_numeric
_numrange
_oid
_record
_regclass
_regproc
_regtype
_text
_time
_timestamp
_timestamptz
_tsrange
_tstzrange
_uuid
_varchar
any
anyarray
anycompatible
anycompatiblearray
anycompatiblelist
anycompatiblemap
anycompatiblenonarray
anycompatiblerange
anyelement
anynonarray
anyrange
bool
bpchar
bytea
char
date
daterange
float4
float8
int2
int2vector
int4
int4range
int8
int8range
uint2
uint4
uint8
interval
jsonb
list
map
mz_aclitem
mz_timestamp
numeric
numrange
oid
regclass
regproc
regtype
record
text
time
timestamp
timestamptz
tsrange
tstzrange
uuid
varchar

$ postgres-execute connection=mz_system
ALTER SYSTEM SET max_tables = 10000

# Support creating tables with catalog types and their aliases
> CREATE TABLE bool_t (a bool);
> CREATE TABLE boolean_t (a boolean);

> CREATE TABLE bytea_t (a bytea);
> CREATE TABLE bytes_t (a bytes);

> CREATE TABLE date_t (a date);

> CREATE TABLE float4_t (a float4);
> CREATE TABLE real_t (a real);
> CREATE TABLE float16_t (a float(16));

> CREATE TABLE float8_t (a float8);
> CREATE TABLE float_t (a float);
> CREATE TABLE double_t (a double);

> CREATE TABLE int2_t (a int2);
> CREATE TABLE smallint_t (a smallint);

> CREATE TABLE int4_t (a int4);
> CREATE TABLE int_t (a int);
> CREATE TABLE integer_t (a integer);

> CREATE TABLE int8_t (a int8);
> CREATE TABLE bigint_t (a bigint);

> CREATE TABLE uint2_t (a uint2);

> CREATE TABLE uint4_t (a uint4);

> CREATE TABLE uint8_t (a uint8);

> CREATE TABLE interval_t (a interval);

> CREATE TABLE jsonb_t (a jsonb);
> CREATE TABLE json_t (a json);

> CREATE TABLE numeric_t (a numeric);
> CREATE TABLE decimal_t (a decimal);
> CREATE TABLE dec_t (a dec);

> CREATE TABLE oid_t (a oid);
> CREATE TABLE regclass_t (a regclass);

> CREATE TABLE text_t (a text);
> CREATE TABLE char_t (a char(100));
> CREATE TABLE bpchar_t (a bpchar(100));
> CREATE TABLE varchar_t (a varchar(100));

> CREATE TABLE time_t (a time);

> CREATE TABLE timestamp_t (a timestamp);

> CREATE TABLE timestamptz_t (a timestamptz);

> CREATE TABLE uuid_t (a uuid);

# User-defined types

> CREATE TYPE int_list_c AS LIST (ELEMENT TYPE = int4);
> CREATE TYPE int_map_c AS MAP (KEY TYPE = text, VALUE TYPE = int4);
> CREATE TYPE int_record_c AS (i1 int, i2 int, i3 int);

# User-defined types can use other user-defined types
> CREATE TYPE int_list_list_c AS LIST (ELEMENT TYPE = int_list_c);
> CREATE TYPE int_record_record_c AS (j1 int, j2 int_record_c);

> SHOW TYPES
name
-------------------
int_list_c
int_map_c
int_list_list_c
int_record_c
int_record_record_c

# Allow creating tables using custom types
> CREATE TABLE custom_types (a int_list_c, b int_map_c);

> INSERT INTO custom_types VALUES (LIST[1], '{a=>1}'::int_map_c);

> CREATE TYPE int_array_list AS LIST (ELEMENT TYPE = _int4);

> CREATE TABLE custom_types_2 (a int_array_list);

> INSERT INTO custom_types_2 VALUES (LIST[ARRAY[1]]);

> CREATE TABLE custom_types_3 (a int_record_c, b int_record_record_c);

> INSERT INTO custom_types_3 VALUES (ROW(9, 8, 7), ROW(6, ROW(5, 4, 3)));

# Custom types are namespaced objects
> CREATE SCHEMA other;

> CREATE TYPE other.other_int_list_c AS LIST (ELEMENT TYPE = int4);
> CREATE TYPE other.other_int_map_c AS MAP (KEY TYPE = text, VALUE TYPE = int4);
> CREATE TYPE other.other_record_c AS (a int, b text);

> SHOW TYPES FROM other;
name
----------------
other_int_list_c
other_int_map_c
other_record_c

> CREATE TABLE custom_types_4 (a other.other_int_list_c, b other.other_int_map_c);

> CREATE TYPE int_list_map AS MAP (KEY TYPE = text, VALUE TYPE = other.other_int_list_c)

# Array element types

> CREATE TYPE bool_array_list_c AS LIST (ELEMENT TYPE = _bool);
> CREATE TABLE bool_array_list_t (a bool_array_list_c);
> INSERT INTO bool_array_list_t VALUES (LIST[ARRAY[true]]);

> CREATE TYPE int8_array_list_c AS LIST (ELEMENT TYPE = _int8);
> CREATE TABLE int8_array_list_t (a int8_array_list_c);
> INSERT INTO int8_array_list_t VALUES (LIST[ARRAY[1::int8,2::int8]]);

> CREATE TYPE int4_array_list_c AS LIST (ELEMENT TYPE = _int4);
> CREATE TABLE int4_array_list_t (a int4_array_list_c);
> INSERT INTO int4_array_list_t VALUES (LIST[ARRAY[1,2]]);

> CREATE TYPE text_array_list_c AS LIST (ELEMENT TYPE = _text);
> CREATE TABLE text_array_list_t (a text_array_list_c);
> INSERT INTO text_array_list_t VALUES (LIST[ARRAY['a','b']]);

> CREATE TYPE varchar_array_list_c AS LIST (ELEMENT TYPE = _varchar);
> CREATE TABLE varchar_array_list_t (a varchar_array_list_c);
> INSERT INTO varchar_array_list_t VALUES (LIST[ARRAY['a'::varchar,'b'::varchar]]);

# Enable this when closing #7613
# > CREATE TYPE char_array_list_c AS LIST (ELEMENT TYPE = _char);
# > CREATE TABLE char_array_list_t (a char_array_list_c);
# > INSERT INTO char_array_list_t VALUES (LIST[ARRAY['a'::char,'b'::char]]);

> CREATE TYPE float4_array_list_c AS LIST (ELEMENT TYPE = _float4);
> CREATE TABLE float4_array_list_t (a float4_array_list_c);
> INSERT INTO float4_array_list_t VALUES (LIST[ARRAY[1.2::float4,2.3::float4]]);

> CREATE TYPE float8_array_list_c AS LIST (ELEMENT TYPE = _float8);
> CREATE TABLE float8_array_list_t (a float8_array_list_c);
> INSERT INTO float8_array_list_t VALUES (LIST[ARRAY[1.2::float8,2.3::float8]]);

> CREATE TYPE date_array_list_c AS LIST (ELEMENT TYPE = _date);
> CREATE TABLE date_array_list_t (a date_array_list_c);
> INSERT INTO date_array_list_t VALUES (LIST[ARRAY['2001-01-01'::date]]);

> CREATE TYPE time_array_list_c AS LIST (ELEMENT TYPE = _time);
> CREATE TABLE time_array_list_t (a time_array_list_c);
> INSERT INTO time_array_list_t VALUES (LIST[ARRAY['12:34:56'::time]]);

> CREATE TYPE timestamp_array_list_c AS LIST (ELEMENT TYPE = _timestamp);
> CREATE TABLE timestamp_array_list_t (a timestamp_array_list_c);
> INSERT INTO timestamp_array_list_t VALUES (LIST[ARRAY['2001-01-01 12:34:56'::timestamp]]);

> CREATE TYPE timestamptz_array_list_c AS LIST (ELEMENT TYPE = _timestamptz);
> CREATE TABLE timestamptz_array_list_t (a timestamptz_array_list_c);
> INSERT INTO timestamptz_array_list_t VALUES (LIST[ARRAY['2001-01-01 12:34:56'::timestamptz]]);

> CREATE TYPE interval_array_list_c AS LIST (ELEMENT TYPE = _interval);
> CREATE TABLE interval_array_list_t (a interval_array_list_c);
> INSERT INTO interval_array_list_t VALUES (LIST[ARRAY['1y 2d 3h 4m'::interval]]);

# > CREATE TYPE numeric_array_list_c AS LIST (ELEMENT TYPE = _numeric);
# > CREATE TABLE numeric_array_list_t (a numeric_array_list_c);
# > INSERT INTO numeric_array_list_t VALUES (LIST[ARRAY[1.23, 2.34]]);

> CREATE TYPE jsonb_array_list_c AS LIST (ELEMENT TYPE = _jsonb);
> CREATE TABLE jsonb_array_list_t (a jsonb_array_list_c);
> INSERT INTO jsonb_array_list_t VALUES (LIST[ARRAY['{"1":2}'::jsonb]]);

# Test pg_type_is_visible.

> SELECT PG_TYPE_IS_VISIBLE('bool'::REGTYPE::OID);
pg_type_is_visible
--------------------
true

> CREATE SCHEMA hidden_schema;
> CREATE TYPE hidden_schema.my_hidden_type AS LIST (ELEMENT TYPE = int4);
> CREATE TYPE my_type AS LIST (ELEMENT TYPE = int4);

> SELECT PG_TYPE_IS_VISIBLE(oid::REGTYPE) FROM mz_catalog.mz_types WHERE name='my_hidden_type';
pg_type_is_visible
--------------------
false

> SELECT PG_TYPE_IS_VISIBLE(oid::REGTYPE) FROM mz_catalog.mz_types WHERE name='my_type';
pg_type_is_visible
--------------------
true

# Ensure we don't allow unknown options
! CREATE TYPE whatever AS LIST (ELEMENT TYPE = int4, gus=int4);
contains:Expected ELEMENT, found identifier

$ postgres-execute connection=mz_system
ALTER SYSTEM RESET ALL
