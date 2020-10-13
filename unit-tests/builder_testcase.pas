unit builder_testcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, sqlite3.builder, sqlite3.schema,
  sqlite3.result_row, sqlite3.select, container.memorybuffer;

type
  { TSQLite3BuilderTestCase }
  TSQLite3BuilderTestCase = class(TTestCase)
  published
    procedure Test_SQLite3Builder_CreateNewEmpty;
    procedure Test_SQLite3Builder_CreateNewSchema;
    procedure Test_SQLite3Builder_InsertData;
    procedure Test_SQLite3Builder_InsertMultipleData;
    procedure Test_SQLite3Builder_CheckTableSchema;
    procedure Test_SQLite3Builder_SelectLimitOffset;
    procedure Test_SQLite3Builder_SelectWhere;
    procedure Test_SQLite3Builder_SelectOrderBy;
    procedure Test_SQLite3Builder_Join;
    procedure Test_SQLite3Builder_Blob;
  end;

implementation

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_CreateNewEmpty;
var
  builder : TSQLite3Builder;
begin
  AssertTrue('Database file already exists', not FileExists('test.db'));
 
  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);

  AssertTrue('Database connection has errors', builder.Errors.Count = 0);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_CreateNewSchema;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
begin
  schema := TSQLite3Schema.Create;
  schema.Id('id').Text('txt').NotNull;

  AssertTrue('Database file already exists', not FileExists('test.db'));
 
  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);   

  AssertTrue('Database table not exists', builder.Table('test_table').Exists);
  AssertTrue('Database table not have id column', 
    builder.Table('test_table').HasColumn('id'));
  AssertTrue('Database table not have txt column', 
    builder.Table('test_table').HasColumn('txt'));

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_InsertData;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('int1').Integer('int2').Integer('int3').Text('txt');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Database table not exists', builder.Table('test_table').Exists);
  AssertTrue('Database table not have id column', 
    builder.Table('test_table').HasColumn('id'));
  AssertTrue('Database table not have int1 column', 
    builder.Table('test_table').HasColumn('int1'));
  AssertTrue('Database table not have int2 column', 
    builder.Table('test_table').HasColumn('int2'));
  AssertTrue('Database table not have int3 column', 
    builder.Table('test_table').HasColumn('int3'));
  AssertTrue('Database table not have txt column', 
    builder.Table('test_table').HasColumn('txt'));

  inserted_rows := 0;
  inserted_rows := builder.Table('test_table').Insert
    .Value('int1', 12)
    .Value('int2', 43)
    .Value('int3', -54)
    .Value('txt', 'string')
    .Get;

  AssertTrue('Database inserted row count is not correct', inserted_rows = 1);

  counter := 0;
  for row in builder.Table('test_table').Select.All.Get do
  begin
    AssertTrue('Selected row ''int1'' column value is not correct', 
      row.GetIntegerValue('int1') = 12);
    AssertTrue('Selected row ''int2'' column value is not correct', 
      row.GetIntegerValue('int2') = 43);
    AssertTrue('Selected row ''int3'' column value is not correct', 
      row.GetIntegerValue('int3') = -54);
    AssertTrue('Selected row ''txt'' column value is not correct', 
      row.GetStringValue('txt') = 'string');

    Inc(counter);
  end;  

  AssertTrue('Database selected rows count is not correct', counter = 1);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_InsertMultipleData;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('val_1').Float('val_2').Text('val_3');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema));

  inserted_rows := 0;
  inserted_rows := builder.Table('test_table').Insert
    .Column('val_1', SQLITE_INTEGER)
    .Column('val_2', SQLITE_FLOAT)
    .Column('val_3', SQLITE_TEXT)
    .Row
      .Value(12)
      .Value(3.14)
      .Value('some value')
    .Row
      .Value(54)
      .Value(6.54)
      .Value('string value')
    .Row
      .Value(-874)
      .Value(532.00)
      .Value('test value')
    .Get;

  AssertTrue('Database inserted rows count is not correct', inserted_rows = 3);

  counter := 0;
  for row in builder.Table('test_table').Select.All.Get do
  begin
    case counter of
      0 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 12);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 3.14, 0.01);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = 'some value');
      end;
      1 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 54);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 6.54, 0.01);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = 'string value');
      end;
      2 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = -874);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 532.00, 0.01);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = 'test value');
      end;
      3 : begin
        Fail('Impossible row.');
      end;
    end;
    Inc(counter);
  end;

  AssertTrue('Database selected rows count is not correct', counter = 3);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_CheckTableSchema;
