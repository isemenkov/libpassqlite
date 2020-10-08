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
unit sqlite3.table;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.schema, sqlite3.query,
  sqlite3.result_row, sqlite3.insert, sqlite3.select, sqlite3.update,
  sqlite3.delete, sqlite3.result;

type
  TSQLite3Table = class
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle : 
      ppsqlite3; ATableName : String);
    destructor Destroy; override;

    { Create new table. }
    procedure New (ASchema : TSQLite3Schema);
    procedure NewIfNotExists (ASchema : TSQLite3Schema);

    { Check current database table schema. }
    function CheckSchema (ASchema : TSQLite3Schema) : Boolean; 

    { Check if table exists. }
    function Exists : Boolean;

    { Check if table has column. }
    function HasColumn (AColumnName : String) : Boolean;

    { Delete table. }
    procedure Drop;
    procedure DropIfExists;

    { Rename table. }
    procedure Rename (ANewName : String);

    { Get select interface. }
    function Select : TSQLite3Select;

    { Get insert interface. }
    function Insert : TSQLite3Insert;

    { Get update interface. }
    function Update : TSQLite3Update;

    { Get delete interface. }
    function Delete : TSQLite3Delete;
  private
    procedure CreateTable (ASchema : TSQLite3Schema; AIfNotExists : Boolean);
    procedure DropTable (AIfExists : Boolean);
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
  end;

implementation

{ TSQLite3Builder }

constructor TSQLite3Table.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
end;

destructor TSQLite3Table.Destroy;
begin
  inherited Destroy;
end;

procedure TSQLite3Table.CreateTable (ASchema : TSQLite3Schema; AIfNotExists :
  Boolean);
var
  SQL : String;
  column : TSQLite3Schema.TColumnItem;
  i : Integer;
  Query : TSQLite3Query;
begin
  if not ASchema.Columns.FirstEntry.HasValue then
    Exit;

  i := 0;
  SQL := 'CREATE TABLE ';
  
  if AIfNotExists then
    SQL := SQL + ' IF NOT EXISTS ';

  SQL := SQL + FTableName + ' (';
  for column in ASchema.Columns do
  begin
    { For every column. }
    if i > 0 then
      SQL := SQL + ',';

    case column.Column_Type of
      SQLITE_INTEGER : SQL := SQL + column.Column_Name + ' INTEGER';
      SQLITE_FLOAT   : SQL := SQL + column.Column_Name + ' REAL';    
      SQLITE_BLOB    : SQL := SQL + column.Column_Name + ' BLOB';  
      SQLITE_TEXT    : SQL := SQL + column.Column_Name + ' TEXT';
    end;

    { Add modificators. }
    if column.Option_PrimaryKey then
      SQL := SQL + ' PRIMARY KEY';

    if column.Option_PrimaryKey and column.Option_AutoIncrement then
      SQL := SQL + ' AUTOINCREMENT';

    if column.Option_NotNull then
      SQL := SQL + ' NOT NULL';

    if column.Option_Unique then
      SQL := SQL + ' UNIQUE';

    Inc(i);
  end;
  SQL := SQL + ');';

  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);
  Query.Run;
  FreeAndNil(Query);
end;

procedure TSQLite3Table.New (ASchema : TSQLite3Schema);
begin
  CreateTable(ASchema, False);  
end;

procedure TSQLite3Table.NewIfNotExists (ASchema : TSQLite3Schema);
begin
  CreateTable(ASchema, True);
end;

function TSQLite3Table.CheckSchema (ASchema : TSQLite3Schema) : Boolean;
var
  column : TSQLite3Schema.TColumnsList.TIterator;
  Query : TSQLite3Query;
  Row : TSQLite3ResultRow;
