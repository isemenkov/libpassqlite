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
unit sqlite3.result; 

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  libpassqlite, sqlite3.errors_stack, sqlite3.result_row;

type
  { SQLite3 database query result collection. }
  TSQLite3Result = class
  public
    type
      { TSQLite3Result row iterator. }
      TRowIterator = class
      public
        constructor Create (AErrorsStack : PSQL3LiteErrorsStack; 
          AStatementHandle : psqlite3_stmt; AResCode : Integer);

        { Return true if iterator has correct row. }
        function HasRow : Boolean;

        { Retrieve the next entry in a TSQLite3Result. }
        function NextRow : TRowIterator;

        { Return True if we can move to next row. }
        function MoveNext : Boolean;

        { Return enumerator for in operator. }
        function GetEnumerator : TRowIterator;
      protected
        { Return current item iterator and move it to next row. }
        function GetCurrent : TSQLite3ResultRow;
      public
        { Result row. }
        property Row : TSQLite3ResultRow read GetCurrent;

        { Current TSQLite3Result row item. }
        property Current : TSQLite3ResultRow read GetCurrent;
      private
        FErrorsStack : PSQL3LiteErrorsStack;
        FStatementHandle : psqlite3_stmt;
        FResCode : Integer;
      end;
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; AStatementHandle : 
        psqlite3_stmt; AResCode : Integer);
    destructor Destroy; override;

    { Retrive the first row in a result row collection. }
    function FirstRow : TRowIterator;

    { Return enumerator for in operator. }
    function GetEnumerator : TRowIterator;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FStatementHandle : psqlite3_stmt;
    FResCode : Integer;
  end;

implementation

{ TSQLite3Result.TRowIterator }

constructor TSQLite3Result.TRowIterator.Create (AErrorsStack : 
  PSQL3LiteErrorsStack; AStatementHandle : psqlite3_stmt; AResCode : Integer);
begin
  FErrorsStack := AErrorsStack;
  FStatementHandle := AStatementHandle;
  FResCode := AResCode;
end;

function TSQLite3Result.TRowIterator.HasRow : Boolean;
begin
  Result := (FResCode = SQLITE_ROW);
end;

function TSQLite3Result.TRowIterator.NextRow : TSQLite3Result.TRowIterator;
begin
  Result := TSQLite3Result.TRowIterator.Create(FErrorsStack, FStatementHandle,
    sqlite3_step(FStatementHandle));
end;

function TSQLite3Result.TRowIterator.MoveNext : Boolean;
var
  res_code : Integer;
begin
  res_code := sqlite3_step(FStatementHandle);
  FErrorsStack^.Push(res_code);
  Result := (res_code = SQLITE_ROW); 
end;

function TSQLite3Result.TRowIterator.GetEnumerator : 
  TSQLite3Result.TRowIterator;
begin
  Result := Self;
end;

function TSQLite3Result.TRowIterator.GetCurrent : TSQLite3ResultRow;
begin
  Result := TSQLite3ResultRow.Create(FErrorsStack, FStatementHandle);
end;

{ TSQLite3Result }

constructor TSQLite3Result.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  AStatementHandle : psqlite3_stmt; AResCode : Integer);
begin
  FErrorsStack := AErrorsStack;
  FStatementHandle := AStatementHandle;   
  FResCode := AResCode; 
end;

destructor TSQLite3Result.Destroy;
begin
  inherited Destroy;
end;

function TSQLite3Result.FirstRow : TSQLite3Result.TRowIterator;
begin
  Result := TSQLite3Result.TRowIterator.Create(FErrorsStack, FStatementHandle,
    sqlite3_step(FStatementHandle));
end;

function TSQLite3Result.GetEnumerator : TSQLite3Result.TRowIterator;
begin
  Result := TSQLite3Result.TRowIterator.Create(FErrorsStack, FStatementHandle,
    sqlite3_step(FStatementHandle));
end;

end.
