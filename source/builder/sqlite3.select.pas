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
  SysUtils, libpassqlite, sqlite3.errors_stack, sqlite3.query, sqlite3.result,
  sqlite3.structures, sqlite3.where;

type
  TSQLite3Select = class
  public
    type
      TWhereComparisonOperator = TSQLite3Structures.TWhereComparisonOperator;
      TJoinType = TSQLite3Structures.TJoinType;
      TOrderByType = TSQLite3Structures.TOrderByType;
  public
    constructor Create (AErrorsStack : PSQL3LiteErrorsStack; ADBHandle :
      ppsqlite3; ATableName : String);
    destructor Destroy; override;

    { Add select field to list. }
    function All : TSQLite3Select;
    function Field (AColumnName : String) : TSQLite3Select; overload;
    function Field (AColumnName, AColumnAlias : String) : TSQLite3Select;
      overload;

    { Set distinct modifier. }
    function Distinct : TSQLite3Select;

    { Add where clause. }
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Select; overload;
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Select; overload;
    function Where (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Select; overload;
    function Where (AColumnName : String; AValue : String) : TSQLite3Select; 
      overload;
    function Where (AColumnName : String; AValue : Integer) : TSQLite3Select; 
      overload;
    function Where (AColumnName : String; AValue : Double) : TSQLite3Select; 
      overload;
    function WhereNull (AColumnName : String) : TSQLite3Select;
    function WhereNotNull (AColumnName : String) : TSQLite3Select;

    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Select; overload;
    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Select; overload;
    function AndWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Select; overload;
    function AndWhere (AColumnName : String; AValue : String) : TSQLite3Select; 
      overload;
    function AndWhere (AColumnName : String; AValue : Integer) : TSQLite3Select; 
      overload;
    function AndWhere (AColumnName : String; AValue : Double) : TSQLite3Select; 
      overload;
    function AndWhereNull (AColumnName : String) : TSQLite3Select;
    function AndWhereNotNull (AColumnName : String) : TSQLite3Select;

    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : String) : TSQLite3Select; overload;
    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Integer) : TSQLite3Select; overload;
    function OrWhere (AColumnName : String; AComparison : 
      TWhereComparisonOperator; AValue : Double) : TSQLite3Select; overload;
    function OrWhere (AColumnName : String; AValue : String) : TSQLite3Select; 
      overload;
    function OrWhere (AColumnName : String; AValue : Integer) : TSQLite3Select; 
      overload;
    function OrWhere (AColumnName : String; AValue : Double) : TSQLite3Select; 
      overload;
    function OrWhereNull (AColumnName : String) : TSQLite3Select;
    function OrWhereNotNull (AColumnName : String) : TSQLite3Select;

    { Join clause. }
    function Join (ATableName : String; AJoinType : TJoinType; AColumnName : 
      String; ACurrentTableColumn : String) : TSQLite3Select;
    function InnerJoin (ATableName : String; AColumnName : String; 
      ACurrentTableColumn : String) : TSQLite3Select; 
    function LeftJoin (ATableName : String; AColumnName : String; 
      ACurrentTableColumn : String) : TSQLite3Select; 

    { Order by clause. }
    function OrderBy (AColumnName : String; AOrderBy : TOrderByType) :
      TSQLite3Select;

    { Group by clause. }
    function GroupBy (AColumnName : String) : TSQLite3Select;

    { Set limit clause. }
    function Limit (ACount : Cardinal) : TSQLite3Select;
    function Offset (ACount : Cardinal) : TSQLite3Select;

    { Get result. }
    function Get : TSQLite3Result;
  private
    function PrepareJoinQuery : String;
    function PrepareOrderByQuery : String;
    function PrepareGroupByQuery : String;
  private
    FErrorsStack : PSQL3LiteErrorsStack;
    FDBHandle : ppsqlite3;
    FTableName : String;
    FDistinct : Boolean;
    FSelectFieldsList : TSQLite3Structures.TSelectFieldsList;
    FWhereFragment : TSQLite3Where;
    FJoinsList : TSQLite3Structures.TJoinsList;
    FOrderByList : TSQLite3Structures.TOrderByList;
    FLimit : TSQLite3Structures.TLimitItem;
    FGroupByList : TSQLite3Structures.TGroupByList;
  end;

implementation

{ TSQLite3Select }

constructor TSQLite3Select.Create (AErrorsStack : PSQL3LiteErrorsStack; 
  ADBHandle : ppsqlite3; ATableName : String);
