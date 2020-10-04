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

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.query,
  sqlite3.structures, sqlite3.result_row;

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
      TSQLite3Structures.TWhereComparisonOperator; AValue : String) : 
      TSQLite3Delete; overload;
    function Where (AColumnName : String; AComparison : 
      TSQLite3Structures.TWhereComparisonOperator; AValue : Integer) : 
      TSQLite3Delete; overload;
    function Where (AColumnName : String; AComparison : 
      TSQLite3Structures.TWhereComparisonOperator; AValue : Double) : 
      TSQLite3Delete; overload;
    function Where (AColumnName : String; AValue : String) : TSQLite3Delete;
      overload;
    function Where (AColumnName : String; AValue : Integer) : TSQLite3Delete;
      overload;
    function Where (AColumnName : String; AValue : Double) : TSQLite3Delete;
      overload;
    function WhereNull (AColumnName : String) : TSQLite3Delete;
    function WhereNotNull (AColumnName : String) : TSQLite3Delete;

    { Get result. }
    function Get : Integer;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FWhereFieldsList : TSQLite3Structures.TWhereFieldsList;
  end;

implementation

{ TSQLite3Delete }

constructor TSQLite3Delete.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FWhereFieldsList := TSQLite3Structures.TWhereFieldsList.Create;
end;

destructor TSQLite3Delete.Destroy;
begin
  FreeAndNil(FWhereFieldsList);
  inherited Destroy;
end;

function TSQLite3Delete.Where (AColumnName : String; AComparison :
  TSQLite3Structures.TWhereComparisonOperator; AValue : String) : 
  TSQLite3Delete;
var
  val : TSQLite3Structures.TWhereFieldItem;
begin
  val.Comparison_ColumnName := AColumnName;
  val.Comparison := AComparison;

  val.Comparison_Value.Column_Name := '';
  val.Comparison_Value.Value_Type := SQLITE_TEXT;
  val.Comparison_Value.Value_Integer := 0;
  val.Comparison_Value.Value_Float := 0;
  val.Comparison_Value.Value_Text := AValue;
  val.Comparison_Value.Value_Blob := nil;

  FWhereFieldsList.Append(val);
  Result := Self;  
end;

function TSQLite3Delete.Where (AColumnName : String; AComparison :
  TSQLite3Structures.TWhereComparisonOperator; AValue : Integer) : 
  TSQLite3Delete;
var
  val : TSQLite3Structures.TWhereFieldItem;
begin
  val.Comparison_ColumnName := AColumnName;
  val.Comparison := AComparison;

  val.Comparison_Value.Column_Name := '';
  val.Comparison_Value.Value_Type := SQLITE_INTEGER;
  val.Comparison_Value.Value_Integer := AValue;
  val.Comparison_Value.Value_Float := 0;
  val.Comparison_Value.Value_Text := '';
  val.Comparison_Value.Value_Blob := nil;
  
  FWhereFieldsList.Append(val);
  Result := Self;  
end;

function TSQLite3Delete.Where (AColumnName : String; AComparison :
  TSQLite3Structures.TWhereComparisonOperator; AValue : Double) : 
  TSQLite3Delete;
var
  val : TSQLite3Structures.TWhereFieldItem;
begin
  val.Comparison_ColumnName := AColumnName;
  val.Comparison := AComparison;

  val.Comparison_Value.Column_Name := '';
  val.Comparison_Value.Value_Type := SQLITE_FLOAT;
  val.Comparison_Value.Value_Integer := 0;
  val.Comparison_Value.Value_Float := AValue;
  val.Comparison_Value.Value_Text := '';
  val.Comparison_Value.Value_Blob := nil;
  
  FWhereFieldsList.Append(val);
  Result := Self;  
end;

function TSQLite3Delete.Where (AColumnName : String; AValue : String) : 
  TSQLite3Delete;
var
  val : TSQLite3Structures.TWhereFieldItem;
begin
  val.Comparison_ColumnName := AColumnName;
  val.Comparison := COMPARISON_EQUAL;

  val.Comparison_Value.Column_Name := '';
  val.Comparison_Value.Value_Type := SQLITE_TEXT;
  val.Comparison_Value.Value_Integer := 0;
  val.Comparison_Value.Value_Float := 0;
  val.Comparison_Value.Value_Text := AValue;
  val.Comparison_Value.Value_Blob := nil;
  
  FWhereFieldsList.Append(val);
  Result := Self;  
end;

function TSQLite3Delete.Where (AColumnName : String; AValue : Integer) : 
  TSQLite3Delete;
var
  val : TSQLite3Structures.TWhereFieldItem;
begin
  val.Comparison_ColumnName := AColumnName;
  val.Comparison := COMPARISON_EQUAL;

  val.Comparison_Value.Column_Name := '';
  val.Comparison_Value.Value_Type := SQLITE_INTEGER;
  val.Comparison_Value.Value_Integer := AValue;
  val.Comparison_Value.Value_Float := 0;
  val.Comparison_Value.Value_Text := '';
  val.Comparison_Value.Value_Blob := nil;
  
  FWhereFieldsList.Append(val);
  Result := Self;  
