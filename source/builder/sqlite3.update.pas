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
unit sqlite3.update;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.query,
  sqlite3.structures, sqlite3.where, sqlite3.result_row, Classes,
  container.memorybuffer;

type
  TSQLite3Update = class
  public
    type
      TWhereComparisonOperator
        = sqlite3.structures.TSQLite3Structures.TWhereComparisonOperator;
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle :
      ppsqlite3; ATableName : String);
    destructor Destroy; override;

    { Add update field to list. }
    function Value (AColumnName : String; AValue : String) : TSQLite3Update;
      overload;
    function Value (AColumnName : String; AValue : Integer) : TSQLite3Update;
      overload;
    function Value (AColumnName : String; AValue : Double) : TSQLite3Update;
      overload;
    function Value (AColumnName : String; AValue : TStream) : TSQLite3Update;
      overload;
    function Value (AColumnName : String; AValue : TMemoryBuffer) : 
      TSQLite3Update; overload;
    function ValueNull (AColumnName : String) : TSQLite3Update; overload;
    
    { Add where clause. }
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Update; overload;
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Update; overload;
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Update; overload;
    function Where (AColumnName : String; AValue : String) : TSQLite3Update; 
      overload;
    function Where (AColumnName : String; AValue : Integer) : TSQLite3Update; 
      overload;
    function Where (AColumnName : String; AValue : Double) : TSQLite3Update; 
      overload;
    function WhereNull (AColumnName : String) : TSQLite3Update;
    function WhereNotNull (AColumnName : String) : TSQLite3Update;

    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Update; overload;
    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Update; overload;
    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Update; overload;
    function AndWhere (AColumnName : String; AValue : String) : TSQLite3Update; 
      overload;
    function AndWhere (AColumnName : String; AValue : Integer) : TSQLite3Update; 
      overload;
    function AndWhere (AColumnName : String; AValue : Double) : TSQLite3Update; 
      overload;
    function AndWhereNull (AColumnName : String) : TSQLite3Update;
    function AndWhereNotNull (AColumnName : String) : TSQLite3Update;

    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Update; overload;
    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Update; overload;
    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Update; overload;
    function OrWhere (AColumnName : String; AValue : String) : TSQLite3Update; 
      overload;
    function OrWhere (AColumnName : String; AValue : Integer) : TSQLite3Update; 
      overload;
    function OrWhere (AColumnName : String; AValue : Double) : TSQLite3Update; 
      overload;
    function OrWhereNull (AColumnName : String) : TSQLite3Update;
    function OrWhereNotNull (AColumnName : String) : TSQLite3Update;

    { Get result. }
    function Get : Integer;
  private
    function PrepareQuery : String;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    function BindQueryData (AQuery : TSQLite3Query; AIndex : Integer) :
      Integer;
      {$IFNDEF DEBUG}inline;{$ENDIF}
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FUpdatesFieldsList : TSQLite3Structures.TUpdatesFieldsList;
    FWhereFragment : TSQLite3Where;
  end;

implementation

{ TSQLite3Update }

constructor TSQLite3Update.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FUpdatesFieldsList := TSQLite3Structures.TUpdatesFieldsList.Create;
  FWhereFragment := TSQLite3Where.Create;
end;

destructor TSQLite3Update.Destroy;
begin
  FreeAndNil(FUpdatesFieldsList);
  FreeAndNil(FWhereFragment);
  inherited Destroy;
end;

function TSQLite3Update.ValueNull (AColumnName : String) : TSQLite3Update;
var
  item : TSQLite3Structures.TUpdateItem;
begin
  item.Column_Name := AColumnName;
  item.Value.Column_Name := '';
  item.Value.Value_Type := SQLITE_NULL;
  item.Value.Value_Integer := 0;
  item.Value.Value_Float := 0;
  item.Value.Value_Text := '';
  item.Value.Value_BlobBuffer := nil;

  FUpdatesFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Update.Value (AColumnName : String; AValue : String) : 
  TSQLite3Update;
var
  item : TSQLite3Structures.TUpdateItem;
begin
  item.Column_Name := AColumnName;
  item.Value.Column_Name := '';
  item.Value.Value_Type := SQLITE_TEXT;
  item.Value.Value_Integer := 0;
  item.Value.Value_Float := 0;
  item.Value.Value_Text := AValue;
  item.Value.Value_BlobBuffer := nil;

  FUpdatesFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Update.Value (AColumnName : String; AValue : Integer) : 
  TSQLite3Update;
var
  item : TSQLite3Structures.TUpdateItem;
begin
  item.Column_Name := AColumnName;
  item.Value.Column_Name := '';
  item.Value.Value_Type := SQLITE_INTEGER;
  item.Value.Value_Integer := AValue;
  item.Value.Value_Float := 0;
  item.Value.Value_Text := '';
  item.Value.Value_BlobBuffer := nil;

  FUpdatesFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Update.Value (AColumnName : String; AValue : Double) : 
  TSQLite3Update;
var
  item : TSQLite3Structures.TUpdateItem;
