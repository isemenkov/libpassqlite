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

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, utils.functor, container.list, sqlite3.errors_stack,
  sqlite3.query, sqlite3.structures, sqlite3.result_row, Classes, 
  container.memorybuffer;

type
  TSQLite3Insert = class
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle :
      ppsqlite3; ATableName : String);
    destructor Destroy; override;

    { Add value to insert list. }
    function Value (AColumnName : String; AValue : Integer) : TSQLite3Insert; 
      overload;
    function Value (AColumnName : String; AValue : Double) : TSQLite3Insert;
      overload;
    function Value (AColumnName : String; AValue : String) : TSQLite3Insert;
      overload;
    function Value (AColumnName : String; AValue : TStream) : TSQLite3Insert;
      overload;
    function Value (AColumnName : String; AValue : TMemoryBuffer) : 
      TSQLite3Insert; overload;
    function ValueNull (AColumnName : String) : TSQLite3Insert; overload;

    { Set multiple insert column data. }
    function Column (AColumnName : String; AColumnType : TDataType) : 
      TSQLite3Insert;

    { Start new insert row. }
    function Row : TSQLite3Insert;

    { Add values to insert row. }
    function Value (AValue : Integer) : TSQLite3Insert; overload;
    function Value (AValue : Double) : TSQLite3Insert; overload;
    function Value (AValue : String) : TSQLite3Insert; overload;
    function Value (AValue : TStream) : TSQLite3Insert; overload;
    function Value (AValue : TMemoryBuffer) : TSQLite3Insert; overload;
    function ValueNull : TSQLite3Insert; overload;

    { Get result. }
    function Get : Integer;  
  private
    { Prepare multiple insert values data query and bind data. }
    function PrepareMultipleQuery : String;
    function BindMultipleQueryData (AQuery : TSQLite3Query; AIndex : Integer) : 
      Integer;

    { Write blob data. }
    procedure WriteBlob ({%H-}ARowIndex : sqlite3_int64; {%H-}AColumnName : String; 
      {%H-}AStream : TStream); overload;
    procedure WriteBlob (ARowIndex : sqlite3_int64; AColumnName : String; 
      ABuffer : TMemoryBuffer); overload;
  private
    type
      TMultipleValuesListCompareFunctor = class
        ({$IFDEF FPC}specialize{$ENDIF} 
        TBinaryFunctor<TSQLite3Structures.TValuesList, Integer>)
      public
        function Call (AValue1, AValue2 : TSQLite3Structures.TValuesList) : 
          Integer; override;
      end;

      TMultipleValuesList = {$IFDEF FPC}type specialize{$ENDIF} 
        TList<TSQLite3Structures.TValuesList, 
        TMultipleValuesListCompareFunctor>;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FValuesList : TSQLite3Structures.TValuesList;
    FColumnsList : TSQLite3Structures.TValuesList;
    FMultipleValuesList : TMultipleValuesList;
  end;

implementation

{ TSQLite3Insert.TValuesListCompareFunctor }

function TSQLite3Insert.TMultipleValuesListCompareFunctor.Call (AValue1, 
  AValue2 : TSQLite3Structures.TValuesList) : Integer;
begin
  Result := Longint((AValue1 <> nil) and (AValue2 <> nil));
end;

{ TSQLite3Insert }

constructor TSQLite3Insert.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FValuesList := TSQLite3Structures.TValuesList.Create;
  FColumnsList := TSQLite3Structures.TValuesList.Create;
  FMultipleValuesList := TMultipleValuesList.Create;
end;

destructor TSQLite3Insert.Destroy;
begin
  FreeAndNil(FValuesList);
  FreeAndNil(FColumnsList);
  FreeAndNil(FMultipleValuesList);

  inherited Destroy;
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
  val.Value_BlobStream := nil;
  val.Value_BlobBuffer := nil;
  val.Value_BlobLength := 0;

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
  val.Value_BlobStream := nil;
  val.Value_BlobBuffer := nil;
  val.Value_BlobLength := 0;

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
  val.Value_BlobStream := nil;
  val.Value_BlobBuffer := nil;
  val.Value_BlobLength := 0;

  FValuesList.Append(val);
  Result := Self;
end;

function TSQLite3Insert.Value (AColumnName : String; AValue : TStream) : 
  TSQLite3Insert;
var
  val : TSQLite3Structures.TValueItem;
begin
  val.Column_Name := AColumnName;

  val.Value_Type := SQLITE_BLOB;
  val.Value_Integer := 0;
  val.Value_Float := 0;
  val.Value_Text := '';
  val.Value_BlobStream := @AValue;
  val.Value_BlobBuffer := nil;
  val.Value_BlobLength := AValue.Size;

  FValuesList.Append(val);
  Result := Self;
end;

function TSQLite3Insert.Value (AColumnName : String; AValue : TMemoryBuffer) : 
  TSQLite3Insert;
