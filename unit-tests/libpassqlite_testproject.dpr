program libpassqlite_testproject;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,

  utils.functor in '..\pascalutils\source\utils.functor.pas',
  container.arraylist in '..\libpasc-algorithms\source\container.arraylist.pas',
  container.list in '..\libpasc-algorithms\source\container.list.pas',
  container.memorybuffer in
    '..\libpasc-algorithms\source\container.memorybuffer.pas',

  sqlite3.code in '..\source\sqlite3\sqlite3.code.pas',
  utils.errorsstack in '..\pascalutils\source\utils.errorsstack.pas',
  sqlite3.errors_stack in '..\source\sqlite3\sqlite3.errors_stack.pas',
  libpassqlite in '..\source\libpassqlite.pas',
  sqlite3.connection in '..\source\sqlite3\sqlite3.connection.pas',
  sqlite3.query in '..\source\sqlite3\sqlite3.query.pas',
  sqlite3.result in '..\source\sqlite3\sqlite3.result.pas',
  sqlite3.result_row in '..\source\sqlite3\sqlite3.result_row.pas',
  sqlite3.database in '..\source\sqlite3.database.pas',

  sqlite3.structures in '..\source\builder\sqlite3.structures.pas',
  sqlite3.table in '..\source\builder\sqlite3.table.pas',
  sqlite3.schema in '..\source\builder\sqlite3.schema.pas',
  sqlite3.insert in '..\source\builder\sqlite3.insert.pas',
  sqlite3.select in '..\source\builder\sqlite3.select.pas',
  sqlite3.where in '..\source\builder\sqlite3.where.pas',
  sqlite3.update in '..\source\builder\sqlite3.update.pas',
  sqlite3.delete in '..\source\builder\sqlite3.delete.pas',
  sqlite3.builder in '..\source\sqlite3.builder.pas',

  rawbindings_testcase in '..\unit-tests\rawbindings_testcase.pas',
  database_testcase in '..\unit-tests\database_testcase.pas',
  builder_testcase in '..\unit-tests\builder_testcase.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