begin
  item.Column_Name := AColumnName;
  item.Value.Column_Name := '';
  item.Value.Value_Type := SQLITE_FLOAT;
  item.Value.Value_Integer := 0;
  item.Value.Value_Float := AValue;
  item.Value.Value_Text := '';
  item.Value.Value_BlobBuffer := nil;

  FUpdatesFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Update.Value (AColumnName : String; AValue : TStream) : 
  TSQLite3Update;
var
  item : TSQLite3Structures.TUpdateItem;
  ptr : Pointer;
begin
  item.Value.Value_BlobBuffer := TMemoryBuffer.Create;
  ptr := item.Value.Value_BlobBuffer.GetAppendBuffer(AValue.Size);
  AValue.Read(ptr, AValue.Size);

  item.Column_Name := AColumnName;
  item.Value.Column_Name := '';
  item.Value.Value_Type := SQLITE_BLOB;
  item.Value.Value_Integer := 0;
  item.Value.Value_Float := 0;
  item.Value.Value_Text := '';

  FUpdatesFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Update.Value (AColumnName : String; AValue : TMemoryBuffer) : 
  TSQLite3Update;
var
  item : TSQLite3Structures.TUpdateItem;
begin
  item.Column_Name := AColumnName;
  item.Value.Column_Name := '';
  item.Value.Value_Type := SQLITE_BLOB;
  item.Value.Value_Integer := 0;
  item.Value.Value_Float := 0;
  item.Value.Value_Text := '';
  item.Value.Value_BlobBuffer := AValue;

  FUpdatesFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Update.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Update.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Update.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Update.Where (AColumnName : String; AValue : String) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Update.Where (AColumnName : String; AValue : Integer) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self;  
end;

function TSQLite3Update.Where (AColumnName : String; AValue : Double) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Update.WhereNull (AColumnName : String) : TSQLite3Update;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Update.WhereNotNull (AColumnName : String) : TSQLite3Update;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Update.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Update.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Update.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Update.AndWhere (AColumnName : String; AValue : String) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Update.AndWhere (AColumnName : String; AValue : Integer) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self;  
end;

function TSQLite3Update.AndWhere (AColumnName : String; AValue : Double) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Update.AndWhereNull (AColumnName : String) : TSQLite3Update;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Update.AndWhereNotNull (AColumnName : String) : TSQLite3Update;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Update.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Update.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Update.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    AComparison, AValue);
  Result := Self; 
end;

function TSQLite3Update.OrWhere (AColumnName : String; AValue : String) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Update.OrWhere (AColumnName : String; AValue : Integer) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self;  
end;

function TSQLite3Update.OrWhere (AColumnName : String; AValue : Double) : 
  TSQLite3Update;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, AColumnName, 
    TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, AValue);
  Result := Self; 
end;

function TSQLite3Update.OrWhereNull (AColumnName : String) : TSQLite3Update;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_OR, AColumnName);
  Result := Self;  
end;

function TSQLite3Update.OrWhereNotNull (AColumnName : String) : TSQLite3Update;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_OR, AColumnName);
  Result := Self;  
end;

function TSQLite3Update.PrepareQuery : String;
var
  SQL : String;
  update_item : TSQLite3Structures.TUpdateItem;
  i : Integer;
begin
  if not FUpdatesFieldsList.FirstEntry.HasValue then
    Exit('');

  i := 0;
  SQL := 'UPDATE ' + FTableName + ' SET ';
  for update_item in FUpdatesFieldsList do
  begin
    { For every update pair. }
    if i > 0 then
      SQL := SQL + ', ';

    { Set updated column name. }
    SQL := SQL + update_item.Column_Name + ' = ?';      

    Inc(i);
  end;

  SQL := SQL + FWhereFragment.GetQuery + ';';

  Result := SQL;
end;

function TSQLite3Update.BindQueryData (AQuery : TSQLite3Query; AIndex : 
  Integer) : Integer;
var
  update_item : TSQLite3Structures.TUpdateItem;
  i : Integer;
begin
  if not FUpdatesFieldsList.FirstEntry.HasValue then
    Exit(AIndex);

  i := AIndex;
  for update_item in FUpdatesFieldsList do
  begin
    case update_item.Value.Value_Type of
      SQLITE_INTEGER : AQuery.Bind(i, update_item.Value.Value_Integer);
      SQLITE_FLOAT : AQuery.Bind(i, update_item.Value.Value_Float);
      SQLITE_TEXT : AQuery.Bind(i, update_item.Value.Value_Text);
      SQLITE_BLOB : AQuery.BindBlob(i,
        update_item.Value.Value_BlobBuffer.GetBufferData,
        update_item.Value.Value_BlobBuffer.GetBufferDataSize);
      SQLITE_NULL : AQuery.Bind(i);
    end;
    Inc(i);
  end;
  
  i := FWhereFragment.BindQueryData(AQuery, i);
  Result := i;
end;

function TSQLite3Update.Get : Integer;
var
  Query : TSQLite3Query;
begin
  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, PrepareQuery,
    [SQLITE_PREPARE_NORMALIZE]);

  BindQueryData(Query, 1);

  { Run SQL query. }
  Query.Run;
  Result := sqlite3_changes(FDBHandle^);
  FreeAndNil(Query);
end;

end.
