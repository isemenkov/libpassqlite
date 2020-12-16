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
unit sqlite3.builder;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.connection, 
  sqlite3.table, sqlite3.query;

type
  TSQLite3Builder = class
  public 
    type
      TConnectFlag = sqlite3.connection.TSQLite3DatabaseConnection.TConnectFlag;
      TConnectFlags =
        sqlite3.connection.TSQLite3DatabaseConnection.TConnectFlags;
      TPrepareFlag = sqlite3.query.TSQLite3Query.TPrepareFlag;
      TPrepareFlags = sqlite3.query.TSQLite3Query.TPrepareFlags;

      { Database transactions type. }
      TTransactionType = (
        { Means that the transaction does not actually start until the database 
          is first accessed. }
        DEFERRED, 

        { Cause the database connection to start a new write immediately,
          without waiting for a write statement. }
        IMMEDIATE,

        { Prevents other database connections from reading the database while 
          the transaction is underway. }
        EXCLUSIVE 
      );
  public
    constructor Create (AFilename : String; AFlags : TConnectFlags = 
      [SQLITE_OPEN_CREATE, SQLITE_OPEN_READWRITE]);
    destructor Destroy; override;

    { Raw query. }
    function RawQuery (ASQL : String; AFlags : TPrepareFlags =
      [SQLITE_PREPARE_NORMALIZE]) : TSQLite3Query;

    { Get table interface. }
    function Table (ATableName : String) : TSQLite3Table;

    { Start new database transaction. }
    procedure BeginTransaction (AType : TTransactionType = DEFERRED; 
      ATransactionName : String = '');

    { End database transaction. }
    procedure EndTransaction (ATransactionName : String = '');

    { Rollback database transaction. }
    procedure RollbackTransaction (ATransactionName : String = '');

    { Get last insert row id. }
    function LastInsertID : int64;
  private
    FErrorsStack : TSQL3LiteErrorsStack;
    FHandle : psqlite3;
    FConnection : TSQLite3DatabaseConnection;
  public
    { Get errors list. }
    property Errors : TSQL3LiteErrorsStack read FErrorsStack;
  end;

implementation

{ TSQLite3Builder }

constructor TSQLite3Builder.Create (AFilename : String; AFlags : TConnectFlags);
begin
  FErrorsStack := TSQL3LiteErrorsStack.Create;
  FConnection := TSQLite3DatabaseConnection.Create(@FErrorsStack, @FHandle,
    AFilename, AFlags);
end;

destructor TSQLite3Builder.Destroy;
begin
  FreeAndNil(FConnection);
  FreeAndNil(FErrorsStack);
  inherited Destroy;
end;

function TSQLite3Builder.RawQuery (ASQL : String; AFlags : TPrepareFlags) : 
  TSQLite3Query;
begin
  Result := TSQLite3Query.Create(@FErrorsStack, @FHandle, ASQL, AFlags);
end;

function TSQLite3Builder.Table (ATableName : String) : TSQLite3Table;
begin
  Result := TSQLite3Table.Create(@FErrorsStack, @FHandle, ATableName);
end;

procedure TSQLite3Builder.BeginTransaction (AType : TTransactionType;
  ATransactionName : String);
var
  SQL : String;
  Query : TSQLite3Query;
begin
  SQL := 'BEGIN ';

  case AType of
    DEFERRED :  SQL := SQL + 'DEFERRED ';
    IMMEDIATE : SQL := SQL + 'IMMEDIATE ';
    EXCLUSIVE : SQL := SQL + 'EXCLUSIVE ';
  end;

  SQL := SQL + 'TRANSACTION;';
  Query := TSQLite3Query.Create(@FErrorsStack, @FHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);
  Query.Run;
  FreeAndNil(Query);

  { Start new savepoint. }
  if ATransactionName <> '' then
  begin
    Query := TSQLite3Query.Create(@FErrorsStack, @FHandle, 'SAVEPOINT ' +
    ATransactionName + ';', [SQLITE_PREPARE_NORMALIZE]);
    FreeAndNil(Query);
  end;
end;

procedure TSQLite3Builder.EndTransaction (ATransactionName : String = '');
var
  SQL : String;
  Query : TSQLite3Query;
begin
  if ATransactionName <> '' then
  begin
    SQL := 'RELEASE SAVEPOINT ' + ATransactionName + ';';
  end else
  begin
    SQL := 'COMMIT TRANSACTION;';
  end;

  Query := TSQLite3Query.Create(@FErrorsStack, @FHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);
  Query.Run;
  FreeAndNil(Query);
end;

procedure TSQLite3Builder.RollbackTransaction (ATransactionName : String = '');
var
  SQL : String;
  Query : TSQLite3Query;
begin
  SQL := 'ROLLBACK TRANSACTION ';

  if ATransactionName <> '' then
  begin
    SQL := SQL + 'TO  SAVEPOINT ' + ATransactionName;
  end;
  SQL := SQL + ';';

  Query := TSQLite3Query.Create(@FErrorsStack, @FHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);
  Query.Run;
  FreeAndNil(Query);
end;

function TSQLite3Builder.LastInsertID : Int64;
begin
  Result := sqlite3_last_insert_rowid(FHandle);
end;

end.
