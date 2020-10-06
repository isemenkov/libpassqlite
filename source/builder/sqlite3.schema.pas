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
unit sqlite3.schema;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, sqlite3.result_row, container.list, utils.functor;

type
  TSQLite3Schema = class
  public
    type
      { Table column item. }
      TColumnItem = record
        Column_Name : String;
        Column_Type : TDataType;
        
        Option_AutoIncrement : Boolean;
        Option_PrimaryKey : Boolean;
        Option_NotNull : Boolean;
        Option_Unique : Boolean;
      end;

      { ColumnItem compare functor. }
      TColumnItemCompareFunctor = class
        (specialize TBinaryFunctor<TColumnItem, Integer>)
      public
        function Call (AValue1, AValue2 : TColumnItem) : Integer; override;
      end;

      { Columns list. }  
      TColumnsList = class
        (specialize TList<TColumnItem, TColumnItemCompareFunctor>);
  public
    constructor Create;
    destructor Destroy; override;

    { Create autoincrement primary key column id. }
    function Id (AColumnName : String = 'id') : TSQLite3Schema;

    { Create float column. }
    function Float (AColumnName : String) : TSQLite3Schema;

    { Create integer column. }
    function Integer (AColumnName : String) : TSQLite3Schema;

    { Create text column. }
    function Text (AColumnName : String) : TSQLite3Schema;

    { Create blob column. }
    function Blob (AColumnName : String) : TSQLite3Schema;

    { Add autoincrement to the last adding element. }
    function Autoincrement : TSQLite3Schema;

    { Add not null modifier to the last adding element. }
    function NotNull : TSQLite3Schema;

    { Add unique modifier to the last adding element. }
    function Unique : TSQLite3Schema;

    { Clear columns list. }
    procedure Clear;
  private
    FColumns : TColumnsList;
  public
    { Get schema columns list. }
    property Columns : TColumnsList read FColumns;
  end;

implementation

{ TSQLite3Schema.TColumnItemCompareFunctor }

function TSQLite3Schema.TColumnItemCompareFunctor.Call (AValue1, AValue2 :
  TColumnItem) : Integer;
begin
  if AValue1.Column_Name < AValue2.Column_Name then
    Result := -1
  else if AValue2.Column_Name < AValue1.Column_Name then
    Result := 1
  else
    Result := 0;
end;

{ TSQLite3Schema }

constructor TSQLite3Schema.Create;
begin
  FColumns := TColumnsList.Create;
end;

destructor TSQLite3Schema.Destroy;
begin
  FreeAndNil(FColumns);
  inherited Destroy;
end;

procedure TSQLite3Schema.Clear;
begin
  FColumns.Clear;
end;

function TSQLite3Schema.Id (AColumnName : String) : TSQLite3Schema;
var
  Column : TColumnItem;
begin
  Column.Column_Name := AColumnName;
  Column.Column_Type := SQLITE_INTEGER;
  
  Column.Option_AutoIncrement := True;
  Column.Option_PrimaryKey := True;
  Column.Option_NotNull := True;
  Column.Option_Unique := True;

  FColumns.Append(Column);
  Result := Self;
end;

function TSQLite3Schema.Float (AColumnName : String) : TSQLite3Schema;
var
  Column : TColumnItem;
begin
  Column.Column_Name := AColumnName;
  Column.Column_Type := SQLITE_FLOAT;
  
  Column.Option_AutoIncrement := False;
  Column.Option_PrimaryKey := False;
  Column.Option_NotNull := False;
  Column.Option_Unique := False;

  FColumns.Append(Column);
  Result := Self;
end;

function TSQLite3Schema.Integer (AColumnName : String) : TSQLite3Schema;
var
  Column : TColumnItem;
begin
  Column.Column_Name := AColumnName;
  Column.Column_Type := SQLITE_INTEGER;
  
  Column.Option_AutoIncrement := False;
  Column.Option_PrimaryKey := False;
  Column.Option_NotNull := False;
  Column.Option_Unique := False;

  FColumns.Append(Column);
  Result := Self;
end;

function TSQLite3Schema.Text (AColumnName : String) : TSQLite3Schema;
var
  Column : TColumnItem;
begin
  Column.Column_Name := AColumnName;
  Column.Column_Type := SQLITE_TEXT;
  
  Column.Option_AutoIncrement := False;
  Column.Option_PrimaryKey := False;
  Column.Option_NotNull := False;
  Column.Option_Unique := False;

  FColumns.Append(Column);
  Result := Self;
end;

function TSQLite3Schema.Blob (AColumnName : String) : TSQLite3Schema;
var
  Column : TColumnItem;
begin
  Column.Column_Name := AColumnName;
  Column.Column_Type := SQLITE_TEXT;
  
  Column.Option_AutoIncrement := False;
  Column.Option_PrimaryKey := False;
  Column.Option_NotNull := False;
  Column.Option_Unique := False;

  FColumns.Append(Column);
  Result := Self;
end;

function TSQLite3Schema.Autoincrement : TSQLite3Schema;
var
  Column : TColumnItem;
begin
  if FColumns.LastEntry.HasValue then
  begin
    Column := FColumns.LastEntry.Value;
    Column.Option_AutoIncrement := True;
    FColumns.LastEntry.Value := Column;    
  end; 

  Result := Self; 
end;

function TSQLite3Schema.NotNull : TSQLite3Schema;
var
  Column : TColumnItem;
begin
  if FColumns.LastEntry.HasValue then
  begin
    Column := FColumns.LastEntry.Value;
    Column.Option_NotNull := True;
    FColumns.LastEntry.Value := Column;    
  end; 

  Result := Self; 
end;

function TSQLite3Schema.Unique : TSQLite3Schema;
var
  Column : TColumnItem;
begin
  if FColumns.LastEntry.HasValue then
  begin
    Column := FColumns.LastEntry.Value;
    Column.Option_Unique := True;
    FColumns.LastEntry.Value := Column;   
  end; 

  Result := Self;
end;

end.