end;

function TSQLite3Delete.Where (AColumnName : String; AValue : Double) : 
  TSQLite3Delete;
var
  val : TSQLite3Structures.TWhereFieldItem;
begin
  val.Comparison_ColumnName := AColumnName;
  val.Comparison := COMPARISON_EQUAL;

  val.Comparison_Value.Column_Name := '';
  val.Comparison_Value.Value_Type := SQLITE_FLOAT;
  val.Comparison_Value.Value_Integer := 0;
  val.Comparison_Value.Value_Float := AValue;
  val.Comparison_Value.Value_Text := '';
  val.Comparison_Value.Value_Blob := nil;
  
  FWhereFieldsList.Append(val);
  Result := Self;  
end;

function TSQLite3Delete.WhereNull (AColumnName : String) : TSQLite3Delete;
var
  val : TSQLite3Structures.TWhereFieldItem;
begin
  val.Comparison_ColumnName := AColumnName;
  val.Comparison := COMPARISON_EQUAL;

  val.Comparison_Value.Column_Name := '';
  val.Comparison_Value.Value_Type := SQLITE_NULL;
  val.Comparison_Value.Value_Integer := 0;
  val.Comparison_Value.Value_Float := 0;
  val.Comparison_Value.Value_Text := '';
  val.Comparison_Value.Value_Blob := nil;
  
  FWhereFieldsList.Append(val);
  Result := Self;  
end;

function TSQLite3Delete.WhereNotNull (AColumnName : String) : TSQLite3Delete;
var
  val : TSQLite3Structures.TWhereFieldItem;
begin
  val.Comparison_ColumnName := AColumnName;
  val.Comparison := COMPARISON_NOT;

  val.Comparison_Value.Column_Name := '';
  val.Comparison_Value.Value_Type := SQLITE_NULL;
  val.Comparison_Value.Value_Integer := 0;
  val.Comparison_Value.Value_Float := 0;
  val.Comparison_Value.Value_Text := '';
  val.Comparison_Value.Value_Blob := nil;
  
  FWhereFieldsList.Append(val);
  Result := Self;  
end;

function TSQLite3Delete.Get : Integer;
var
  SQL : String;
  where_item : TSQLite3Structures.TWhereFieldItem;
  i : Integer;
  Query : TSQLite3Query;
begin
  SQL := 'DELETE FROM ' + FTableName;

  if FWhereFieldsList.FirstEntry.HasValue then
  begin
    i := 0;
    SQL := SQL + ' WHERE ';
    for where_item in FWhereFieldsList do
    begin
      // TODO

      SQL := SQL + where_item.Comparison_ColumnName;
      case where_item.Comparison of  
        TSQLite3Structures.TWhereComparisonOperator.COMPARISON_EQUAL :
          SQL := SQL + ' = ';
        TSQLite3Structures.TWhereComparisonOperator.COMPARISON_NOT_EQUAL :
          SQL := SQL + ' <> ';
        TSQLite3Structures.TWhereComparisonOperator.COMPARISON_LESS :
          SQL := SQL + ' < ';
        TSQLite3Structures.TWhereComparisonOperator.COMPARISON_GREATER :
          SQL := SQL + ' > ';
        TSQLite3Structures.TWhereComparisonOperator.COMPARISON_LESS_OR_EQUAL :
          SQL := SQL + ' <= ';
        TSQLite3Structures.TWhereComparisonOperator.COMPARISON_GREATER_OR_EQUAL:
          SQL := SQL + ' >= ';
        TSQLite3Structures.TWhereComparisonOperator.COMPARISON_NOT :
          SQL := SQL + ' NOT ';
      end;

      SQL := SQL + '?';
      Inc(i);
    end;
  end;

  i := 1;
  SQL := SQL + ';'; 
  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);

  if FWhereFieldsList.FirstEntry.HasValue then
  begin
    for where_item in FWhereFieldsList do
    begin
      case where_item.Comparison_Value.Value_Type of
        SQLITE_INTEGER : Query.Bind(i, 
          where_item.Comparison_Value.Value_Integer);
        SQLITE_FLOAT : Query.Bind(i, where_item.Comparison_Value.Value_Float);
        SQLITE_TEXT : Query.Bind(i, where_item.Comparison_Value.Value_Text);
        SQLITE_BLOB : Query.Bind(i, where_item.Comparison_Value.Value_Blob);    
        SQLITE_NULL : Query.Bind(i);
      end;
      Inc(i);  
    end;
  end;
  
  { Run SQL query. }
  Query.Run;
  Result := sqlite3_changes(FDBHandle^);
  FreeAndNil(Query);
end;

end.
