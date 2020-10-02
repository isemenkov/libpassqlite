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
unit sqlite3.statement;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite;

type
  { Option that is used for special purposes. }
  TPrepareFlag = (
    { The SQLITE_PREPARE_PERSISTENT flag is a hint to the query planner that the 
      prepared statement will be retained for a long time and probably reused 
      many times. }
    SQLITE_PREPARE_PERSISTENT,

    { The SQLITE_PREPARE_NORMALIZE flag is a no-op. This flag used to be 
      required for any prepared statement that wanted to use the 
      sqlite3_normalized_sql() interface. However, the sqlite3_normalized_sql() 
      interface is now available to all prepared statements, regardless of 
      whether or not they use this flag. }
    SQLITE_PREPARE_NORMALIZE,

    { The SQLITE_PREPARE_NO_VTAB flag causes the SQL compiler to return an error 
      (error code SQLITE_ERROR) if the statement uses any virtual tables. }
    SQLITE_PREPARE_NO_VTAB
  );
  TPrepareFlags = set of TPrepareFlag;

  { Single SQL statement. }
  TSQLite3Statement = class
  private
    FDBHandle : psqlite3;
    FStatementHandle : psqlite3_stmt;

    function PrepareFlags (AFlags : TPrepareFlags) : Integer;
  public
    constructor Create (ADBHandle : psqlite3; AQuery : String; AFlags : 
      TPrepareFlags);
    destructor Destroy; override;
  end;

implementation

{ TSQLite3Statement }

constructor TSQLite3Statement.Create (ADBHandle : psqlite3; AQuery : String;
  AFlags : TPrepareFlags);
begin
  sqlite3_prepare_v3(FDBHandle, PChar(AQuery), Length(PChar(AQuery)), 
    PrepareFlags(AFlags), @FStatementHandle, nil);
end;

destructor TSQLite3Statement.Destroy;
begin
  sqlite3_finalize(FStatementHandle);

  inherited Destroy;
end;

function TSQLite3Statement.PrepareFlags (AFlags : TPrepareFlags) : Integer;
begin
  Result := 0;

  if SQLITE_PREPARE_PERSISTENT in AFlags then
    Result := Result or libpassqlite.SQLITE_PREPARE_PERSISTENT;
  if SQLITE_PREPARE_NORMALIZE in AFlags then
    Result := Result or libpassqlite.SQLITE_PREPARE_NORMALIZE;
  if SQLITE_PREPARE_NO_VTAB in AFlags then
    Result := Result or libpassqlite.SQLITE_PREPARE_NO_VTAB;
end;

end.