var
  val : TSQLite3Structures.TValueItem;
begin
  val.Column_Name := AColumnName;

  val.Value_Type := SQLITE_BLOB;
  val.Value_Integer := 0;
  val.Value_Float := 0;
  val.Value_Text := '';
  val.Value_BlobStream := nil;
  val.Value_BlobBuffer := @AValue;
  val.Value_BlobLength := AValue.GetBufferDataSize;

  FValuesList.Append(val);
  Result := Self;
end;

function TSQLite3Insert.ValueNull (AColumnName : String) : TSQLite3Insert;
var
  val : TSQLite3Structures.TValueItem;
begin
  val.Column_Name := AColumnName;

  val.Value_Type := SQLITE_NULL;
  val.Value_Integer := 0;
  val.Value_Float := 0;
  val.Value_Text := '';
  val.Value_BlobStream := nil;
  val.Value_BlobBuffer := nil;
  val.Value_BlobLength := 0;

  FValuesList.Append(val);
  Result := Self;
end;

function TSQLite3Insert.Column (AColumnName : String; AColumnType : 
  TDataType) : TSQLite3Insert;
var
  item : TSQLite3Structures.TValueItem;
begin
  item.Column_Name := AColumnName;
  item.Value_Type := AColumnType;
  
  item.Value_Integer := 0;
  item.Value_Float := 0;
  item.Value_Text := '';
  item.Value_BlobStream := nil;
  item.Value_BlobBuffer := nil;
  item.Value_BlobLength := 0;

  FColumnsList.Append(item);
  Result := Self;
end;

function TSQLite3Insert.Row : TSQLite3Insert;
begin
  FMultipleValuesList.Append(TSQLite3Structures.TValuesList.Create);
  Result := Self;
end;

function TSQLite3Insert.Value (AValue : Integer) : TSQLite3Insert;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FMultipleValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_INTEGER;
    item.Value_Integer := AValue;
    item.Value_Float := 0;
    item.Value_Text := '';
    item.Value_BlobStream := nil;
    item.Value_BlobBuffer := nil;
    item.Value_BlobLength := 0;

    FMultipleValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TSQLite3Insert.Value (AValue : Double) : TSQLite3Insert;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FMultipleValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_FLOAT;
    item.Value_Integer := 0;
    item.Value_Float := AValue;
    item.Value_Text := '';
    item.Value_BlobStream := nil;
    item.Value_BlobBuffer := nil;
    item.Value_BlobLength := 0;

    FMultipleValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TSQLite3Insert.Value (AValue : String) : TSQLite3Insert;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FMultipleValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_TEXT;
    item.Value_Integer := 0;
    item.Value_Float := 0;
    item.Value_Text := AValue;
    item.Value_BlobStream := nil;
    item.Value_BlobBuffer := nil;
    item.Value_BlobLength := 0;

    FMultipleValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TSQLite3Insert.Value (AValue : TStream) : TSQLite3Insert;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FMultipleValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_BLOB;
    item.Value_Integer := 0;
    item.Value_Float := 0;
    item.Value_Text := '';
    item.Value_BlobStream := @AValue;
    item.Value_BlobBuffer := nil;
    item.Value_BlobLength := AValue.Size;

    FMultipleValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TSQLite3Insert.Value (AValue : TMemoryBuffer) : TSQLite3Insert;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FMultipleValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_BLOB;
    item.Value_Integer := 0;
    item.Value_Float := 0;
    item.Value_Text := '';
    item.Value_BlobStream := nil;
    item.Value_BlobBuffer := @AValue;
    item.Value_BlobLength := AValue.GetBufferDataSize;

    FMultipleValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TSQLite3Insert.ValueNull : TSQLite3Insert;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FMultipleValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_NULL;
    item.Value_Integer := 0;
    item.Value_Float := 0;
    item.Value_Text := '';
    item.Value_BlobStream := nil;
    item.Value_BlobBuffer := nil;

    FMultipleValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TSQLite3Insert.Get : Integer;
var
  Query : TSQLite3Query;
  val : TSQLite3Structures.TValueItem;
  SQL : String;
  i : Integer;
  blob_count : Integer;
  {%H-}row_index : sqlite3_int64;
