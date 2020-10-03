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
unit sqlite3.result_row; 

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack;

type
  { SQLite3 database query result collection row. }
  TSQLite3ResultRow = class
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; AStatementHandle :
      psqlite3_stmt);
    destructor Destroy; override;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FStatementHandle : psqlite3_stmt;
  end;

implementation

{ TSQLite3ResultRow }

constructor TSQLite3ResultRow.Create(AErrorsStack : PSQL3LiteErrorsStack;
  AStatementHandle : sqlite3_stmt);
begin
  FErrorsStack := AErrorsStack;
  FStatementHandle := AStatementHandle;
end; 

destructor TSQLite3ResultRow.Destroy;
begin
  inherited Destroy;
end;

end.