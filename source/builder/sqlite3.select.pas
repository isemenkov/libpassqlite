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
unit sqlite3.select;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  libpassqlite, sqlite3.errors_stack, sqlite3.query, sqlite3.result,
  sqlite3.structures;

type
  TSQLite3Select = class
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle :
      ppsqlite3; ATableName : String);
    destructor Destroy; override;

    { Add select field to list. }
    function All : TSQLite3Select;
    function Field (AColumnName : String) : TSQLite3Select; overload;
    function Field (AColumnName, AColumnAlias : String) : TSQLite3Select;
      overload;

    { Add where clause. }

  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FQuery : TSQLite3Query;
    FSelectFieldsList : TSQLite3Structures.TSelectFieldsList;
    FWhereFieldsList : TSQLite3Structures.TWhereFieldsList;
  end;

implementation

{ TSQLite3Select }

constructor TSQLite3Select.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FSelectFieldsList := TSQLite3Structures.TSelectFieldsList.Create;
  FWhereFieldsList := TSQLite3Structures.TWhereFieldsList.Create;
end;

destructor TSQLite3Select.Destroy;
begin
  FreeAndNil(FSelectFieldsList);
  FreeAndNil(FWhereFieldsList);
  inherited Destroy;
end;

function TSQLite3Select.All : TSQLite3Select;
var
  field : TSelectFieldItem;
begin
  field.Column_Name := '*';
  field.Column_AliasName := '';
  FSelectFieldsList.Append(field);
  Result := Self;
end;

function TSQLite3Select.Field (AColumnName : String) : TSQLite3Select;
var
  field : TSelectFieldItem;
begin
  field.Column_Name := AColumnName;
  field.Column_AliasName := '';
  FSelectFieldsList.Append(field);
  Result := Self;
end;

function TSQLite3Select.Field (AColumnName, AColumnAlias : String) : 
  TSQLite3Select;
var
  field : TSelectFieldItem;
begin
  field.Column_Name := AColumnName;
  field.Column_AliasName := AColumnAlias;
  FSelectFieldsList.Append(field);
  Result := Self;
end;



end.