begin

  { Set values. }
  if FValuesList.FirstEntry.HasValue then
  begin  

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
    
    Query := TSQLite3Query.Create (FErrorsStack, FDBHandle, SQL,
      [SQLITE_PREPARE_NORMALIZE]);

    blob_count := 0;
    for val in FValuesList do
    begin
      case val.Value_Type of
        SQLITE_INTEGER : Query.Bind(i, val.Value_Integer);
        SQLITE_FLOAT :   Query.Bind(i, val.Value_Float);
        SQLITE_TEXT :    Query.Bind(i, val.Value_Text);
        SQLITE_BLOB : 
          begin
            Query.BindBlobZero(i, val.Value_BlobLength);
            Inc(blob_count);
          end;
        SQLITE_NULL :    Query.Bind(i);
      end;
      Inc(i);
    end;

    Query.Run;

    // WriteBlob

    Result := sqlite3_changes(FDBHandle^);
    FreeAndNil(Query);

  end else
  { Set multiple values. }
  begin
    
    SQL := PrepareMultipleQuery;
    Query := TSQLite3Query.Create (FErrorsStack, FDBHandle, SQL,
      [SQLITE_PREPARE_NORMALIZE]);
    BindMultipleQueryData(Query, 1);

    Query.Run;
    Result := sqlite3_changes(FDBHandle^);
    FreeAndNil(Query);

  end;  
end;

function TSQLite3Insert.PrepareMultipleQuery : String;
var
  SQL : String;
  column_item : TSQLite3Structures.TValueItem;
  value_row : TSQLite3Structures.TValuesList;
  column_iterator : TSQLite3Structures.TValuesList.TIterator;
  value_item : TSQLite3Structures.TValueItem;
  i, j : Integer;
begin
  if (not FColumnsList.FirstEntry.HasValue) or
     (not FMultipleValuesList.FirstEntry.HasValue) then
    Exit('');
  
  SQL := '';

  { If columns list is not empty. }
  if FColumnsList.FirstEntry.HasValue then
  begin
    SQL := SQL + 'INSERT INTO ' + FTableName + ' (';

    i := 0;
    for column_item in FColumnsList do
    begin
      { For each column name. }
      if i > 0 then
        SQL := SQL + ', ';

      SQL := SQL + column_item.Column_Name;
      Inc(i);
    end;

    SQL := SQL + ')';
  end;

  SQL := SQL + ' VALUES ';

  { For each row in list. }
  i := 0;
  for value_row in FMultipleValuesList do
  begin
    column_iterator := FColumnsList.FirstEntry;
    if i > 0 then
      SQL := SQL + ',';

    j := 0;
    SQL := SQL + '(';

    { For each value item in row. }
    for value_item in value_row do
    begin
      if (column_iterator.Value.Value_Type <> value_item.Value_Type) and
         (value_item.Value_Type <> SQLITE_NULL) then
        raise Exception.Create('Mistmach column type.');

      if j > 0 then
        SQL := SQL + ', ';

      SQL := SQL + '?';
      column_iterator := column_iterator.Next;
      Inc(j);
    end;
    SQL := SQL + ') ';
    Inc(i);
  end;

  SQL := SQL + ';';
  Result := SQL;  
end;

function TSQLite3Insert.BindMultipleQueryData (AQuery : TSQLite3Query; AIndex : 
  Integer) : Integer;
var
  value_row : TSQLite3Structures.TValuesList;
  value_item : TSQLite3Structures.TValueItem;
  i : Integer;
begin
  if not FMultipleValuesList.FirstEntry.HasValue then
    Exit(AIndex);

  i := AIndex;

  { For each row in list. }
  for value_row in FMultipleValuesList do
  begin
    for value_item in value_row do
    begin
      case value_item.Value_Type of
        SQLITE_INTEGER : 
          begin
            AQuery.Bind(i, value_item.Value_Integer);
          end;
        SQLITE_FLOAT : 
          begin
            AQuery.Bind(i, value_item.Value_Float);
          end;
        SQLITE_BLOB : 
          begin
            AQuery.BindBlobZero(i, value_item.Value_BlobLength);
          end;
        SQLITE_TEXT :
          begin
            AQuery.Bind(i, value_item.Value_Text);
          end;
        SQLITE_NULL :
          begin
            AQuery.Bind(i);
          end;
      end;
      Inc(i);
    end;
  end;

  Result := i;
end;

procedure TSQLite3Insert.WriteBlob (ARowIndex : sqlite3_int64; AColumnName :
  String; AStream : TStream);
begin
  
end;

procedure TSQLite3Insert.WriteBlob (ARowIndex : sqlite3_int64; AColumnName :
  String; ABuffer : TMemoryBuffer);
var
  blob : psqlite3_blob;
  result_code : Integer;
begin
  result_code := sqlite3_blob_open(FDBHandle^, 'main',
    PAnsiChar(AnsiString(FTableName)), PAnsiChar(AnsiString(AColumnName)),
    ARowIndex, 1, @blob);
  
  if result_code <> SQLITE_OK then
  begin
    FErrorsStack^.Push(result_code);
    Exit;
  end;

  FErrorsStack^.Push(sqlite3_blob_write(blob, ABuffer.GetBufferData, 
    ABuffer.GetBufferDataSize, 0));
  FErrorsStack^.Push(sqlite3_blob_close(blob));
end;

end.