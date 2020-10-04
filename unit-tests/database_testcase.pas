unit database_testcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, sqlite3.database, sqlite3.query,
  sqlite3.result, sqlite3.result_row;

type
  { TSQLite3DatabaseTestCase }
  TSQLite3DatabaseTestCase = class(TTestCase)
  published
    procedure Test_SQLite3Database_CreateNewEmpty;
    procedure Test_SQLite3Database_Query;
  end;

implementation

{ TSQLite3DatabaseTestCase }

procedure TSQLite3DatabaseTestCase.Test_SQLite3Database_CreateNewEmpty;
var
  database : TSQLite3Database;
begin
  AssertTrue('#Test_SQLite3Database_CreateNewEmpty -> ' +
    'Database file already exists', not FileExists('test.db'));

  database := TSQLite3Database.Create('test.db',
    [TSQLite3Database.TConnectFlag.SQLITE_OPEN_CREATE]);

  AssertTrue('#Test_SQLite3Database_CreateNewEmpty -> ' +
    'Database connection has errors', database.Errors.Count = 0);

  FreeAndNil(database);

  AssertTrue('#Test_SQLite3Database_CreateNewEmpty -> ' +
    'Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3DatabaseTestCase.Test_SQLite3Database_Query;
var
  database : TSQLite3Database;
  SQL : String;
  Query : TSQLite3Query;
  Res : TSQLite3Result;
  Row : TSQLite3ResultRow;
  i : Integer;
begin
  AssertTrue('#Test_SQLite3Database_Query -> ' +
    'Database file already exists', not FileExists('test.db'));

  database := TSQLite3Database.Create('test.db',
    [TSQLite3Database.TConnectFlag.SQLITE_OPEN_CREATE]);
  
  SQL := 'CREATE TABLE test_table (id INTEGER PRIMARY KEY, txt TEXT NOT NULL);';
  database.Query(SQL, [TSQLite3Query.TPrepareFlag.SQLITE_PREPARE_NORMALIZE])
    .Run;
  
  SQL := 'INSERT INTO test_table (txt) VALUES (?);';
  Query := database.Query(SQL, 
    [TSQLite3Query.TPrepareFlag.SQLITE_PREPARE_NORMALIZE])
    .Bind(1, 'text value');
  Query.Run;
   
  SQL := 'SELECT * FROM test_table WHERE id = ?';
  Query := database.Query(SQL, 
    [TSQLite3Query.TPrepareFlag.SQLITE_PREPARE_NORMALIZE])
    .Bind(1, 1);
  Res := Query.Run;
  
  i := 0;
  for Row in Res do
  begin
    AssertTrue('#Test_SQLite3Database_Query -> ' +
      'Selected result columns count is incorrect.', Row.ColumnCount = 2);
    AssertTrue('#Test_SQLite3Database_Query -> ' +
      'Selected result column 0 name is incorrect.', Row.ColumnName(0) = 'id');
    AssertTrue('#Test_SQLite3Database_Query -> ' +
      'Selected result column 1 name is incorrect.', Row.ColumnName(1) = 'txt');

    AssertTrue('#Test_SQLite3Database_Query -> ' +
      'Selected result column ''id'' value is incorrect.', 
      Row.GetIntegerValue('id') = 1);
    AssertTrue('#Test_SQLite3Database_Query -> ' +
      'Selected result column ''txt'' value is incorrect.', 
      Row.GetStringValue('txt') = 'text value');

    Inc(i);    
  end;
  
  AssertTrue('#Test_SQLite3Database_Query -> ' +
    'Table ''test_table'' has more than one rows', i = 1);
  AssertTrue('#Test_SQLite3Database_Query -> ' +
    'Database connection has errors', database.Errors.Count = 0);

  FreeAndNil(database);

  AssertTrue('#Test_SQLite3Database_Query -> ' +
    'Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

initialization
  RegisterTest(TSQLite3DatabaseTestCase);
end.