begin
  FErrorsStack := AErrorsStack;
  FDBHandle := ADBHandle;
  FTableName := ATableName;
  FDistinct := False;
  FSelectFieldsList := TSQLite3Structures.TSelectFieldsList.Create;
  FWhereFragment := TSQLite3Where.Create;
  FJoinsList := TSQLite3Structures.TJoinsList.Create;
  FOrderByList := TSQLite3Structures.TOrderByList.Create;
  FLimit.Limit_Item := False;
  FLimit.Offset_Item := False;
  FGroupByList := TSQLite3Structures.TGroupByList.Create;
end;

destructor TSQLite3Select.Destroy;
begin
  FreeAndNil(FSelectFieldsList);
  FreeAndNil(FWhereFragment);
  FreeAndNil(FJoinsList);
  FreeAndNil(FOrderByList);
  FreeAndNil(FGroupByList);
  inherited Destroy;
end;

function TSQLite3Select.All : TSQLite3Select;
var
  item : TSQLite3Structures.TSelectFieldItem;
begin
  item.Column_Name := '*';
  item.Column_AliasName := '';
  FSelectFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Select.Field (AColumnName : String) : TSQLite3Select;
var
  item : TSQLite3Structures.TSelectFieldItem;
begin
  item.Column_Name := AColumnName;
  item.Column_AliasName := '';
  FSelectFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Select.Field (AColumnName, AColumnAlias : String) : 
  TSQLite3Select;
var
  item : TSQLite3Structures.TSelectFieldItem;
begin
  item.Column_Name := AColumnName;
  item.Column_AliasName := AColumnAlias;
  FSelectFieldsList.Append(item);
  Result := Self;
end;

function TSQLite3Select.Distinct : TSQLite3Select;
begin
  FDistinct := True;
  Result := Self;
end;

function TSQLite3Select.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AValue : String) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AValue : Integer) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.Where (AColumnName : String; AValue : Double) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.WhereNull (AColumnName : String) : TSQLite3Select;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Select.WhereNotNull (AColumnName : String) : TSQLite3Select;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Select.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.AndWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.AndWhere (AColumnName : String; AValue : String) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.AndWhere (AColumnName : String; AValue : Integer) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.AndWhere (AColumnName : String; AValue : Double) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_AND, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.AndWhereNull (AColumnName : String) : TSQLite3Select;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Select.AndWhereNotNull (AColumnName : String) : TSQLite3Select;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_AND, AColumnName);
  Result := Self;  
end;

function TSQLite3Select.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : String) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Integer) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.OrWhere (AColumnName : String; AComparison :
  TWhereComparisonOperator; AValue : Double) : TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, 
    AColumnName, AComparison, AValue);
  Result := Self;  
end;

function TSQLite3Select.OrWhere (AColumnName : String; AValue : String) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.OrWhere (AColumnName : String; AValue : Integer) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.OrWhere (AColumnName : String; AValue : Double) : 
  TSQLite3Select;
begin
  FWhereFragment.Where(TSQLite3Where.TWhereType.WHERE_OR, 
    AColumnName, TSQLite3Where.TWhereComparisonOperator.COMPARISON_EQUAL, 
    AValue);
  Result := Self;  
end;

function TSQLite3Select.OrWhereNull (AColumnName : String) : TSQLite3Select;
begin
  FWhereFragment.WhereNull(TSQLite3Where.TWhereType.WHERE_OR, AColumnName);
  Result := Self;  
end;

function TSQLite3Select.OrWhereNotNull (AColumnName : String) : TSQLite3Select;
begin
  FWhereFragment.WhereNotNull(TSQLite3Where.TWhereType.WHERE_OR, AColumnName);
  Result := Self;  
end;

function TSQLite3Select.Join (ATableName : String; AJoinType : TJoinType;
  AColumnName : String; ACurrentTableColumn : String) : TSQLite3Select;
var
  item : TSQLite3Structures.TJoinItem;
begin
  item.Table_Name := ATableName;
  item.Column_Name := AColumnName;
  item.Join_Type := AJoinType;
  item.CurrColumn_Name := ACurrentTableColumn;

  FJoinsList.Append(item);
  Result := Self;
end;

function TSQLite3Select.InnerJoin(ATableName : String; AColumnName : String;
  ACurrentTableColumn : String) : TSQLite3Select;
begin
  Result := Join(ATableName, JOIN_INNER, AColumnName, ACurrentTableColumn);
end;

function TSQLite3Select.LeftJoin(ATableName : String; AColumnName : String;
  ACurrentTableColumn : String) : TSQLite3Select;
begin
  Result := Join(ATableName, JOIN_OUTER_LEFT, AColumnName, ACurrentTableColumn);
end;

function TSQLite3Select.OrderBy (AColumnName : String; AOrderBy : TOrderByType)
 : TSQLite3Select;
var
  item : TSQLite3Structures.TOrderByItem;
begin
  item.Column_Name := AColumnName;
  item.Order_Type := AOrderBy;

  FOrderByList.Append(item);
  Result := Self;
