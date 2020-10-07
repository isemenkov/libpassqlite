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
unit sqlite3.where;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, sqlite3.structures, sqlite3.query, sqlite3.result_row;

type
  TSQLite3Where = class
  public
    type
      TWhereComparisonOperator
        = sqlite3.structures.TSQLite3Structures.TWhereComparisonOperator;
  public
    constructor Create;
    destructor Destroy; override;

    { Add where clause. }
    procedure Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String); overload;
    procedure Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer); overload;
    procedure Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double); overload;
    procedure Where (AColumnName : String; AValue : String); overload;
    procedure Where (AColumnName : String; AValue : Integer); overload;
    procedure Where (AColumnName : String; AValue : Double); overload;
    procedure WhereNull (AColumnName : String);
    procedure WhereNotNull (AColumnName : String);

    { Form SQL query fragment. }
    function GetQuery : String;

    { Bind where quary fragment data, return next after last binding index. }
    function BindQueryData (AQuery : TSQLite3Query; AStartIndex : Integer) :
      Integer;
  private
    FWhereFieldsList : TSQLite3Structures.TWhereFieldsList;
  end;

implementation

{ TSQLite3Where }

constructor TSQLite3Where.Create;
begin
  FWhereFieldsList := TSQLite3Structures.TWhereFieldsList.Create;
end;

destructor TSQLite3Where.Destroy;
begin
  FreeAndNil(FWhereFieldsList);
  inherited Destroy;
end;

procedure TSQLite3Where.Where (AColumnName : String; AComparison : 
  TWhereComparisonOperator; AValue : String);
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
end;

procedure TSQLite3Where.Where (AColumnName : String; AComparison : 
  TWhereComparisonOperator; AValue : Integer);
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
end;

procedure TSQLite3Where.Where (AColumnName : String; AComparison : 
  TWhereComparisonOperator; AValue : Double);
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
end;

procedure TSQLite3Where.Where (AColumnName : String; AValue : String);
begin
  Where(AColumnName, COMPARISON_EQUAL, AValue);  
end;

procedure TSQLite3Where.Where (AColumnName : String; AValue : Integer); 
begin
  Where(AColumnName, COMPARISON_EQUAL, AValue);
end;

procedure TSQLite3Where.Where (AColumnName : String; AValue : Double);
begin
  Where(AColumnName, COMPARISON_EQUAL, AValue);
end;

procedure TSQLite3Where.WhereNull (AColumnName : String);
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
end;

procedure TSQLite3Where.WhereNotNull (AColumnName : String);
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
end;

function TSQLite3Where.GetQuery : String;
var
  where_item : TSQLite3Structures.TWhereFieldItem;
  i : Integer;
begin
  if not FWhereFieldsList.FirstEntry.HasValue then
    Exit('');

  i := 0;
  Result := ' WHERE ';
  for where_item in FWhereFieldsList do
  begin
    if i > 0 then
      Result := Result + ' AND ';

    Result := Result + where_item.Comparison_ColumnName;
    case where_item.Comparison of  
      TSQLite3Structures.TWhereComparisonOperator.COMPARISON_EQUAL :
        begin
          if where_item.Comparison_Value.Value_Type = SQLITE_NULL then
            Result := Result + ' IS '
          else
            Result := Result + ' = ';
        end;
        
      TSQLite3Structures.TWhereComparisonOperator.COMPARISON_NOT_EQUAL :
        Result := Result + ' <> ';
      TSQLite3Structures.TWhereComparisonOperator.COMPARISON_LESS :
        Result := Result + ' < ';
      TSQLite3Structures.TWhereComparisonOperator.COMPARISON_GREATER :
        Result := Result + ' > ';
      TSQLite3Structures.TWhereComparisonOperator.COMPARISON_LESS_OR_EQUAL :
        Result := Result + ' <= ';
      TSQLite3Structures.TWhereComparisonOperator.COMPARISON_GREATER_OR_EQUAL:
        Result := Result + ' >= ';
      TSQLite3Structures.TWhereComparisonOperator.COMPARISON_NOT :
        Result := Result + ' IS NOT ';
    end;

    Result := Result + '?';
    Inc(i);
  end; 
end;

{ Bind where quary fragment data, return next after last binding index. }
function TSQLite3Where.BindQueryData (AQuery : TSQLite3Query; AStartIndex : 
  Integer) : Integer;
var
  i : Integer;
  where_item : TSQLite3Structures.TWhereFieldItem;
begin
  if not FWhereFieldsList.FirstEntry.HasValue then
    Exit(AStartIndex);

  i := AStartIndex;

  for where_item in FWhereFieldsList do 
  begin
    case where_item.Comparison_Value.Value_Type of
      SQLITE_INTEGER : AQuery.Bind(i, 
        where_item.Comparison_Value.Value_Integer);
      SQLITE_FLOAT : AQuery.Bind(i, where_item.Comparison_Value.Value_Float);
      SQLITE_TEXT : AQuery.Bind(i, where_item.Comparison_Value.Value_Text);
      SQLITE_BLOB : AQuery.Bind(i, where_item.Comparison_Value.Value_Blob);    
      SQLITE_NULL : AQuery.Bind(i);
    end;
    Inc(i);  
  end;

  Result := i;
end;

end.
