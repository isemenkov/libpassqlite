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

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.connection, 
  sqlite3.table;

type
  TSQLite3Builder = class
  public
    constructor Create (AFilename : String; AFlags : TConnectFlags = 
      [SQLITE_OPEN_CREATE, SQLITE_OPEN_READWRITE]);
    destructor Destroy; override;

    { Get table interface. }
    function Table (ATableName : String) : TSQLite3Table;

  private
    FErrorsStack : TSQL3LiteErrorsStack;
    FHandle : psqlite3;
    FConnection : TSQLite3DatabaseConnection;
  public
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

function TSQLite3Builder.Table (ATableName : String) : TSQLite3Table;
begin
  Result := TSQLite3Table.Create(@FErrorsStack, @FHandle, ATableName);
end;

end.
