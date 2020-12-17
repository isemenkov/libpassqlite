libPasSQLite
============
It is object pascal bindings and wrapper around [SQLite library](https://www.sqlite.org). SQLite is library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.



### Table of contents

* [Requierements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Testing](#testing)
* [Bindings](#bindings)
  * [Usage example](#usage-example)
* [Object wrapper](#object-wrapper)



### Requirements

* [SQLite](https://www.sqlite.org)
* [Free Pascal Compiler](http://freepascal.org)
* [Lazarus IDE](http://www.lazarus.freepascal.org/) (optional)

Library is tested with latest stable FreePascal Compiler (currently 3.2.0) and Lazarus IDE (currently 2.0.10) on Ubuntu Linux 5.8.0-33-generic x86_64 and Embarcadero (R) Delphi 10.3 on Windows 7 Service Pack 1 (Version 6.1, Build 7601, 64-bit Edition).



### Installation

Get the sources and add the *source* directory to the *fpc.cfg* file.



### Usage

Clone the repository `git clone https://github.com/isemenkov/libpascurl`.

Add the unit you want to use to the `uses` clause.



### Testing

A testing framework consists of the following ingredients:
1. Test runner project located in `unit-tests` directory.
2. Test cases (FPCUnit based) for additional helpers classes.



### Bindings

[libpassqlite.pas](https://github.com/isemenkov/libpassqlite/blob/master/source/libpassqlite.pas) file contains the SQLite translated headers to use this library in pascal programs. You can find C API documentation at [SQLite website](https://www.sqlite.org/docs.html).

#### Usage example

```pascal
uses
  libpassqlite;

var
  Handle : ppsqlite3;
  StatementHandle : psqlite3_stmt;
  Query : String;

begin
  sqlite3_open_v2(PChar('database.db'), Handle, SQLITE_OPEN_READWRITE);
  
  Query := 'CREATE TABLE test_table (id INTEGER PRIMARY KEY, txt TEXT NOT NULL);';
  sqlite3_prepare_v3(Handle^, PChar(Query), Length(PChar(Query)), SQLITE_PREPARE_NORMALIZE, @StatementHandle, nil);

  sqlite3_step(StatementHandle);

  sqlite3_finalize(StatementHandle);
  sqlite3_close_v2(Handle^);
end.
```


