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
unit sqlite3.insert;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.query,
  sqlite3.structures, sqlite3.result_row;

type
  TSQLite3Insert = class
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle :
      ppsqlite3; ATableName : String);
    destructor Destroy; override;

    { Add value to insert list. }
    function Value (AColumnName : String) : TSQLite3Insert; overload;
    function Value (AColumnName : String; AValue : Integer) : TSQLite3Insert; 
      overload;
    function Value (AColumnName : String; AValue : Double) : TSQLite3Insert;
      overload;
    function Value (AColumnName : String; AValue : String) : TSQLite3Insert;
      overload;

    { Get result. }
    function Get : Integer;  
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FValuesList : TSQLite3Structures.TValuesList;
    FQuery : TSQLite3Query;
  end;

implementation

{ TSQLite3Insert }

constructor TSQLite3Insert.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FValuesList := TSQLite3Structures.TValuesList.Create;
end;

destructor TSQLite3Insert.Destroy;
begin
  FreeAndNil(FValuesList);
  inherited Destroy;
end;

function TSQLite3Insert.Value (AColumnName : String) : TSQLite3Insert;
var
  val : TSQLite3Structures.TValueItem;
begin
  val.Column_Name := AColumnName;

  val.Value_Type := SQLITE_NULL;
  val.Value_Integer := 0;
  val.Value_Float := 0;
  val.Value_Text := '';
  val.Value_Blob := nil;

  FValuesList.Append(val);
  Result := Self;
end;

function TSQLite3Insert.Value (AColumnName : String; AValue : Integer) : 
  TSQLite3Insert;
var
  val : TSQLite3Structures.TValueItem;
begin
  val.Column_Name := AColumnName;

  val.Value_Type := SQLITE_INTEGER;
  val.Value_Integer := AValue;
  val.Value_Float := 0;
  val.Value_Text := '';
  val.Value_Blob := nil;

  FValuesList.Append(val);
  Result := Self;
end;

function TSQLite3Insert.Value (AColumnName : String; AValue : Double) : 
  TSQLite3Insert;
var
  val : TSQLite3Structures.TValueItem;
begin
  val.Column_Name := AColumnName;

  val.Value_Type := SQLITE_FLOAT;
  val.Value_Integer := 0;
  val.Value_Float := AValue;
  val.Value_Text := '';
  val.Value_Blob := nil;

  FValuesList.Append(val);
  Result := Self;
end;

function TSQLite3Insert.Value (AColumnName : String; AValue : String) : 
  TSQLite3Insert;
var
  val : TSQLite3Structures.TValueItem;
begin
  val.Column_Name := AColumnName;

  val.Value_Type := SQLITE_TEXT;
  val.Value_Integer := 0;
  val.Value_Float := 0;
  val.Value_Text := AValue;
  val.Value_Blob := nil;

  FValuesList.Append(val);
  Result := Self;
end;

function TSQLite3Insert.Get : Integer;
var
  val : TSQLite3Structures.TValueItem;
  SQL : String;
  i : Integer;
begin
  if not FValuesList.FirstEntry.HasValue then
    Exit;

  i := 0;
  SQL := 'INSERT INTO ' + FTableName + ' (';
  for val in FValuesList do
  begin
    { For every column. }
    if i > 0 then
      SQL := SQL + ', ';

    SQL := SQL + val.Column_Name;
    Inc(i);
  end;
  
  i := 0;
  SQL := SQL + ') VALUES (';
  for val in FValuesList do
  begin
    { For every value. }
    if i > 0 then
      SQL := SQL + ', ';

    SQL := SQL + '?';
    Inc(i);
  end;
  
  i := 1;
  SQL := SQL + ');';
  
  FQuery := TSQLite3Query.Create (FErrorsStack, FDBHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);

  for val in FValuesList do
  begin
    case val.Value_Type of
      SQLITE_INTEGER : FQuery.Bind(i, val.Value_Integer);
      SQLITE_FLOAT :   FQuery.Bind(i, val.Value_Float);
      SQLITE_TEXT :    FQuery.Bind(i, val.Value_Text);
      SQLITE_NULL :    FQuery.Bind(i);
    end;
    Inc(i);
  end;
  FQuery.Run;
  Result := 0; // TODO
  FreeAndNil(FQuery);
end;

end.