end;

function TSQLite3Select.GroupBy (AColumnName : String) : TSQLite3Select;
begin
  if AColumnName <> '' then
  begin
    FGroupByList.Append(AColumnName);
  end;

  Result := Self;
end;

function TSQLite3Select.Limit (ACount : Cardinal) : TSQLite3Select;
begin
  FLimit.Limit_Item := True;
  FLimit.Limit_Value := ACount;
  Result := Self;
end;

function TSQLite3Select.Offset (ACount : Cardinal) : TSQLite3Select;
begin
  FLimit.Offset_Item := True;
  FLimit.Offset_Value := ACount;
  Result := Self;
end;

function TSQLite3Select.PrepareJoinQuery : String;
var
  SQL : String;
  join_item : TSQLite3Structures.TJoinItem;
begin
  if not FJoinsList.FirstEntry.HasValue then
    Exit('');

  SQL := '';
  for join_item in FJoinsList do
  begin
    { Add join type. }
    case join_item.Join_Type of
      JOIN_INNER : 
        SQL := SQL + ' INNER JOIN ';
      JOIN_OUTER_LEFT :
        SQL := SQL + ' LEFT OUTER JOIN ';
      JOIN_CROSS :
        SQL := SQL + ' CROSS JOIN ';
    end;

    SQL := SQL + join_item.Table_Name + ' ON ' + join_item.Table_Name + '.' +
      join_item.Column_Name + ' = ' + FTableName + '.' + 
      join_item.CurrColumn_Name;
  end;

  Result := SQL;
end;

function TSQLite3Select.PrepareOrderByQuery : String;
var
  SQL : String;
  order_item : TSQLite3Structures.TOrderByItem;
  i : Integer;
begin
  if not FOrderByList.FirstEntry.HasValue then
    Exit('');

  SQL := ' ORDER BY ';

  i := 0;
  for order_item in FOrderByList do
  begin
    if i > 0 then
      SQL := SQL + ', ';

    SQL := SQL + order_item.Column_Name;

    case order_item.Order_Type of
      ORDER_ASC : SQL := SQL + ' ASC';
      ORDER_DESC : SQL := SQL + ' DESC';
    end;

    Inc(i);
  end;

  Result := SQL;
end;

function TSQLite3Select.PrepareGroupByQuery : String;
var
  SQL : String;
  Column : String;
  i : Integer;
begin
  if not FGroupByList.FirstEntry.HasValue then
    Exit('');

  SQL := ' GROUP BY ';

  i := 0;
  for Column in FGroupByList do
  begin
    if i > 0 then
      SQL := SQL + ', ';

    SQL := SQL + Column;
    Inc(i);
  end;

  Result := SQL;
end;

function TSQLite3Select.Get : TSQLite3Result;
var
  SQL : String;
  select_elem : TSQLite3Structures.TSelectFieldItem;
  i : Integer;
  Query : TSQLite3Query;
begin
  if not FSelectFieldsList.FirstEntry.HasValue then
    Exit;

  i := 0;
  SQL := 'SELECT ';

  { Set distinct modifier. }
  if FDistinct then
    SQL := SQL + 'DISTINCT ';

  { Set selected fields. }
  for select_elem in FSelectFieldsList do
  begin
    { For every field. }
    if i > 0 then
      SQL := SQL + ', ';

    { Column name. }
    SQL := SQL + select_elem.Column_Name;

    { Column alias. }
    if select_elem.Column_AliasName <> '' then
      SQL := SQL + ' AS ' + select_elem.Column_AliasName;
    
    Inc(i);     
  end;
  
  SQL := SQL + ' FROM ' + FTableName;
  SQL := SQL + PrepareJoinQuery;
  SQL := SQL + FWhereFragment.GetQuery;
  SQL := SQL + PrepareGroupByQuery;
  SQL := SQL + PrepareOrderByQuery;
  

  { Set limit clause. }
  if FLimit.Limit_Item then
    SQL := SQL + ' LIMIT ?';

  if FLimit.Offset_Item then
    SQL := SQL + ' OFFSET ?';

  { Close SQL query. }
  SQL := SQL + ';';

  { Bind query data. }
  Query := TSQLite3Query.Create(FErrorsStack, FDBHandle, SQL,
    [SQLITE_PREPARE_NORMALIZE]);
  i := FWhereFragment.BindQueryData (Query, 1);
  
  if FLimit.Limit_Item then
  begin
    Query.Bind(i, FLimit.Limit_Value);
    Inc(i);
  end;

  if FLimit.Offset_Item then
  begin
    Query.Bind(i, FLimit.Offset_Value);
  end;

  { Run SQL query. }
  Result := Query.Run;  
end;

end.
