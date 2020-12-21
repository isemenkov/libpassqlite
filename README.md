libPasSQLite
============
It is delphi and object pascal bindings and wrapper around [SQLite library](https://www.sqlite.org). SQLite is library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.



### Table of contents

* [Requierements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Testing](#testing)
* [Raw bindings](#raw-bindings)
  * [Usage example](#usage-example)
    * [Create new table](#create-new-table)
    * [Insert data](#insert-data)
    * [Select data](#select-data)
* [Object wrapper](#object-wrapper)



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

Clone the repository `git clone https://github.com/isemenkov/libpascurl`.

Add the unit you want to use to the `uses` clause.



### Testing

A testing framework consists of the following ingredients:
1. Test runner project located in `unit-tests` directory.
2. Test cases (DUnit for Delphi and FPCUnit for FPC based) for all containers classes. 



### Raw bindings

[libpassqlite.pas](https://github.com/isemenkov/libpassqlite/blob/master/source/libpassqlite.pas) file contains the SQLite translated headers to use this library in pascal programs. You can find C API documentation at [SQLite website](https://www.sqlite.org/docs.html).

#### Usage example


##### Create new table

```pascal
uses
  libpassqlite;

var
  Handle : psqlite3;
  StatementHandle : psqlite3_stmt;
  Query : String;

begin
  { Create new database file or open exists. }
  sqlite3_open_v2(PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}('database.db')), 
    @Handle, SQLITE_OPEN_CREATE or SQLITE_OPEN_READWRITE, nil);
  
  Query := 'CREATE TABLE test_table (id INTEGER PRIMARY KEY, txt TEXT NOT NULL);';

  { Prepare SQL query. }
  sqlite3_prepare_v3(Handle, PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}(Query)), 
    Length(Query), SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil);

  { Run SQL query. }
  sqlite3_step(StatementHandle); { Function return SQLITE_DONE }

  { Free SQL query inner database resources. }
  sqlite3_finalize(StatementHandle);

  { Close database. }
  sqlite3_close_v2(Handle);
end.
```

##### Insert data

```pascal
uses
  libpassqlite {$IFNDEF FPC}, System.AnsiStrings{$ENDIF};

var
  Handle : psqlite3;
  StatementHandle : psqlite3_stmt;
  Query, StrData : String;

begin
  { Create new database file or open exists. }
  sqlite3_open_v2(PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}('database.db')), 
    @Handle, SQLITE_OPEN_CREATE or SQLITE_OPEN_READWRITE, nil);
  
  Query := 'CREATE TABLE test_table (id INTEGER PRIMARY KEY, txt TEXT NOT NULL);';

  { Prepare SQL query. }
  sqlite3_prepare_v3(Handle, PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}(Query)), 
    Length(Query), SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil);
  
  { Run SQL query. }
  sqlite3_step(StatementHandle); { Function return SQLITE_DONE }

  Query := 'INSERT INTO test_table (txt) VALUES (?);';

  { Prepare SQL query. }
  sqlite3_prepare_v3(Handle, PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}(Query)), 
    Length(Query), SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil);

  StrData := 'Test string';

  { Bind SQL query data. }
  sqlite3_bind_text(StatementHandle, 1, 
    {$IFNDEF FPC}System.AnsiStrings.StrNew(PAnsiChar(PAnsiString(Utf8Encode(
    {$ENDIF}{$IFDEF FPC}PChar({$ENDIF}StrData{$IFDEF FPC}){$ELSE})))){$ENDIF},
    Length(StrData), nil);

  { Run SQL query. }
  sqlite3_step(StatementHandle); { Function return SQLITE_DONE }

  { Free SQL query inner database resources. }
  sqlite3_finalize(StatementHandle);

  { Close database. }
  sqlite3_close_v2(Handle);
end.
```

##### Select data

```pascal
uses
  libpassqlite {$IFNDEF FPC}, System.AnsiStrings{$ENDIF};

var
  Handle : psqlite3;
  StatementHandle : psqlite3_stmt;
  Query, StrData : String;
  IntData : Integer;

begin
  { Create new database file or open exists. }
  sqlite3_open_v2(PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}('database.db')), 
    @Handle, SQLITE_OPEN_CREATE or SQLITE_OPEN_READWRITE, nil);
  
  Query := 'CREATE TABLE test_table (id INTEGER PRIMARY KEY, int INTEGER, ' +
    'txt TEXT NOT NULL);';

  { Prepare SQL query. }
  sqlite3_prepare_v3(Handle, PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}(Query)), 
    Length(Query), SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil);
  
  { Run SQL query. }
  sqlite3_step(StatementHandle); { Function return SQLITE_DONE }

  Query := 'INSERT INTO test_table (int, txt) VALUES (?, ?), (?, ?);';

  { Prepare SQL query. }
  sqlite3_prepare_v3(Handle, PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}(Query)), 
    Length(Query), SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil);

  { Bind SQL query data. }
  IntData := 123456;
  sqlite3_bind_int(StatementHandle, 1, IntData);

  StrData := 'Test string';
  sqlite3_bind_text(StatementHandle, 2, 
    {$IFNDEF FPC}System.AnsiStrings.StrNew(PAnsiChar(PAnsiString(Utf8Encode(
    {$ENDIF}{$IFDEF FPC}PChar({$ENDIF}StrData{$IFDEF FPC}){$ELSE})))){$ENDIF},
    Length(StrData), nil);

  IntData := 654321;
  sqlite3_bind_int(StatementHandle, 3, IntData);

  StrData := 'Some string value';
  sqlite3_bind_text(StatementHandle, 4, 
    {$IFNDEF FPC}System.AnsiStrings.StrNew(PAnsiChar(PAnsiString(Utf8Encode(
    {$ENDIF}{$IFDEF FPC}PChar({$ENDIF}StrData{$IFDEF FPC}){$ELSE})))){$ENDIF},
    Length(StrData), nil);

  { Run SQL query. }
  sqlite3_step(StatementHandle); { Function return SQLITE_DONE }

  Query := 'SELECT * FROM test_table;';

  { Prepare SQL query. }
  sqlite3_prepare_v3(Handle, PAnsiChar({$IFNDEF FPC}Utf8Encode{$ENDIF}(Query)), 
    Length(Query), SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil)

  { Run SQL query. }
  sqlite3_step(StatementHandle); { Function return SQLITE_ROW }

  { Get values from first row. }
  sqlite3_column_int(StatementHandle, 0); { Function return 1. }
  sqlite3_column_int(StatementHandle, 1); { Function return 123456. }
  String(PAnsiChar(sqlite3_column_text(StatementHandle, 2))); { Function return 'Test string'. }

  { Get next result row. }
  sqlite3_step(StatementHandle); { Function return SQLITE_ROW }

  { Get values from second row. }
  sqlite3_column_int(StatementHandle, 0); { Function return 2. }
  sqlite3_column_int(StatementHandle, 1); { Function return 654321. }
  String(PAnsiChar(sqlite3_column_text(StatementHandle, 2))); { Function return 'Some string value'. }

  { Get next result row. }
  sqlite3_step(StatementHandle); { Function return SQLITE_DONE }

  { Free SQL query inner database resources. }
  sqlite3_finalize(StatementHandle);

  { Close database. }
  sqlite3_close_v2(Handle);
end.
```