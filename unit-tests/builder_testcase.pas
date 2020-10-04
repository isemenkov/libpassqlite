unit builder_testcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, sqlite3.builder, sqlite3.schema;

type
  { TSQLite3BuilderTestCase }
  TSQLite3BuilderTestCase = class(TTestCase)
  published
    procedure Test_SQLite3Builder_CreateNewEmpty;
    procedure Test_SQLite3Builder_CreateNewSchema;
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

  FreeAndNil(builder);

  AssertTrue('#Test_SQLite3Builder_CreateNewEmpty -> ' +
    'Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

initialization

  RegisterTest(TSQLite3BuilderTestCase);
end.

