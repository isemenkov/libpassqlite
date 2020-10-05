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
  end;

implementation

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_CreateNewEmpty;
var
  builder : TSQLite3Builder;
begin
  AssertTrue('#Test_SQLite3Builder_CreateNewEmpty -> ' +
    'Database file already exists', not FileExists('test.db'));
 
  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);

  AssertTrue('#Test_SQLite3Builder_CreateNewEmpty -> ' +
    'Database connection has errors', builder.Errors.Count = 0);

  FreeAndNil(builder);

  AssertTrue('#Test_SQLite3Builder_CreateNewEmpty -> ' +
    'Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_CreateNewSchema;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
begin
  schema := TSQLite3Schema.Create;
  schema.Id('id').Text('txt').NotNull;

  AssertTrue('#Test_SQLite3Builder_CreateNewSchema -> ' +
    'Database file already exists', not FileExists('test.db'));
 
  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);   

  AssertTrue('#Test_SQLite3Builder_CreateNewSchema -> ' +
    'Database table not exists', builder.Table('test_table').Exists);
  AssertTrue('#Test_SQLite3Builder_CreateNewSchema -> ' +
    'Database table not have id column', 
    builder.Table('test_table').HasColumn('id'));
  AssertTrue('#Test_SQLite3Builder_CreateNewSchema -> ' +
    'Database table not have txt column', 
    builder.Table('test_table').HasColumn('txt'));

  FreeAndNil(builder);

  AssertTrue('#Test_SQLite3Builder_CreateNewEmpty -> ' +
    'Database file not exists', FileExists('test.db'));

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

   AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database file already exists', not FileExists('test.db'));

   builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database table not exists', builder.Table('test_table').Exists);
  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database table not have id column', 
    builder.Table('test_table').HasColumn('id'));
  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database table not have int1 column', 
    builder.Table('test_table').HasColumn('int1'));
  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database table not have int2 column', 
    builder.Table('test_table').HasColumn('int2'));
  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database table not have int3 column', 
    builder.Table('test_table').HasColumn('int3'));
  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database table not have txt column', 
    builder.Table('test_table').HasColumn('txt'));

  inserted_rows := 0;
  inserted_rows := builder.Table('test_table').Insert
    .Value('int1', 12)
    .Value('int2', 43)
    .Value('int3', -54)
    .Value('txt', 'string')
    .Get;

  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database inserted row count is not correct', inserted_rows = 1);

  counter := 0;
  for row in builder.Table('test_table').Select.All.Get do
  begin
    AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
      'Selected row ''int1'' column value is not correct', 
      row.GetIntegerValue('int1') = 12);
    AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
      'Selected row ''int2'' column value is not correct', 
      row.GetIntegerValue('int2') = 43);
    AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
      'Selected row ''int3'' column value is not correct', 
      row.GetIntegerValue('int3') = -54);
    AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
      'Selected row ''txt'' column value is not correct', 
      row.GetStringValue('txt') = 'string');

    Inc(counter);
  end;  

  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database selected rows count is not correct', 
    counter = 1);

  FreeAndNil(builder);

  AssertTrue('#Test_SQLite3Builder_InsertData -> ' +
    'Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

initialization

  RegisterTest(TSQLite3BuilderTestCase);
end.

