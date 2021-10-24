unit rawbindings_testcase;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, libpassqlite {$IFDEF FPC}, fpcunit, testregistry{$ELSE},
  TestFramework{$ENDIF}, utils.api.cstring;

type
  { TSQLite3RawBindingsTestCase }

  TSQLite3RawBindingsTestCase = class(TTestCase)
  public
    {$IFNDEF FPC}
    procedure AssertTrue (AMessage : String; ACondition : Boolean);
    {$ENDIF}
  published
    procedure Test_TSQLite3RawBindings_CreateNewEmpty;
    procedure Test_TSQLite3RawBindings_CreateTableQuery;
    procedure Test_TSQLite3RawBindings_InsertDataQuery;
    procedure Test_TSQLite3RawBindings_SelectDataQuery;
  end;

implementation
 
{ TSQLite3RawBindingsTestCase }

{$IFNDEF FPC}
procedure TSQLite3RawBindingsTestCase.AssertTrue(AMessage : String; ACondition :
  Boolean);
begin
  CheckTrue(ACondition, AMessage);
end;
{$ENDIF}

procedure TSQLite3RawBindingsTestCase.Test_TSQLite3RawBindings_CreateNewEmpty;
var
  Handle : psqlite3;
begin
  AssertTrue('#TSQLite3RawBindingsTestCase -> ' +
    'Database file already exists', not FileExists('database1.db'));

  AssertTrue('#TSQLite3RawBindingsTestCase -> ' +
    'Create database error', sqlite3_open_v2(API.CString.Create('database1.db')
    .ToPAnsiChar, @Handle, SQLITE_OPEN_CREATE or
    SQLITE_OPEN_READWRITE, nil) = SQLITE_OK);
  
  AssertTrue('#TSQLite3RawBindingsTestCase -> ' +
    'Close database error', sqlite3_close_v2(Handle) = SQLITE_OK);

  AssertTrue('#TSQLite3RawBindingsTestCase -> ' +
    'Database file not exists', FileExists('database1.db'));

  DeleteFile('database1.db');
end;

procedure TSQLite3RawBindingsTestCase.Test_TSQLite3RawBindings_CreateTableQuery;
var
  Handle : psqlite3;
  StatementHandle : psqlite3_stmt;
  Query : String; 
begin
  AssertTrue('#Test_TSQLite3RawBindings_Query -> ' +
    'Database file already exists', not FileExists('database2.db'));

  AssertTrue('#Test_TSQLite3RawBindings_Query -> ' +
    'Create database error', sqlite3_open_v2(PAnsiChar({$IFNDEF FPC}Utf8Encode
    {$ENDIF}('database2.db')), @Handle, SQLITE_OPEN_CREATE or
    SQLITE_OPEN_READWRITE, nil) = SQLITE_OK);
  
  Query := 'CREATE TABLE test_table (id INTEGER PRIMARY KEY, txt TEXT NOT NULL);';

  AssertTrue('#Test_TSQLite3RawBindings_Query -> ' +
    'Query prepare error', sqlite3_prepare_v3(Handle,
    API.CString.Create(Query).ToPAnsiChar, Length(Query), 
    SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil) = SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_Query -> ' +
    'Query run error', sqlite3_step(StatementHandle) = SQLITE_DONE);

  AssertTrue('#Test_TSQLite3RawBindings_Query -> ' +
    'Query statement clear error', sqlite3_finalize(StatementHandle) = 
    SQLITE_OK);

  AssertTrue('#TSQLite3RawBindingsTestCase -> ' +
    'Close database error', sqlite3_close_v2(Handle) = SQLITE_OK);

  AssertTrue('#Test_SQLite3Database_CreateNewEmpty -> ' +
    'Database file not exists', FileExists('database2.db'));

  DeleteFile('database2.db');
end;

procedure TSQLite3RawBindingsTestCase.Test_TSQLite3RawBindings_InsertDataQuery;
var
  Handle : psqlite3;
  StatementHandle : psqlite3_stmt;
  Query, StrData : String;
