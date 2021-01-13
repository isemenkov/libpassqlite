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
unit sqlite3.delete;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.query,
  sqlite3.structures, sqlite3.where;

type
  TSQLite3Delete = class
  public
    type
      TWhereComparisonOperator
        = sqlite3.structures.TSQLite3Structures.TWhereComparisonOperator;
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle :
      ppsqlite3; ATableName : String);
    destructor Destroy; override;

    { Add where clause. }
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Delete; overload;
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Delete; overload;
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Delete; overload;
    function Where (AColumnName : String; AValue : String) : TSQLite3Delete;
      overload;
    function Where (AColumnName : String; AValue : Integer) : TSQLite3Delete;
      overload;
    function Where (AColumnName : String; AValue : Double) : TSQLite3Delete;
      overload;
    function WhereNull (AColumnName : String) : TSQLite3Delete;
    function WhereNotNull (AColumnName : String) : TSQLite3Delete;

    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Delete; overload;
    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Delete; overload;
    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Delete; overload;
    function AndWhere (AColumnName : String; AValue : String) : TSQLite3Delete;
      overload;
    function AndWhere (AColumnName : String; AValue : Integer) : TSQLite3Delete;
      overload;
    function AndWhere (AColumnName : String; AValue : Double) : TSQLite3Delete;
      overload;
    function AndWhereNull (AColumnName : String) : TSQLite3Delete;
    function AndWhereNotNull (AColumnName : String) : TSQLite3Delete;

    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Delete; overload;
    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Delete; overload;
    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Delete; overload;
    function OrWhere (AColumnName : String; AValue : String) : TSQLite3Delete;
      overload;
    function OrWhere (AColumnName : String; AValue : Integer) : TSQLite3Delete;
      overload;
    function OrWhere (AColumnName : String; AValue : Double) : TSQLite3Delete;
      overload;
    function OrWhereNull (AColumnName : String) : TSQLite3Delete;
    function OrWhereNotNull (AColumnName : String) : TSQLite3Delete;

    { Get result. }
    function Get : Integer;
  private
    function PrepareQuery : String;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    function BindQuery (AQuery : TSQLite3Query; AIndex : Integer) : Integer;
      {$IFNDEF DEBUG}inline;{$ENDIF}
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FWhereFragment : TSQLite3Where;
  end;

implementation

{ TSQLite3Delete }

constructor TSQLite3Delete.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FWhereFragment := TSQLite3Where.Create;
end;

destructor TSQLite3Delete.Destroy;
begin
  FreeAndNil(FWhereFragment);
  inherited Destroy;
end;

function TSQLite3Delete.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Delete.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Delete.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self;
end;

function TSQLite3Delete.Where (AColumnName : String; AValue : String) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self;
end;

function TSQLite3Delete.Where (AColumnName : String; AValue : Integer) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Delete.Where (AColumnName : String; AValue : Double) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Delete.WhereNull (AColumnName : String) : TSQLite3Delete;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self; 
end;

function TSQLite3Delete.WhereNotNull (AColumnName : String) : TSQLite3Delete;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Delete.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Delete.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Delete.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self;
end;

function TSQLite3Delete.AndWhere (AColumnName : String; AValue : String) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self;
end;

function TSQLite3Delete.AndWhere (AColumnName : String; AValue : Integer) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Delete.AndWhere (AColumnName : String; AValue : Double) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Delete.AndWhereNull (AColumnName : String) : TSQLite3Delete;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self; 
end;

function TSQLite3Delete.AndWhereNotNull (AColumnName : String) : TSQLite3Delete;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Delete.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Delete.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Delete.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    AComparison, AValue);
  Result := Self;
end;

function TSQLite3Delete.OrWhere (AColumnName : String; AValue : String) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self;
end;

function TSQLite3Delete.OrWhere (AColumnName : String; AValue : Integer) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Delete.OrWhere (AColumnName : String; AValue : Double) : 
  TSQLite3Delete;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Delete.OrWhereNull (AColumnName : String) : TSQLite3Delete;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_OR, AColumnName);
  Result := Self; 
end;

function TSQLite3Delete.OrWhereNotNull (AColumnName : String) : TSQLite3Delete;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_OR, AColumnName);
  Result := Self;  
end;

function TSQLite3Delete.PrepareQuery : String;
var
  SQL : String;
begin
  SQL := 'DELETE FROM ' + FTableName;
  SQL := SQL + FWhereFragment.GetQuery + ';';
  Result := SQL;
end;

function TSQLite3Delete.BindQuery (AQuery : TSQLite3Query; AIndex : Integer) :
  Integer;
begin
  Result := FWhereFragment.BindQueryData(AQuery, AIndex);
end;

function TSQLite3Delete.Get : Integer;
var
  Query : TSQLite3Query;
begin
  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, PrepareQuery,
    [SQLITE_PREPARE_NORMALIZE]);
  BindQuery(Query, 1);
  
  { Run SQL query. }
  Query.Run;
  Result := sqlite3_changes(FDBHandle^);
  FreeAndNil(Query);
end;

end.
