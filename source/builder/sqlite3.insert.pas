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
  SysUtils, libpassqlite, utils.functor, container.list, sqlite3.errors_stack,
  sqlite3.query, sqlite3.structures, sqlite3.result_row;

type
  PSQLite3Insert = ^TSQLite3Insert;
  TInsertValuesList = class;

  { Insert columns list. }
  TInsertColumnsList = class
  public
    constructor Create;
    destructor Destroy; override;

    function Column (AColumnName : String; AColumnType : TDataType) : 
      TInsertColumnsList;
    
    { Facade for TSQLite3Insert.Values function. }
    function Values : TInsertValuesList;
  private
    FColumnsList : TSQLite3Structures.TValuesList;
    FInsert : PSQLite3Insert;
  end;

  { Insert data rows list. }
  TInsertValuesList = class
  public
    constructor Create;
    destructor Destroy; override;

    { Start new insert row. }
    function Row : TInsertValuesList;

    { Add values to insert row. }
    function Value (AValue : Integer) : TInsertValuesList; overload;
    function Value (AValue : Double) : TInsertValuesList; overload;
    function Value (AValue : String) : TInsertValuesList; overload;
    function ValueNull : TInsertValuesList;

    { Facade for TSQLite3Insert.Get function. }
    function Get : Integer;
  private
    type
      TValuesListCompareFunctor = class
        (specialize TBinaryFunctor<TSQLite3Structures.TValuesList, Integer>)
      public
        function Call (AValue1, AValue2 : TSQLite3Structures.TValuesList) : 
          Integer; override;
      end;

      TValuesList = class
        (specialize TList<TSQLite3Structures.TValuesList, 
        TValuesListCompareFunctor>);
  private
    FValuesList : TValuesList;
    FInsert : PSQLite3Insert;
  end;

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

    { Inserted columns list. }
    function Columns : TInsertColumnsList;

    { Inserted values list. }
    function Values : TInsertValuesList;

    { Get result. }
    function Get : Integer;  
  private
    { Prepare multiple insert values data query and bind data. }
    function PrepareMultipleQuery : String;
    function BindMultipleQueryData (AQuery : TSQLite3Query; AIndex : Integer) : 
      Integer;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FValuesList : TSQLite3Structures.TValuesList;
    
    FMultipleColumns : TInsertColumnsList;
    FMultipleValues : TInsertValuesList;
  end;

implementation

{ TInsertColumnsList }

constructor TInsertColumnsList.Create;
begin
  FColumnsList := TSQLite3Structures.TValuesList.Create;
  FInsert := nil;
end;

destructor TInsertColumnsList.Destroy;
begin
  FreeAndNil(FColumnsList);
  inherited Destroy;
end;

function TInsertColumnsList.Column (AColumnName : String; AColumnType : 
  TDataType) : TInsertColumnsList;
var
  item : TSQLite3Structures.TValueItem;
begin
  item.Column_Name := AColumnName;
  item.Value_Type := AColumnType;
  
  item.Value_Integer := 0;
  item.Value_Float := 0;
  item.Value_Text := '';
  item.Value_Blob := nil;

  FColumnsList.Append(item);
  Result := Self;
end;

function TInsertColumnsList.Values : TInsertValuesList;
begin
  Result := FInsert^.Values;
end;

{ TInsertValuesList.TValuesListCompareFunctor }

function TInsertValuesList.TValuesListCompareFunctor.Call (AValue1, AValue2 : 
  TSQLite3Structures.TValuesList) : Integer;
begin
  Result := Longint((AValue1 <> nil) and (AValue2 <> nil));
end;

{ TInsertValuesList }

constructor TInsertValuesList.Create;
begin
  FValuesList := TInsertValuesList.TValuesList.Create;
  FInsert := nil;
end;

destructor TInsertValuesList.Destroy;
begin
  FreeAndNil(FValuesList);
  inherited Destroy;
end;

