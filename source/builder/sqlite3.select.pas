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
unit sqlite3.select;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  libpassqlite, sqlite3.errors_stack, sqlite3.query, sqlite3.result,
  container.list, utils.functor;

type
  TSQLite3Select = class
  public
    type
      { Select field item. }  
      TSelectFieldItem = record
        Column_Name : String;
        Column_AliasName : String;    
      end;

      { Select item compare functior. }
      TSelectFieldItemCompareFunctor = class
        (specialize TBinaryFunctor<TSelectFieldItem, Integer>)
      public
        function Call (AValue1, AValue2 : TSelectFieldItem) : Integer; override;
      end;

      { Select fields list. }  
      TSelectFieldsList = class
        (specialize TList<TSelectFieldItem, TSelectFieldItemCompareFunctor>);

      { Where clause experssion. }  
      TWhereExpression = (
        EXPRESSION_EQUAL,               { =   }
        EXPRESSION_NOT_EUQAL,           { <>  }
        EXPRESSION_LESS,                { <   }
        EXPRESSION_GREATER,             { >   }
        EXPRESSION_LESS_OR_EQUAL,       { <=  }
        EXPRESSION_GREATER_OR_EQUAL     { >=  }
        EXPRESSION_NOT                  { NOT }    
      );  

      { Where field item. }
      TWhereFieldItem = record
        Column_Name : String;

        Expression : TWhereExpression;
      end;

      { Where item compare functor. }
      TWhereFieldItemCompareFunction = class
        (specialize TBinaryFunctor<TWhereFieldItem, Integer>)
      public
        function Call (AValue1, AValue2 : TWhereFieldItem) : Integer; override;
      end;

      { Where filds list. }
      TWhereFieldsList = class
        (specialize TList<TWhereFieldItem, TWhereFieldItemCompareFunction>);
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle :
      ppsqlite3; ATableName : String);
    destructor Destroy; override;

    { Add select field to list. }
    function All : TSQLite3Select;
    function Field (AColumnName : String) : TSQLite3Select; overload;
    function Field (AColumnName, AColumnAlias : String) : TSQLite3Select;
      overload;

    { Add where clause. }

  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FQuery : TSQLite3Query;
    FSelectFieldsList : TSelectFieldsList;
    FWhereFieldsList : TWhereFieldsList;
  end;

implementation

{ TSQLite3Select.TSelectFieldItemCompareFunctor }

function TSQLite3Select.TSelectFieldItemCompareFunctor.Call (AValue1, AValue2 :
  TSelectFieldItem) : Integer;
begin
  if AValue1.Column_Name < AValue2.Column_Name then
    Result := -1
  else if AValue2.Column_Name < AValue1.Column_Name then
    Result := 1
  else
    Result := 0;
end;

{ TSQLite3Select.TWhereFieldItemCompareFunction }

function TSQLite3Select.TWhereFieldItemCompareFunction.Call (AValue1, AValue2 :
  TWhereFieldItem) : Integer;
begin
  if AValue1.Column_Name < AValue2.Column_Name then
    Result := -1
  else if AValue2.Column_Name < AValue1.Column_Name then
    Result := 1
  else
    Result := 0;
end;

{ TSQLite3Select }

constructor TSQLite3Select.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FSelectFieldsList := TSelectFieldsList.Create;
  FWhereFieldsList := TWhereFieldsList.Create;
end;

destructor TSQLite3Select.Destroy;
begin
  FreeAndNil(FSelectFieldsList);
  FreeAndNil(FWhereFieldsList);
  inherited Destroy;
end;

function TSQLite3Select.All : TSQLite3Select;
var
  field : TSelectFieldItem;
begin
  field.Column_Name := '*';
  field.Column_AliasName := '';
  FSelectFieldsList.Append(field);
  Result := Self;
end;

function TSQLite3Select.Field (AColumnName : String) : TSQLite3Select;
var
  field : TSelectFieldItem;
begin
  field.Column_Name := AColumnName;
  field.Column_AliasName := '';
  FSelectFieldsList.Append(field);
  Result := Self;
end;

function TSQLite3Select.Field (AColumnName, AColumnAlias : String) : 
  TSQLite3Select;
var
  field : TSelectFieldItem;
begin
  field.Column_Name := AColumnName;
  field.Column_AliasName := AColumnAlias;
  FSelectFieldsList.Append(field);
  Result := Self;
end;



end.
