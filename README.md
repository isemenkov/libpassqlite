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



### Requirements

* [SQLite](https://www.sqlite.org)
* [Embarcadero (R) Rad Studio](https://www.embarcadero.com)
* [Free Pascal Compiler](http://freepascal.org)
* [Lazarus IDE](http://www.lazarus.freepascal.org/) (optional)



Library is tested for 

- Embarcadero (R) Delphi 10.3 on Windows 7 Service Pack 1 (Version 6.1, Build 7601, 64-bit Edition)
- Embarcadero (R) Delphi 11.0 Version 28.0.42600.6491 on Windows 10 (Version 10.0, Build 19042, 64-bit Edition)
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

* [Create database](https://github.com/isemenkov/libpassqlite/wiki/Raw-bindings#create-database)
* [Run query](https://github.com/isemenkov/libpassqlite/wiki/Raw-bindings#run-query)

*More details read on* [wiki page](https://github.com/isemenkov/libpassqlite/wiki/Raw-bindings).



### Object wrapper

[sqlite3.database.pas](https://github.com/isemenkov/libpassqlite/blob/master/source/sqlite3.database.pas) file contains the SQLite object wrapper.

* [Create database](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Database#create-database)
* [Run query](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Database#run-query)

*More details read on* [wiki page](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Database).



### Query builder

[sqlite3.builder.pas](https://github.com/isemenkov/libpassqlite/blob/master/source/sqlite3.builder.pas) file contains the SQLite query builder.

* [Create database](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Builder#create-database)
* [Raw query](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Builder#raw-query)
* [Table](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Builder#table)
  * [Schema](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Schema)
  * [Select](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Select)
  * [Insert](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Insert)
  * [Update](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Update)
  * [Delete](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Delete)
* [Transaction](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Builder#transaction)

*More details read on* [wiki page](https://github.com/isemenkov/libpassqlite/wiki/TSQLite3Builder).