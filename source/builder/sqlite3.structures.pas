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
unit sqlite3.structures;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, container.list, utils.functor, sqlite3.result_row;

type
  TSQLite3Structures = class
  public
    type
      { Insert list value. }
      TValueItem = record
        Column_Name : String;

        Value_Type : TDataType;
        Value_Integer : Integer;
        Value_Float : Double;
        Value_Text : String;
        Value_Blob : PByte;
      end;

      { Value item compare functor. }
      TValueItemCompareFunctor = class
        (specialize TBinaryFunctor<TValueItem, Integer>)
      public
        function Call (AValue1, AValue2 : TValueItem) : Integer; override;
      end;

      { Values list. }
      PValuesList = ^TValuesList;
      TValuesList = class
        (specialize TList<TValueItem, TValueItemCompareFunctor>);

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
      TWhereComparisonOperator = (
        COMPARISON_EQUAL,               { =   }
        COMPARISON_NOT_EQUAL,           { <>  }
        COMPARISON_LESS,                { <   }
        COMPARISON_GREATER,             { >   }
        COMPARISON_LESS_OR_EQUAL,       { <=  }
        COMPARISON_GREATER_OR_EQUAL,    { >=  }
        COMPARISON_NOT                  { NOT }    
      );  

      { Where field item. }
      TWhereFieldItem = record
        Comparison_ColumnName : String;
        Comparison : TWhereComparisonOperator;
        Comparison_Value : TValueItem;
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

      { Update list value. }
      TUpdateItem = record
        Column_Name : String;
        Value : TValueItem;
      end;

      { Update item compare functor. }
      TUpdateItemCompareFunctor = class
        (specialize TBinaryFunctor<TUpdateItem, Integer>)
      public
        function Call (AValue1, AValue2 : TUpdateItem) : Integer; override;
      end;

      { Updates list. }
      TUpdatesFieldsList = class
        (specialize TList<TUpdateItem, TUpdateItemCompareFunctor>);

      { Joins type. }
      TJoinType = (
        JOIN_INNER,
        JOIN_OUTER_LEFT,
        JOIN_CROSS
      );

      { Join list value. }
      TJoinItem = record
        Table_Name : String;
        Column_Name : String;
        Join_Type : TJoinType;
        CurrColumn_Name : String;
      end;

      { Join item compare functor. }
      TJoinItemCompareFunctor = class
        (specialize TBinaryFunctor<TJoinItem, Integer>)
      public
        function Call (AValue1, AValue2 : TJoinItem) : Integer; override;
      end;

      { Updates list. }
      TJoinsList = class
        (specialize TList<TJoinItem, TJoinItemCompareFunctor>);

      { Limit item clause. }
      TLimitItem = record
        Limit_Item : Boolean;
        Limit_Value : Cardinal;
        Offset_Item : Boolean;
        Offset_Value : Cardinal;
      end;
  end;

implementation

{ TSQLite3Structures.TValueItemCompareFunctor }

function TSQLite3Structures.TValueItemCompareFunctor.Call (AValue1, AValue2 :
  TValueItem) : Integer;
begin
  if AValue1.Column_Name < AValue2.Column_Name then
    Result := -1
  else if AValue2.Column_Name < AValue1.Column_Name then
    Result := 1
  else
    Result := 0;
end;

{ TSQLite3Structures.TSelectFieldItemCompareFunctor }

function TSQLite3Structures.TSelectFieldItemCompareFunctor.Call (AValue1, 
  AValue2 : TSelectFieldItem) : Integer;
begin
  if AValue1.Column_Name < AValue2.Column_Name then
    Result := -1
  else if AValue2.Column_Name < AValue1.Column_Name then
    Result := 1
  else
    Result := 0;
end;

{ TSQLite3Structures.TWhereFieldItemCompareFunction }

function TSQLite3Structures.TWhereFieldItemCompareFunction.Call (AValue1, 
  AValue2 : TWhereFieldItem) : Integer;
begin
  if AValue1.Comparison_ColumnName < AValue2.Comparison_ColumnName then
    Result := -1
  else if AValue2.Comparison_ColumnName < AValue1.Comparison_ColumnName then
    Result := 1
  else
    Result := 0;
end;

{ TSQLite3Structures.TUpdateItemCompareFunctor }

function TSQLite3Structures.TUpdateItemCompareFunctor.Call (AValue1, 
  AValue2 : TUpdateItem) : Integer;
begin
  if AValue1.Column_Name < AValue2.Column_Name then
    Result := -1
  else if AValue2.Column_Name < AValue1.Column_Name then
    Result := 1
  else
    Result := 0;
end;

{ TSQLite3Structures.TJoinItemCompareFunctor }

function TSQLite3Structures.TJoinItemCompareFunctor.Call (AValue1, 
  AValue2 : TJoinItem) : Integer;
begin
  if AValue1.Column_Name < AValue2.Column_Name then
    Result := -1
  else if AValue2.Column_Name < AValue1.Column_Name then
    Result := 1
  else
    Result := 0;
end;

end.
