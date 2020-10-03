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
  libpassqlite, sqlite3.errors_stack, sqlite3.schema, sqlite3.query;

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
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : psqlite3;
    FQuery : TSQLite3Query;
  end;

implementation

{ TSQLite3Builder }

constructor TSQLite3Table.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : psqlite3);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
end;

destructor TSQLite3Table.Destroy;
begin
  inherited Destroy;
end;

function TSQLite3Table.CreateTable (ATableName : String) : TSQLite3Schema;
begin
  
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