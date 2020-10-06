unit builder_testcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, sqlite3.builder, sqlite3.schema,
  sqlite3.result_row;

type
  { TSQLite3BuilderTestCase }
  TSQLite3BuilderTestCase = class(TTestCase)
  published
    procedure Test_SQLite3Builder_CreateNewEmpty;
    procedure Test_SQLite3Builder_CreateNewSchema;
    procedure Test_SQLite3Builder_InsertData;
    procedure Test_SQLite3Builder_InsertMultipleData;
    procedure Test_SQLite3Builder_CheckTableSchema;
    procedure Test_SQLite3Builder_SelectLimitOffset;
  end;

implementation

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_CreateNewEmpty;
var
  builder : TSQLite3Builder;
begin
  AssertTrue('Database file already exists', not FileExists('test.db'));
 
  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);

  AssertTrue('Database connection has errors', builder.Errors.Count = 0);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_CreateNewSchema;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
begin
  schema := TSQLite3Schema.Create;
  schema.Id('id').Text('txt').NotNull;

  AssertTrue('Database file already exists', not FileExists('test.db'));
 
  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);   

  AssertTrue('Database table not exists', builder.Table('test_table').Exists);
  AssertTrue('Database table not have id column', 
    builder.Table('test_table').HasColumn('id'));
  AssertTrue('Database table not have txt column', 
    builder.Table('test_table').HasColumn('txt'));

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_InsertData;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('int1').Integer('int2').Integer('int3').Text('txt');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Database table not exists', builder.Table('test_table').Exists);
  AssertTrue('Database table not have id column', 
    builder.Table('test_table').HasColumn('id'));
  AssertTrue('Database table not have int1 column', 
    builder.Table('test_table').HasColumn('int1'));
  AssertTrue('Database table not have int2 column', 
    builder.Table('test_table').HasColumn('int2'));
  AssertTrue('Database table not have int3 column', 
    builder.Table('test_table').HasColumn('int3'));
  AssertTrue('Database table not have txt column', 
    builder.Table('test_table').HasColumn('txt'));

  inserted_rows := 0;
  inserted_rows := builder.Table('test_table').Insert
    .Value('int1', 12)
    .Value('int2', 43)
    .Value('int3', -54)
    .Value('txt', 'string')
    .Get;

  AssertTrue('Database inserted row count is not correct', inserted_rows = 1);

  counter := 0;
  for row in builder.Table('test_table').Select.All.Get do
  begin
    AssertTrue('Selected row ''int1'' column value is not correct', 
      row.GetIntegerValue('int1') = 12);
    AssertTrue('Selected row ''int2'' column value is not correct', 
      row.GetIntegerValue('int2') = 43);
    AssertTrue('Selected row ''int3'' column value is not correct', 
      row.GetIntegerValue('int3') = -54);
    AssertTrue('Selected row ''txt'' column value is not correct', 
      row.GetStringValue('txt') = 'string');

    Inc(counter);
  end;  

  AssertTrue('Database selected rows count is not correct', counter = 1);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_InsertMultipleData;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('val_1').Float('val_2').Text('val_3');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema));

  inserted_rows := 0;
  inserted_rows := builder.Table('test_table').Insert
    .Columns
      .Column('val_1', SQLITE_INTEGER)
      .Column('val_2', SQLITE_FLOAT)
      .Column('val_3', SQLITE_TEXT)
    .Values
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

  AssertTrue('Database inserted rows count is not correct', inserted_rows = 3);



  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');

end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_CheckTableSchema;
var
  schema, schema2 : TSQLite3Schema;
  builder : TSQLite3Builder;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('int_val').Float('float_val').Text('text_val').NotNull;

  schema2 := TSQLite3Schema.Create;
  schema2.Id.Integer('int_val').Float('f_val').Text('text_val').NotNull;

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema));
  AssertTrue('Table ''test_table'' schema checked wrong',
    not builder.Table('test_table').CheckSchema(schema2));

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_SelectLimitOffset;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('some_value').Text('text_data');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema)); 

  AssertTrue('Inserted rows count not correct', 
    builder.Table('test_table').Insert
    .Value('some_value', 123)
    .Value('text_data', 'string value')
    .Get = 1);

  AssertTrue('Inserted rows count not correct',
    builder.Table('test_table').Insert
    .Value('some_value', 3431)
    .Value('text_data', 'another text value')
    .Get = 1);
  
  counter := 0;
  for row in builder.Table('test_table').Select.All.Limit(1).Get do
  begin
    AssertTrue('Selected row ''some_value'' column value is not correct',
      row.GetIntegerValue('some_value') = 123);
    AssertTrue('Selected row ''text_data'' column value is not correct',
      row.GetStringValue('text_data') = 'string value');

    Inc(counter);  
  end;

  AssertTrue('Database selected rows count is not correct', counter = 1);

  counter := 0;
  for row in builder.Table('test_table').Select.All.Limit(1).Offset(1).Get do
  begin
    AssertTrue('Selected row ''some_value'' column value is not correct',
      row.GetIntegerValue('some_value') = 3431);
    AssertTrue('Selected row ''text_data'' column value is not correct',
      row.GetStringValue('text_data') = 'another text value');

    Inc(counter);  
  end;

  AssertTrue('Database selected rows count is not correct', counter = 1);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

initialization
  RegisterTest(TSQLite3BuilderTestCase);
end.