var
  schema, schema2 : TSQLite3Schema;
  builder : TSQLite3Builder;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('int_val').Float('float_val').Text('text_val').NotNull;

  schema2 := TSQLite3Schema.Create;
  schema2.Id.Integer('int_val').Float('f_val').Text('text_val').NotNull;

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema));
  AssertTrue('Table ''test_table'' schema checked wrong',
    not builder.Table('test_table').CheckSchema(schema2));

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_SelectLimitOffset;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('some_value').Text('text_data');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema)); 

  AssertTrue('Inserted rows count not correct', 
    builder.Table('test_table').Insert
    .Value('some_value', 123)
    .Value('text_data', 'string value')
    .Get = 1);

  AssertTrue('Inserted rows count not correct',
    builder.Table('test_table').Insert
    .Value('some_value', 3431)
    .Value('text_data', 'another text value')
    .Get = 1);
  
  counter := 0;
  for row in builder.Table('test_table').Select.All.Limit(1).Get do
  begin
    AssertTrue('Selected row ''some_value'' column value is not correct',
      row.GetIntegerValue('some_value') = 123);
    AssertTrue('Selected row ''text_data'' column value is not correct',
      row.GetStringValue('text_data') = 'string value');

    Inc(counter);  
  end;

  AssertTrue('Database selected rows count is not correct', counter = 1);

  counter := 0;
  for row in builder.Table('test_table').Select.All.Limit(1).Offset(1).Get do
  begin
    AssertTrue('Selected row ''some_value'' column value is not correct',
      row.GetIntegerValue('some_value') = 3431);
    AssertTrue('Selected row ''text_data'' column value is not correct',
      row.GetStringValue('text_data') = 'another text value');

    Inc(counter);  
  end;

  AssertTrue('Database selected rows count is not correct', counter = 1);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_SelectWhere;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('val_1').Float('val_2').Text('val_3');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema));

  inserted_rows := 0;
  inserted_rows := builder.Table('test_table').Insert
    .Column('val_1', SQLITE_INTEGER)
    .Column('val_2', SQLITE_FLOAT)
    .Column('val_3', SQLITE_TEXT)
    .Row
      .Value(12)
      .Value(3.14)
      .Value('some value')
    .Row
      .Value(54)
      .Value(6.54)
      .Value('string value')
    .Row
      .Value(-874)
      .Value(532.00)
      .Value('test value')
    .Row
      .Value(471)
      .Value(0.025)
      .ValueNull
    .Get;

  AssertTrue('Database inserted rows count is not correct', inserted_rows = 4);

  counter := 0;
  for row in builder.Table('test_table').Select.All
    .Where('val_1',
      TSQLite3Select.TWhereComparisonOperator.COMPARISON_GREATER, 0)
    .WhereNotNull('val_3')
    .Get do
  begin
    case counter of
      0 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 12);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 3.14, 0.01);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = 'some value');
      end;
      1 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 54);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 6.54, 0.01);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = 'string value');
      end;
      2 : begin
        Fail('Impossible row.');
      end;
    end;
    Inc(counter);
  end;

  AssertTrue('Database selected rows count is not correct', counter = 2);

  counter := 0;
  for row in builder.Table('test_table').Select.All
    .WhereNull('val_3')
    .Get do
  begin
    case counter of
      0 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 471);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 0.025, 0.001);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = '');
      end;
      1 : begin
        Fail('Impossible row.');
      end;
    end;
    Inc(counter);
  end;

  AssertTrue('Database selected rows count is not correct', counter = 1);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_SelectOrderBy;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id.Integer('val_1').Float('val_2').Text('val_3');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema));

  inserted_rows := 0;
  inserted_rows := builder.Table('test_table').Insert
    .Column('val_1', SQLITE_INTEGER)
    .Column('val_2', SQLITE_FLOAT)
    .Column('val_3', SQLITE_TEXT)
    .Row
      .Value(12)
      .Value(3.14)
      .Value('some value')
    .Row
      .Value(54)
      .Value(6.54)
      .Value('string value')
    .Row
      .Value(-874)
      .Value(532.00)
      .Value('test value')
    .Row
      .Value(471)
      .Value(0.025)
      .ValueNull
    .Get;

  AssertTrue('Database inserted rows count is not correct', inserted_rows = 4);

  counter := 0;
  for row in builder.Table('test_table').Select.All
    .OrderBy('val_1', TSQLite3Select.TOrderByType.ORDER_ASC)
    .Get do
  begin
    case counter of
      0 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = -874);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 532.00, 0.01);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = 'test value');
      end;
      1 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 12);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 3.14, 0.01);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = 'some value');
      end;
      2 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 54);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 6.54, 0.01);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.GetStringValue('val_3') = 'string value');
      end;
      3 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 471);
        AssertEquals('Selected row ''val_2'' column value is not correct',
          row.GetDoubleValue('val_2'), 0.025, 0.001);
        AssertTrue('Selected row ''val_3'' column value is not correct', 
          row.IsNull('val_3'));
      end;
      4 : begin
        Fail('Impossible row.');
      end;
    end;
    Inc(counter);
  end;

  AssertTrue('Database selected rows count is not correct', counter = 4);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_Join;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  row : TSQLite3ResultRow;
  counter : Integer;