begin
  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle,
    'PRAGMA table_info(' + FTableName + ')', [SQLITE_PREPARE_NORMALIZE]);
  column := ASchema.Columns.FirstEntry;
  
  Result := True;
  for Row in Query.Run do
  begin
    // Check if has schema entry.
    if not column.HasValue then
    begin
      Result := False;
      Break;
    end;

    // Check column name.
    if Row.GetStringValue('name') <> column.Value.Column_Name then
    begin
      Result := False;
      Break;
    end;

    // Check column type.
    case Row.GetStringValue('type') of
      'INTEGER' : 
        begin
          if column.Value.Column_Type <> SQLITE_INTEGER then
          begin
            Result := False;
            Break;
          end;
        end;
      'REAL' : 
        begin
          if column.Value.Column_Type <> SQLITE_FLOAT then
          begin
            Result := False;
            Break;
          end;
        end;
      'TEXT' : 
        begin
          if column.Value.Column_Type <> SQLITE_TEXT then
          begin
            Result := False;
            Break;
          end;
        end;
      'BLOB' : 
        begin
          if column.Value.Column_Type <> SQLITE_BLOB then
          begin
            Result := False;
            Break;
          end;
        end;
    end;

    // Check primary key modifier.
    if (Row.GetIntegerValue('pk') = 0) and column.Value.Option_PrimaryKey then
    begin
      Result := False;
      Break;
    end;

    // Check not null modifier.
    if (Row.GetIntegerValue('notnull') = 0) and column.Value.Option_NotNull then
    begin
      if not column.Value.Option_PrimaryKey then
      begin
        Result := False;
        Break;
      end;
    end;

    column := column.Next;
  end;
end;

function TSQLite3Table.Exists : Boolean;
var 
  Query : TSQLite3Select;
  Row : TSQLite3ResultRow;
begin
  Query := TSQLite3Select.Create(FErrorsStack, FDBHandle, 'sqlite_master');
  Row := Query.Field('count(*)').Where('type', 'table')
    .Where('name', FTableName)
    .Get
    .FirstRow
    .Row;

  Result := (Row.GetIntegerValue(0) > 0);
end;

function TSQLite3Table.HasColumn (AColumnName : String) : Boolean;
var
  Query : TSQLite3Query;
  Row : TSQLite3ResultRow;
begin
  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, 
    'PRAGMA table_info(' + FTableName + ');', [SQLITE_PREPARE_NORMALIZE]);
  
  Result := False;
  for Row in Query.Run do
  begin
    if Row.GetStringValue('name') = AColumnName then
    begin  
      Result := True;
      Break;
    end;
  end; 
end;

procedure TSQLite3Table.DropTable (AIfExists : Boolean);
var
  SQL : String;
  Query : TSQLite3Query;
begin
  SQL := 'DROP TABLE ';
  
  if AIfExists then
    SQL := SQL + ' IF EXISTS ';

  SQL := SQL + FTableName + ';';
  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);
  FreeAndNil(Query);
end;

procedure TSQLite3Table.Drop;
begin
  DropTable(False);
end;

procedure TSQLite3Table.DropIfExists;
begin
  DropTable(True);
end;

procedure TSQLite3Table.Rename (ANewName : String);
var
  SQL : String;
  Query : TSQLite3Query;
begin
  SQL := 'ALTER TABLE ' + FTableName + ' RENAME TO ' + ANewName + ';';
  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);
  FreeAndNil(Query);
end;

function TSQLite3Table.Select : TSQLite3Select;
begin
  Result := TSQLite3Select.Create(FErrorsStack, FDBHandle, FTableName);
end;

function TSQLite3Table.Insert : TSQLite3Insert;
begin
  Result := TSQLite3Insert.Create(FErrorsStack, FDBHandle, FTableName);
end;

function TSQLite3Table.Update : TSQLite3Update;
begin
  Result := TSQLite3Update.Create(FErrorsStack, FDBHandle, FTableName);
end;

function TSQLite3Table.Delete : TSQLite3Delete;
begin
  Result := TSQLite3Delete.Create(FErrorsStack, FDBHandle, FTableName);
end;

end.
