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
  libpassqlite, sqlite3.errors_stack, sqlite3.schema, sqlite3.query,
  sqlite3.result_row;

type
  TSQLite3Table = class
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle : 
      psqlite3);
    destructor Destroy; override;

    { Create new table. }
    function CreateTable (ATableName : String) : TSQLite3Schema;

    { Check if table exists. }
    function HasTable (ATableName : String) : Boolean;

    { Check if table has column. }
    function HasColumn (ATableName : String; AColumnName : String) : Boolean;

    { Delete table. }
    procedure DropTable (ATableName : String);

    { Rename table. }
    procedure RenameTable (AFromName, AToName : String);
  private
    { Create SQL query and run it. }
    procedure CreateAndRunSchemaQuery;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : psqlite3;
    FQuery : TSQLite3Query;

    FTableName : String;
    FSchema : TSQLite3Schema;
  end;

implementation

{ TSQLite3Builder }

constructor TSQLite3Table.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : psqlite3);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FSchema := TSQLite3Schema.Create;
end;

destructor TSQLite3Table.Destroy;
begin
  CreateAndRunSchemaQuery;
  inherited Destroy;
end;

procedure TSQLite3Table.CreateAndRunSchemaQuery;
var
  SQL : String;
  column : TSQLite3Schema.TColumnItem;
  i : Integer;
begin
  if not FSchema.Columns.FirstEntry.HasValue then
    Exit;

  SQL := 'CREATE TABLE ? (';
  for column in FSchema.Columns do
  begin
    case column.Column_Type of
      SQLITE_INTEGER : 
        begin
          { If it is a primary key. }
          if column.Option_PrimaryKey then
          begin
            SQL := SQL + '? INTEGER PRIMARY KEY,';
            continue;
          end;

          { Ignore all modificators. }
          SQL := SQL + '? INTEGER,';  
        end;
      SQLITE_FLOAT : 
        begin
          
        end;
      SQLITE_BLOB : 
        begin
          
        end;
      SQLITE_TEXT : 
        begin
          { Add text column. }
          SQL := SQL + '? TEXT';

          { Add modificators. }
          if column.Option_NotNull then
            SQL := SQL + ' NOT NULL';

          if column.Option_Unique then
            SQL := SQL + ' UNIQUE';

          { Add comma to the end. }
          SQL := SQL + ',';
        end;
    end;
  end;

  FQuery := TSQLite3Query.Create(FErrorsStack, FDBHandle, SQL, 
    [SQLITE_PREPARE_NORMALIZE]);
  
  i := 2;
  FQuery.Bind(1, FTableName);
  for column in FSchema.Columns do
  begin
    FQuery.Bind(i, column.Column_Name);
    Inc(i);
  end;

  FQuery.Run;
end;

function TSQLite3Table.CreateTable (ATableName : String) : TSQLite3Schema;
begin
  FTableName := ATableName;
  FSchema.Clear;
  Result := FSchema;
end;

function TSQLite3Table.HasTable (ATableName : String) : Boolean;
begin
  
end;

function TSQLite3Table.HasColumn (ATableName : String; AColumnName : String) :
  Boolean;
begin
  
end;

procedure TSQLite3Table.DropTable (ATableName : String);
begin
  
end;

procedure TSQLite3Table.RenameTable (AFromName, AToName : String);
begin
  
end;

end.