function TInsertValuesList.Row : TInsertValuesList;
begin
  FValuesList.Append(TSQLite3Structures.TValuesList.Create);
  Result := Self;
end;

function TInsertValuesList.Value (AValue : Integer) : TInsertValuesList;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_INTEGER;
    item.Value_Integer := AValue;
    item.Value_Float := 0;
    item.Value_Text := '';
    item.Value_Blob := nil;

    FValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TInsertValuesList.Value (AValue : Double) : TInsertValuesList;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_FLOAT;
    item.Value_Integer := 0;
    item.Value_Float := AValue;
    item.Value_Text := '';
    item.Value_Blob := nil;

    FValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TInsertValuesList.Value (AValue : String) : TInsertValuesList;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_TEXT;
    item.Value_Integer := 0;
    item.Value_Float := 0;
    item.Value_Text := AValue;
    item.Value_Blob := nil;

    FValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TInsertValuesList.ValueNull : TInsertValuesList;
var
  item : TSQLite3Structures.TValueItem;
begin
  if FValuesList.LastEntry.HasValue then
  begin
    item.Column_Name := '';
    item.Value_Type := SQLITE_NULL;
    item.Value_Integer := 0;
    item.Value_Float := 0;
    item.Value_Text := '';
    item.Value_Blob := nil;

    FValuesList.LastEntry.Value.Append(item);
  end;

  Result := Self;
end;

function TInsertValuesList.Get : Integer;
begin
  Result := FInsert^.Get;
end;

{ TSQLite3Insert }

constructor TSQLite3Insert.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FValuesList := TSQLite3Structures.TValuesList.Create;

  FMultipleColumns := TInsertColumnsList.Create;
  FMultipleValues := TInsertValuesList.Create;

  FMultipleColumns.FInsert := @Self;
  FMultipleValues.FInsert := @Self;
end;

destructor TSQLite3Insert.Destroy;
begin
  FreeAndNil(FValuesList);
  FreeAndNil(FMultipleColumns);
  FreeAndNil(FMultipleValues);

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

function TSQLite3Insert.Columns : TInsertColumnsList;
begin
  Result := FMultipleColumns;
end;

function TSQLite3Insert.Values : TInsertValuesList;
begin
  Result := FMultipleValues;
end;

function TSQLite3Insert.Get : Integer;
var
  Query : TSQLite3Query;
  val : TSQLite3Structures.TValueItem;
  SQL : String;
  i : Integer;
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

    for val in FValuesList do
    begin
      case val.Value_Type of
        SQLITE_INTEGER : Query.Bind(i, val.Value_Integer);
        SQLITE_FLOAT :   Query.Bind(i, val.Value_Float);
        SQLITE_TEXT :    Query.Bind(i, val.Value_Text);
        SQLITE_NULL :    Query.Bind(i);
      end;
      Inc(i);
    end;

    Query.Run;
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
  if (not FMultipleColumns.FColumnsList.FirstEntry.HasValue) or
     (not FMultipleValues.FValuesList.FirstEntry.HasValue) then
    Exit('');
  
  SQL := '';

  { If columns list is not empty. }
  if FMultipleColumns.FColumnsList.FirstEntry.HasValue then
  begin
    SQL := SQL + 'INSERT INTO ' + FTableName + ' (';

    i := 0;
    for column_item in FMultipleColumns.FColumnsList do
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
  for value_row in FMultipleValues.FValuesList do
  begin
    column_iterator := FMultipleColumns.FColumnsList.FirstEntry;
    if i > 0 then
      SQL := SQL + ',';

    j := 0;
    SQL := SQL + '(';

    { For each value item in row. }
    for value_item in value_row do
    begin
      if column_iterator.Value.Value_Type <> value_item.Value_Type then
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
  if not FMultipleValues.FValuesList.FirstEntry.HasValue then
    Exit(AIndex);

  i := AIndex;

  { For each row in list. }
  for value_row in FMultipleValues.FValuesList do
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
            AQuery.Bind(i, value_item.Value_Blob);
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

end.
