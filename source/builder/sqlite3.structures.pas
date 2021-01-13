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
unit sqlite3.structures;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, container.list, container.memorybuffer, utils.functor, 
  sqlite3.result_row;

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
        Value_BlobBuffer : TMemoryBuffer;
      end;

      TMemoryBuffersList = class
        ({$IFDEF FPC}specialize{$ENDIF} TList<TMemoryBuffer,
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<TMemoryBuffer>>);

      { Values list. }
      PValuesList = ^TValuesList;
      TValuesList = class
        ({$IFDEF FPC}specialize{$ENDIF} TList<TValueItem,
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<TValueItem>>);

      TMultipleValuesList = {$IFDEF FPC}type specialize{$ENDIF} 
        TList<TSQLite3Structures.TValuesList, 
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<
        TSQLite3Structures.TValuesList>>;

      { Select field item. }  
      TSelectFieldItem = record
        Column_Name : String;
        Column_AliasName : String;    
      end;

      { Select fields list. }  
      TSelectFieldsList = class
        ({$IFDEF FPC}specialize{$ENDIF} TList<TSelectFieldItem,
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<TSelectFieldItem>>);

      { Where clause experssion. }  
      TWhereComparisonOperator = (
        COMPARISON_EQUAL,               { =   }
        COMPARISON_NOT_EQUAL,           { <>  }
        COMPARISON_LESS,                { <   }
        COMPARISON_GREATER,             { >   }
        COMPARISON_LESS_OR_EQUAL,       { <=  }
        COMPARISON_GREATER_OR_EQUAL,    { >=  }
        COMPARISON_NOT                  { IS NOT }    
      );  

      { Where clause type. }
      TWhereFieldType = (
        WHERE_AND,
        WHERE_OR
      );

      { Where field item. }
      TWhereFieldItem = record
        Comparison_Type : TWhereFieldType;
        Comparison_ColumnName : String;
        Comparison : TWhereComparisonOperator;
        Comparison_Value : TValueItem;
      end;

      { Where filds list. }
      TWhereFieldsList = class
        ({$IFDEF FPC}specialize{$ENDIF} TList<TWhereFieldItem,
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<TWhereFieldItem>>);

      { Update list value. }
      TUpdateItem = record
        Column_Name : String;
        Value : TValueItem;
      end;

      { Updates list. }
      TUpdatesFieldsList = class
        ({$IFDEF FPC}specialize{$ENDIF} TList<TUpdateItem,
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<TUpdateItem>>);

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

      { Joins list. }
      TJoinsList = class
        ({$IFDEF FPC}specialize{$ENDIF} TList<TJoinItem,
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<TJoinItem>>);

      { Order by type. }
      TOrderByType = (
        ORDER_ASC,
        ORDER_DESC
      );

      { Order by item. }
      TOrderByItem = record
        Column_Name : String;
        Order_Type : TOrderByType;
      end;

      { Order by list. }
      TOrderByList = class
        ({$IFDEF FPC}specialize{$ENDIF} TList<TOrderByItem,
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<TOrderByItem>>);

      { Limit item clause. }
      TLimitItem = record
        Limit_Item : Boolean;
        Limit_Value : Cardinal;
        Offset_Item : Boolean;
        Offset_Value : Cardinal;
      end;

      { Group by list. }
      TGroupByList = class
        ({$IFDEF FPC}specialize{$ENDIF} TList<String, 
        {$IFDEF FPC}specialize{$ENDIF} TUnsortableFunctor<String>>);
  end;

implementation

end.