begin
  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Database file already exists', not FileExists('database3.db'));

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Create database error', sqlite3_open_v2(API.CString.Create('database3.db')
    .ToPAnsiChar, @Handle, SQLITE_OPEN_CREATE or
    SQLITE_OPEN_READWRITE, nil) = SQLITE_OK);
  
  Query := 'CREATE TABLE test_table (id INTEGER PRIMARY KEY, txt TEXT NOT NULL);';

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Query prepare error', sqlite3_prepare_v3(Handle,
    API.CString.Create(Query).ToPAnsiChar, Length(Query), 
    SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil) = SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Query run error', sqlite3_step(StatementHandle) = SQLITE_DONE);

  Query := 'INSERT INTO test_table (txt) VALUES (?);';

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Query prepare error', sqlite3_prepare_v3(Handle,
    API.CString.Create(Query).ToPAnsiChar, Length(Query), 
    SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil) = SQLITE_OK);

  StrData := 'Test string';
  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Query text binding error', sqlite3_bind_text(StatementHandle, 1, 
    API.CString.Create(StrData).ToUniquePAnsiChar.Value, Length(StrData),
    nil) = SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Query run error', sqlite3_step(StatementHandle) = SQLITE_DONE);

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Count of inserted rows is not correct', sqlite3_changes(Handle) = 1);

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Query statement clear error', sqlite3_finalize(StatementHandle) = 
    SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Close database error', sqlite3_close_v2(Handle) = SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_InsertDataQuery -> ' +
    'Database file not exists', FileExists('database3.db'));

  DeleteFile('database3.db');
end;

procedure TSQLite3RawBindingsTestCase.Test_TSQLite3RawBindings_SelectDataQuery;
var
  Handle : psqlite3;
  StatementHandle : psqlite3_stmt;
  Query, StrData : String; 
  IntData : Integer;
begin
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Database file already exists', not FileExists('database4.db'));

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Create database error', sqlite3_open_v2(API.CString.Create('database4.db')
    .ToPAnsiChar, @Handle, SQLITE_OPEN_CREATE or
    SQLITE_OPEN_READWRITE, nil) = SQLITE_OK);
  
  Query := 'CREATE TABLE test_table (id INTEGER PRIMARY KEY, int INTEGER, ' +
    'txt TEXT NOT NULL);';

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query prepare error', sqlite3_prepare_v3(Handle,
    API.CString.Create(Query).ToPAnsiChar, Length(Query), 
    SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil) = SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query run error', sqlite3_step(StatementHandle) = SQLITE_DONE);

  Query := 'INSERT INTO test_table (int, txt) VALUES (?, ?), (?, ?);';

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query prepare error', sqlite3_prepare_v3(Handle,
    API.CString.Create(Query).ToPAnsiChar, Length(Query), 
    SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil) = SQLITE_OK);

  IntData := 123456;
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query text binding error', sqlite3_bind_int(StatementHandle, 1, IntData) 
    = SQLITE_OK);
  
  StrData := 'Test string';
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query text binding error', sqlite3_bind_text(StatementHandle, 2, 
    API.CString.Create(StrData).ToUniquePAnsiChar.Value, Length(StrData),
    nil) = SQLITE_OK);

  IntData := 654321;
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query text binding error', sqlite3_bind_int(StatementHandle, 3, IntData) 
    = SQLITE_OK);

  StrData := 'Some string value';
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query text binding error', sqlite3_bind_text(StatementHandle, 4, 
    API.CString.Create(StrData).ToUniquePAnsiChar.Value, Length(StrData),
    nil) = SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query run error', sqlite3_step(StatementHandle) = SQLITE_DONE);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Count of inserted rows is not correct', sqlite3_changes(Handle) = 2);

  Query := 'SELECT * FROM test_table;';

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query prepare error', sqlite3_prepare_v3(Handle,
    API.CString.Create(Query).ToPAnsiChar, Length(Query), 
    SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil) = SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query run error', sqlite3_step(StatementHandle) = SQLITE_ROW);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'First row id value not correct', sqlite3_column_int(StatementHandle, 0)
    = 1);
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'First row id value not correct', sqlite3_column_int(StatementHandle, 1)
    = 123456);
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'First row id value not correct',
    API.CString.Create(PAnsiChar(sqlite3_column_text(StatementHandle, 2)))
    .ToString = 'Test string');

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query run error', sqlite3_step(StatementHandle) = SQLITE_ROW);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Second row id value not correct', sqlite3_column_int(StatementHandle, 0)
    = 2);
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Second row id value not correct', sqlite3_column_int(StatementHandle, 1)
    = 654321);
  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Second row id value not correct',
    API.CString.Create(PAnsiChar(sqlite3_column_text(StatementHandle, 2)))
    .ToString = 'Some string value');

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query run error', sqlite3_step(StatementHandle) = SQLITE_DONE);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Query statement clear error', sqlite3_finalize(StatementHandle) = 
    SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Close database error', sqlite3_close_v2(Handle) = SQLITE_OK);

  AssertTrue('#Test_TSQLite3RawBindings_SelectDataQuery -> ' +
    'Database file not exists', FileExists('database4.db'));

  DeleteFile('database4.db');
end;

initialization
  RegisterTest(TSQLite3RawBindingsTestCase{$IFNDEF FPC}.Suite{$ENDIF});
end.

