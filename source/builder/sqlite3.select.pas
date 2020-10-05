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
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.query, sqlite3.result,
  sqlite3.structures, sqlite3.where;

type
  TSQLite3Select = class
  public
    type
      TWhereComparisonOperator
        = sqlite3.structures.TSQLite3Structures.TWhereComparisonOperator;
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
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Select; overload;
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Select; overload;
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Select; overload;
    function Where (AColumnName : String; AValue : String) : TSQLite3Select; 
      overload;
    function Where (AColumnName : String; AValue : Integer) : TSQLite3Select; 
      overload;
    function Where (AColumnName : String; AValue : Double) : TSQLite3Select; 
      overload;
    function WhereNull (AColumnName : String) : TSQLite3Select;
    function WhereNotNull (AColumnName : String) : TSQLite3Select;

    { Get result. }
    function Get : TSQLite3Result;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FSelectFieldsList : TSQLite3Structures.TSelectFieldsList;
    FWhereFragment : TSQLite3Where;
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
  FWhereFragment := TSQLite3Where.Create;
end;

destructor TSQLite3Select.Destroy;
begin
  FreeAndNil(FSelectFieldsList);
  FreeAndNil(FWhereFragment);
  inherited Destroy;
end;

function TSQLite3Select.All : TSQLite3Select;
var
  item : TSQLite3Structures.TSelectFieldItem;
begin
  item.Column_Name := '*';
  item.Column_AliasName := '';
  FSelectFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Select.Field (AColumnName : String) : TSQLite3Select;
var
  item : TSQLite3Structures.TSelectFieldItem;
begin
  item.Column_Name := AColumnName;
  item.Column_AliasName := '';
  FSelectFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Select.Field (AColumnName, AColumnAlias : String) : 
  TSQLite3Select;
var
  item : TSQLite3Structures.TSelectFieldItem;
begin
  item.Column_Name := AColumnName;
  item.Column_AliasName := AColumnAlias;
  FSelectFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Select.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Select;
begin
  FWhereFragment.Where(AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Select;
begin
  FWhereFragment.Where(AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Select;
begin
  FWhereFragment.Where(AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AValue : String) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(AColumnName, AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AValue : Integer) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(AColumnName, AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AValue : Double) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(AColumnName, AValue);
  Result := Self;  
end;

function TSQLite3Select.WhereNull (AColumnName : String) : TSQLite3Select;
begin
  FWhereFragment.WhereNull(AColumnName);
  Result := Self;  
end;

function TSQLite3Select.WhereNotNull (AColumnName : String) : TSQLite3Select;
begin
  FWhereFragment.WhereNotNull(AColumnName);
  Result := Self;  
end;

function TSQLite3Select.Get : TSQLite3Result;
var
  SQL : String;
  select_elem : TSQLite3Structures.TSelectFieldItem;
  i : Integer;
  Query : TSQLite3Query;
begin
  if not FSelectFieldsList.FirstEntry.HasValue then
    Exit;

  i := 0;
  SQL := 'SELECT ';
  for select_elem in FSelectFieldsList do
  begin
    { For every field. }
    if i > 0 then
      SQL := SQL + ', ';

    { Column name. }
    SQL := SQL + select_elem.Column_Name;

    { Column alias. }
    if select_elem.Column_AliasName <> '' then
      SQL := SQL + ' AS ' + select_elem.Column_AliasName;
    
    Inc(i);     
  end;
  
  SQL := SQL + ' FROM ' + FTableName;
  SQL := SQL + FWhereFragment.GetQuery + ';';

  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);
  FWhereFragment.BindQueryData (Query, 1);
  
  { Run SQL query. }
  Result := Query.Run;  
end;

end.
