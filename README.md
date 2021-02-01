libPasSQLite
============
It is delphi and object pascal bindings and wrapper around [SQLite library](https://www.sqlite.org). SQLite is library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.



### Table of contents

* [Requierements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Testing](#testing)
* [Raw bindings](#raw-bindings)
* [Object wrapper](#object-wrapper)
* [Query builder](#query-builder)
  * [Usage example](#usage-example-2)
    * [Table schema](#table-schema)
    * [Table](#table)
    * [Insert data](#insert-data-2)
    * [Insert multiple rows](#insert-multiple-rows)
    * [Select data](#select-data-2)
      * [Select all](#select-all)
      * [Select concrete fields](#select-concreate-fields)
      * [Where](#where)
      * [Limit, Offset](#limit-offset)
      * [Join](join)



### Requirements

* [SQLite](https://www.sqlite.org)
* [Embarcadero (R) Rad Studio](https://www.embarcadero.com)
* [Free Pascal Compiler](http://freepascal.org)
* [Lazarus IDE](http://www.lazarus.freepascal.org/) (optional)



Library is tested for 

- Embarcadero (R) Delphi 10.3 on Windows 7 Service Pack 1 (Version 6.1, Build 7601, 64-bit Edition)
- FreePascal Compiler (3.2.0) and Lazarus IDE (2.0.10) on Ubuntu Linux 5.8.0-33-generic x86_64



### Installation

Get the sources and add the *source* directory to the project search path. For FPC add the *source* directory to the *fpc.cfg* file.



### Usage

Clone the repository `git clone https://github.com/isemenkov/libpassqlite`.

Add the unit you want to use to the `uses` clause.



### Testing

A testing framework consists of the following ingredients:
1. Test runner project located in `unit-tests` directory.
2. Test cases (DUnit for Delphi and FPCUnit for FPC based) for all containers classes. 



### Raw bindings

[libpassqlite.pas](https://github.com/isemenkov/libpassqlite/blob/master/source/libpassqlite.pas) file contains the SQLite translated headers to use this library in pascal programs. You can find C API documentation at [SQLite website](https://www.sqlite.org/docs.html).

*More details read on* [wiki page](https://github.com/isemenkov/libpassqlite/wiki/Raw-bindings).



### Object wrapper

[sqlite3.database.pas](https://github.com/isemenkov/libpassqlite/blob/master/source/sqlite3.database.pas) file contains the SQLite object wrapper.

*More details read on* [wiki page](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Database).



### Query builder

[sqlite3.builder.pas](https://github.com/isemenkov/libpassqlite/blob/master/source/sqlite3.builder.pas) file contains the SQLite query builder.

#### Usage example

##### Table schema

[TSQLite3Schema](https://github.com/isemenkov/libpassqlite/blob/master/source/builder/sqlite3.schema.pas) is used to create and validate database table schema.

```pascal
uses
  sqlite3.schema, sqlite3.builder;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;

begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Text('txt').NotNull;

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);

  { Create new database table using the schema. }
  builder.Table('test_table').New(schema);

  FreeAndNil(schema);

  { Check table schema. }
  builder.Table('test_table').CheckSchema(schema); { Return True if the table 
    matches the schema. }

  FreeAndNil(builder);
end;
```

##### Table

[TSQLite3Table](https://github.com/isemenkov/libpassqlite/blob/master/source/builder/sqlite3.table.pas) class contains methods to working with database tables.

```pascal
uses
  sqlite3.schema, sqlite3.builder;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;

begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Text('txt').NotNull;

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);

  { Create new database table using the schema. }
  builder.Table('test_table').New(schema);
  builder.Table('test_table2').NewIfNotExists(schema);

  FreeAndNil(schema);

  { Check if database table is exists. }
  builder.Table('test_table').Exists; { Return True if table exists. }

  { Check if database table has column. }
  builder.Table('test_table').HasColumn('id'); { Return True if table has 
    column 'id'. }

  { Rename exists table. }
  builder.Table('test_table2').Rename('new_table');

  { Drop the table. }
  builder.Table('test_table').Drop;
  builder.Table('new_table').DropIfExists;

  FreeAndNil(builder);
```

##### Insert data

[TSQLite3Insert](https://github.com/isemenkov/libpassqlite/blob/master/source/builder/sqlite3.insert.pas) class contains methods to insert data to database.

```pascal
uses
  sqlite3.schema, sqlite3.builder;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  
begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Integer('int1')
    .Integer('int2')
    .Integer('int3')
    .Text('txt');

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  FreeAndNil(schema);

  inserted_rows := builder.Table('test_table').Insert
    .Value('int1', 12)
    .Value('int2', 43)
    .Value('int3', -54)
    .Value('txt', 'string')
    .Get;

  FreeAndNil(builder);
end;
```

##### Insert multiple rows

```pascal
uses
  sqlite3.schema, sqlite3.builder;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  
begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Integer('int1')
    .Float('int2')
    .Text('int3');

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  FreeAndNil(schema);

  inserted_rows := builder.Table('test_table').Insert
    .Column('val_1', SQLITE_INTEGER)
    .Column('val_2', SQLITE_FLOAT)
    .Column('val_3', SQLITE_TEXT)
    .Row
      .Value(12)
      .Value(3.14)
      .Value('some value')
    .Row
      .Value(54)
      .Value(6.54)
      .Value('string value')
    .Row
      .Value(-874)
      .Value(532.00)
      .Value('test value')
    .Get;

  FreeAndNil(builder);
end;
```

##### Select data

[TSQLite3Select](https://github.com/isemenkov/libpassqlite/blob/master/source/builder/sqlite3.select.pas) class contains methods to select data form database.

###### Select all

```pascal
uses
  sqlite3.schema, sqlite3.builder, sqlite3.result_row;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  
begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Integer('int1')
    .Integer('int2')
    .Integer('int3')
    .Text('txt');

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  FreeAndNil(schema);

  inserted_rows := builder.Table('test_table').Insert
    .Value('int1', 12)
    .Value('int2', 43)
    .Value('int3', -54)
    .Value('txt', 'string')
    .Get;

  for row in builder.Table('test_table').Select.All.Get do
  begin
    row.GetIntegerValue('int1');
    row.GetIntegerValue('int2');
    row.GetIntegerValue('int3');
    row.GetStringValue('txt');
  end;

  FreeAndNil(builder);
end;
```

###### Select concrete fields

```pascal
uses
  sqlite3.schema, sqlite3.builder, sqlite3.result, sqlite3.result_row;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  res : TSQLite3Result;
  row : TSQLite3ResultRow;
  
begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Integer('int1')
    .Integer('int2')
    .Integer('int3')
    .Text('txt');

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  FreeAndNil(schema);

  inserted_rows := builder.Table('test_table').Insert
    .Value('int1', 12)
    .Value('int2', 43)
    .Value('int3', -54)
    .Value('txt', 'string')
    .Get;

  res := builder.Table('test_table').Select
    .Field('int1')
    .Field('txt')
    .Get;

  for row in res do
  begin
    row.GetIntegerValue('int1');
    row.GetStringValue('txt');
  end;

  FreeAndNil(builder);
end;
```

###### Where

```pascal
uses
  sqlite3.schema, sqlite3.builder, sqlite3.result_row;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  
begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Integer('val_1')
    .Float('val_2')
    .Text('val_3');

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  FreeAndNil(schema);

  inserted_rows := builder.Table('test_table').Insert
    .Column('val_1', SQLITE_INTEGER)
    .Column('val_2', SQLITE_FLOAT)
    .Column('val_3', SQLITE_TEXT)
    .Row
      .Value(12)
      .Value(3.14)
      .Value('some value')
    .Row
      .Value(54)
      .Value(6.54)
      .Value('string value')
    .Row
      .Value(-874)
      .Value(532.00)
      .Value('test value')
    .Row
      .Value(471)
      .Value(0.025)
      .ValueNull
    .Get;

  for row in builder.Table('test_table').Select.All
    .Where('val_1',
      TSQLite3Select.TWhereComparisonOperator.COMPARISON_GREATER, 0)
    .WhereNotNull('val_3')
    .Get do
  begin
    row.GetIntegerValue('val_1');
    row.GetDoubleValue('val_2');
    row.GetStringValue('val_3');
  end;

  FreeAndNil(builder);
end;
```

###### Limit, Offset

```pascal
uses
  sqlite3.schema, sqlite3.builder, sqlite3.result_row;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  row : TSQLite3ResultRow;
  
begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Integer('some_value')
    .Text('text_data');

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  FreeAndNil(schema);

  builder.Table('test_table').Insert
    .Value('some_value', 123)
    .Value('text_data', 'string value');

  builder.Table('test_table').Insert
    .Value('some_value', 3431)
    .Value('text_data', 'another text value');

  for row in builder.Table('test_table').Select.All.Limit(1).Offset(1).Get do
  begin
    row.GetIntegerValue('some_value');
    row.GetStringValue('text_data');
  end;

  FreeAndNil(builder);
end;
```

###### Join

```pascal
uses
  sqlite3.schema, sqlite3.builder, sqlite3.result_row;

var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  row : TSQLite3ResultRow;
  inserted_rows : Integer;
  
begin
  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Integer('val_1')
    .Text('str')
    .Integer('key_id');

  builder := TSQLite3Builder.Create('database.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  
  builder.Table('table1').New(schema);
  FreeAndNil(schema);

  schema := TSQLite3Schema.Create;
  schema
    .Id
    .Integer('val_2');

  builder.Table('table2').New(schema);
  FreeAndNil(schema);

  inserted_rows := builder.Table('test_table').Insert
    .Column('val_1', SQLITE_INTEGER)
    .Column('str', SQLITE_TEXT)
    .Column('key_id', SQLITE_INTEGER)
    .Row
      .Value(12)
      .Value('some value')
      .Value(1)
    .Row
      .Value(54)
      .Value('string value')
      .Value(2)
    .Row
      .Value(-874)
      .Value('test value')
      .ValueNull
    .Row
      .Value(471)
      .ValueNull
      .ValueNull
    .Get;

  inserted_rows := builder.Table('table2').Insert
    .Column('val_2', SQLITE_INTEGER)
    .Row.Value(-58)
    .Row.Value(-145)
    .Row.Value(-874)
    .Row.Value(471)
    .Get;

  for row in builder.Table('table1').Select.All
    .LeftJoin('table2', 'id', 'key_id')
    .WhereNotNull('key_id')
    .Get do
  begin
    row.GetIntegerValue('val_1');
    row.GetStringValue('str');
    row.GetIntegerValue('val_2');

  end;

  FreeAndNil(builder);
end;
```