begin
  AssertTrue('Database file already exists', not FileExists('test.db'));

  schema := TSQLite3Schema.Create;
  schema.Id.Integer('val_1').Text('str').Integer('key_id');

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('table1').New(schema);

  AssertTrue('Table ''table1'' schema is not correct',
    builder.Table('table1').CheckSchema(schema));
  FreeAndNil(schema);

  schema := TSQLite3Schema.Create;
  schema.Id.Integer('val_2');

  builder.Table('table2').New(schema);

  AssertTrue('Table ''table2'' schema is not correct',
    builder.Table('table2').CheckSchema(schema));
  FreeAndNil(schema);

  inserted_rows := 0;
  inserted_rows := builder.Table('table1').Insert
    .Column('val_1', SQLITE_INTEGER)
    .Column('str', SQLITE_TEXT)
    .Column('key_id', SQLITE_INTEGER)
    .Row
      .Value(12)
      .Value('some value')
      .Value(1)
    .Row
      .Value(54)
      .Value('string value')
      .Value(2)
    .Row
      .Value(-874)
      .Value('test value')
      .ValueNull
    .Row
      .Value(471)
      .ValueNull
      .ValueNull
    .Get;

  AssertTrue('Database inserted rows count is not correct', inserted_rows = 4);

  inserted_rows := builder.Table('table2').Insert
    .Column('val_2', SQLITE_INTEGER)
    .Row.Value(-58)
    .Row.Value(-145)
    .Row.Value(-874)
    .Row.Value(471)
    .Get;

  AssertTrue('Database inserted rows count is not correct', inserted_rows = 4);

  counter := 0;
  for row in builder.Table('table1').Select.All
    .LeftJoin('table2', 'id', 'key_id')
    .WhereNotNull('key_id')
    .Get do
  begin
    case counter of
      0 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 12);
        AssertTrue('Selected row ''str'' column value is not correct',
          row.GetStringValue('str') = 'some value');
        AssertTrue('Selected row ''val_2'' column value is not correct', 
          row.GetIntegerValue('val_2') = -58);
      end;
      1 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 54);
        AssertTrue('Selected row ''str'' column value is not correct',
          row.GetStringValue('str') = 'string value');
        AssertTrue('Selected row ''val_2'' column value is not correct', 
          row.GetIntegerValue('val_2') = -145);
      end;
      2 : begin
        Fail('Impossible row.');
      end;
    end;
    Inc(counter);
  end;

  AssertTrue('Database selected rows count is not correct', counter = 2);

  counter := 0;
  for row in builder.Table('table1').Select.All
    .LeftJoin('table2', 'id', 'key_id')
    .Get do
  begin
    case counter of
      0 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 12);
        AssertTrue('Selected row ''str'' column value is not correct',
          row.GetStringValue('str') = 'some value');
        AssertTrue('Selected row ''val_2'' column value is not correct', 
          row.GetIntegerValue('val_2') = -58);
      end;
      1 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 54);
        AssertTrue('Selected row ''str'' column value is not correct',
          row.GetStringValue('str') = 'string value');
        AssertTrue('Selected row ''val_2'' column value is not correct', 
          row.GetIntegerValue('val_2') = -145);
      end;
      2 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = -874);
        AssertTrue('Selected row ''str'' column value is not correct',
          row.GetStringValue('str') = 'test value');
        AssertTrue('Selected row ''val_2'' column value is not correct', 
          row.IsNull('val_2'));
      end;
      3 : begin
        AssertTrue('Selected row ''val_1'' column value is not correct', 
          row.GetIntegerValue('val_1') = 471);
        AssertTrue('Selected row ''str'' column value is not correct',
          row.IsNull('str'));
        AssertTrue('Selected row ''val_2'' column value is not correct', 
          row.IsNull('val_2'));
      end;
      4 : begin
        Fail('Impossible row.');
      end;
    end;
    Inc(counter);
  end;

  AssertTrue('Database selected rows count is not correct', counter = 4);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  DeleteFile('test.db');
end;

procedure TSQLite3BuilderTestCase.Test_SQLite3Builder_Blob;
var
  schema : TSQLite3Schema;
  builder : TSQLite3Builder;
  inserted_rows : Integer;
  buffer : TMemoryBuffer;
begin
  schema := TSQLite3Schema.Create;
  schema.Id('id').Blob('data');

  AssertTrue('Database file already exists', not FileExists('test.db'));

  builder := TSQLite3Builder.Create('test.db',
    [TSQLite3Builder.TConnectFlag.SQLITE_OPEN_CREATE]);
  builder.Table('test_table').New(schema);

  AssertTrue('Table ''test_table'' schema is not correct',
    builder.Table('test_table').CheckSchema(schema));
  FreeAndNil(schema);

  buffer := TMemoryBuffer.Create;
  buffer.SetBufferDataSize(200);

  inserted_rows := 0;
  inserted_rows := builder.Table('test_table').Insert
    .Column('data', SQLITE_BLOB)
    .Row
      .Value(buffer)
    .Get;

  AssertTrue('Database inserted rows count is not correct', inserted_rows = 1);

  FreeAndNil(builder);

  AssertTrue('Database file not exists', FileExists('test.db'));

  //DeleteFile('test.db');
end;

initialization
  RegisterTest(TSQLite3BuilderTestCase);
end.

