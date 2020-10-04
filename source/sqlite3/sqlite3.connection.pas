(******************************************************************************)
(*                                libPasSQLite                                *)
(*               object pascal wrapper around SQLite library                  *)
(*                                                                            *)
(* Copyright (c) 2020                                       Ivan Semenkov     *)
(* https://github.com/isemenkov/libpassqlite                ivan@semenkov.pro *)
(*                                                          Ukraine           *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the GNU General Public License as published by the Free *)
(* Software Foundation; either version 3 of the License.                      *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License for *)
(* more details.                                                              *)
(*                                                                            *)
(* A copy  of the  GNU General Public License is available  on the World Wide *)
(* Web at <http://www.gnu.org/copyleft/gpl.html>. You  can also obtain  it by *)
(* writing to the Free Software Foundation, Inc., 51  Franklin Street - Fifth *)
(* Floor, Boston, MA 02110-1335, USA.                                         *)
(*                                                                            *)
(******************************************************************************)
unit sqlite3.connection;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack;

type
  { SQLite3 database connection. }
  TSQLite3DatabaseConnection = class
  public
    type
      { Additional parameters for additional control over the new database 
        connection. }
      TConnectFlag = (
        { The database is opened in read-only mode. }
        SQLITE_OPEN_READONLY,

        { The database is created if it does not already exist. }
        SQLITE_OPEN_CREATE,
        
        { The database is opened for reading and writing if possible, or reading 
          only if the file is write protected by the operating system. }
        SQLITE_OPEN_READWRITE,

        { The filename can be interpreted as a URI if this flag is set. }
        SQLITE_OPEN_URI,

        { The database will be opened as an in-memory database. }
        SQLITE_OPEN_MEMORY,

        { The new database connection will use the "multi-thread" threading mode. 
          This means that separate threads are allowed to use SQLite at the same 
          time, as long as each thread is using a different database connection. }
        SQLITE_OPEN_NOMUTEX,

        { The new database connection will use the "serialized" threading mode. This 
          means the multiple threads can safely attempt to use the same database 
          connection at the same time. (Mutexes will block any actual concurrency, 
          but in this mode there is no harm in trying.) }
        SQLITE_OPEN_FULLMUTEX,

        { The database is opened shared cache enabled. }
        SQLITE_OPEN_SHAREDCACHE,

        { The database is opened shared cache disabled. }
        SQLITE_OPEN_PRIVATECACHE,

        { The database filename is not allowed to be a symbolic link. }
        SQLITE_OPEN_NOFOLLOW
      );

      TConnectFlags = set of TConnectFlag;
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; AHandle : 
      ppsqlite3; AFilename : String; AFlags : TConnectFlags);
    destructor Destroy; override;
  private
    FErrorStack : PSQL3LiteErrorsStack;
    FHandle : ppsqlite3;

    function PrepareFlags (AFlags : TConnectFlags) : Integer;
  end;

implementation

{ TSQLite3DatabaseConnection }

constructor TSQLite3DatabaseConnection.Create (AErrorsStack : 
  PSQL3LiteErrorsStack; AHandle : ppsqlite3; AFilename : String; AFlags :
  TConnectFlags);
begin
  FHandle := AHandle;
  FErrorStack := AErrorsStack;
  FErrorStack^.Push(sqlite3_open_v2(PChar(AFilename), FHandle,
    PrepareFlags(AFlags), nil));
end;

destructor TSQLite3DatabaseConnection.Destroy;
begin
  FErrorStack^.Push(sqlite3_close_v2(FHandle^));
  inherited Destroy;
end;

function TSQLite3DatabaseConnection.PrepareFlags (AFlags : TConnectFlags) :
  Integer;
begin
  Result := 0;
  
  if SQLITE_OPEN_READONLY in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_READONLY;
  if SQLITE_OPEN_CREATE in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_READWRITE or 
      libpassqlite.SQLITE_OPEN_CREATE;
  if SQLITE_OPEN_READWRITE in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_READWRITE;
  if SQLITE_OPEN_URI in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_URI;
  if SQLITE_OPEN_MEMORY in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_MEMORY;
  if SQLITE_OPEN_NOMUTEX in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_NOMUTEX;
  if SQLITE_OPEN_FULLMUTEX in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_FULLMUTEX;
  if SQLITE_OPEN_SHAREDCACHE in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_SHAREDCACHE;
  if SQLITE_OPEN_PRIVATECACHE in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_PRIVATECACHE;
  if SQLITE_OPEN_NOFOLLOW in AFlags then
    Result := Result or libpassqlite.SQLITE_OPEN_NOFOLLOW;
end;

end.
