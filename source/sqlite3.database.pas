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
unit sqlite3.database;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.connection,
  sqlite3.query;

type
  { SQLite3 database }
  TSQLite3Database = class
  public 
    type
      TConnectFlag = sqlite3.connection.TSQLite3DatabaseConnection.TConnectFlag;
      TConnectFlags =
        sqlite3.connection.TSQLite3DatabaseConnection.TConnectFlags;
      TPrepareFlag = sqlite3.query.TSQLite3Query.TPrepareFlag;
      TPrepareFlags = sqlite3.query.TSQLite3Query.TPrepareFlags;
  public
    constructor Create (AFilename : String; AFlags : TConnectFlags = 
      [SQLITE_OPEN_CREATE, SQLITE_OPEN_READWRITE]);
    destructor Destroy; override;

    { Create new SQL query. }
    function Query (AQuery : String; AFlags : TPrepareFlags = 
      [SQLITE_PREPARE_NORMALIZE]) : TSQLite3Query;

    { Get last insert row id. }
    function LastInsertID : int64;
  private
    FErrorsStack : TSQL3LiteErrorsStack;
    FHandle : psqlite3;
    FConnection : TSQLite3DatabaseConnection;
  public
    { Get errors list. }
    property Errors : TSQL3LiteErrorsStack read FErrorsStack;

    { Get database handle. }
    property Handle : psqlite3 read FHandle;
  end;

implementation

{ TSQLite3Database }

constructor TSQLite3Database.Create (AFilename : String; AFlags : 
  TConnectFlags);
begin
  FErrorsStack := TSQL3LiteErrorsStack.Create;
  FConnection := TSQLite3DatabaseConnection.Create(@FErrorsStack, @FHandle,
    AFilename, AFlags);
end;

destructor TSQLite3Database.Destroy;
begin
  FreeAndNil(FConnection);
  FreeAndNil(FErrorsStack);
  inherited Destroy;
end;

function TSQLite3Database.Query (AQuery : String; AFlags : TPrepareFlags) :
  TSQLite3Query;
begin
  Result := TSQLite3Query.Create(@FErrorsStack, @FHandle, AQuery, AFlags);
end;

function TSQLite3Database.LastInsertID : Int64;
begin
  Result := sqlite3_last_insert_rowid(FHandle);
end;

end.

