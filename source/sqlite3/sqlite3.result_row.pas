(******************************************************************************)
(*                                libPasSQLite                                *)
(*               object pascal wrapper around SQLite library                  *)
(*                                                                            *)
(* Copyright (c) 2020 - 2021                                Ivan Semenkov     *)
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
unit sqlite3.result_row; 

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpassqlite, sqlite3.errors_stack, container.sortedarray,
  utils.pair, utils.functor, utils.api.cstring;

type
  { Fundamental database column datatypes. }
  TDataType = (
    SQLITE_INTEGER                       = Longint(libpassqlite.SQLITE_INTEGER),
    SQLITE_FLOAT                         = Longint(libpassqlite.SQLITE_FLOAT),
    SQLITE_BLOB                          = Longint(libpassqlite.SQLITE_BLOB),
    SQLITE_NULL                          = Longint(libpassqlite.SQLITE_NULL),
    SQLITE_TEXT                          = Longint(libpassqlite.SQLITE3_TEXT)
  {%H-});

  { SQLite3 database query result collection row. }
  TSQLite3ResultRow = class
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; AStatementHandle :
      psqlite3_stmt);
    destructor Destroy; override;

    { Return the number of columns in the result set. }
    function ColumnCount : Integer;

    { Return the name assigned to a particular column in the result set. }
    function ColumnName (AIndex : Integer) : String;

    { Returns the datatype for the initial data type of the result column. }
    function GetColumnType (AIndex : Integer) : TDataType;

    { Return information about a single column of the current result row of a 
      query. }
    function GetDoubleValue (AColumnIndex : Integer) : Double; overload;
    function GetIntegerValue (AColumnIndex : Integer) : Integer; overload;
    function GetInt64Value (AColumnIndex : Integer) : Int64; overload;
    function GetStringValue (AColumnIndex : Integer) : String; overload;

    { Return information about a single column of the current result row of a 
      query by column name. }
    function GetDoubleValue (AColumnName : String) : Double; overload;
    function GetIntegerValue (AColumnName : String) : Integer; overload;
    function GetInt64Value (AColumnName : String) : Int64; overload;
    function GetStringValue (AColumnName : String) : String; overload;

    { Check if column values is null. }
    function IsNull (AColumnIndex : Integer) : Boolean; overload;
    function IsNull (AColumnName : String) : Boolean; overload;
  private
    type
      TColumnData = {$IFDEF FPC}type specialize{$ENDIF} TPair<String, Integer>;
      TColumnsList = {$IFDEF FPC}type specialize{$ENDIF} 
        TSortedArray<TColumnData,
        {$IFDEF FPC}specialize{$ENDIF}TPairKeyCompareFunctorString<Integer>>;

    function GetColumnIndex (AColumnName : String) : Integer;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FStatementHandle : psqlite3_stmt;
    FColumnsList : TColumnsList; 
  end;

implementation

{ TSQLite3ResultRow }

constructor TSQLite3ResultRow.Create(AErrorsStack : PSQL3LiteErrorsStack;
  AStatementHandle : psqlite3_stmt);
begin
  FErrorsStack := AErrorsStack;
  FStatementHandle := AStatementHandle;
  FColumnsList := TColumnsList.Create;
end; 

destructor TSQLite3ResultRow.Destroy;
begin
  FreeAndNil(FColumnsList);
  inherited Destroy;
end;

function TSQLite3ResultRow.ColumnCount : Integer;
begin
  Result := sqlite3_column_count(FStatementHandle);
end;

function TSQLite3ResultRow.ColumnName (AIndex : Integer) : String;
begin
  Result := String(sqlite3_column_name(FStatementHandle, AIndex));
end;

function TSQLite3ResultRow.GetColumnType (AIndex : Integer) : TDataType;
begin
  Result := TDataType(sqlite3_column_type(FStatementHandle, AIndex));
end;

function TSQLite3ResultRow.GetDoubleValue (AColumnIndex : Integer) : Double;
begin
  Result := sqlite3_column_double(FStatementHandle, AColumnIndex);
end;

function TSQLite3ResultRow.GetDoubleValue (AColumnName : String) : Double;
begin
  Result := sqlite3_column_double(FStatementHandle, 
    GetColumnIndex(AColumnName));
end; 

function TSQLite3ResultRow.GetIntegerValue (AColumnIndex : Integer) : Integer;
begin
  Result := sqlite3_column_int(FStatementHandle, AColumnIndex);
end;

function TSQLite3ResultRow.GetIntegerValue (AColumnName : String) : Integer;
begin
  Result := sqlite3_column_int(FStatementHandle, GetColumnIndex(AColumnName));
end;

function TSQLite3ResultRow.GetInt64Value (AColumnIndex : Integer) : Int64;
begin
  Result := sqlite3_column_int64(FStatementHandle, AColumnIndex);
end;

function TSQLite3ResultRow.GetInt64Value (AColumnName : String) : Int64;
begin
  Result := sqlite3_column_int64(FStatementHandle, GetColumnIndex(AColumnName));
end;

function TSQLite3ResultRow.GetStringValue (AColumnIndex : Integer) : String;
begin
  Result := API.CString.Create(PAnsiChar(sqlite3_column_text(FStatementHandle,
    AColumnIndex))).ToString;
end;

function TSQLite3ResultRow.GetStringValue (AColumnName : String) : String;
begin
  Result := API.CString.Create(PAnsiChar(sqlite3_column_text(FStatementHandle,
     GetColumnIndex(AColumnName)))).ToString;
end;

function TSQLite3ResultRow.IsNull (AColumnIndex : Integer) : Boolean;
begin
  Result := (GetColumnType(AColumnIndex) = SQLITE_NULL);
end;

function TSQLite3ResultRow.IsNull (AColumnName : String) : Boolean;
begin
  Result := (GetColumnType(GetColumnIndex(AColumnName)) = SQLITE_NULL);
end;

function TSQLite3ResultRow.GetColumnIndex (AColumnName : String) : Integer;
var
  i : Integer;
begin
  { Cache column names. }
  if FColumnsList.Length = 0 then
  begin
    for i := 0 to ColumnCount - 1 do
      FColumnsList.Append(TColumnData.Create(ColumnName(i), i));
  end;

  { Get column name from cache. }
  Result := FColumnsList.Value[FColumnsList.IndexOf(
    TColumnData.Create(AColumnName, 0))].Second;
end;

end.
