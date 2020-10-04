program libpassqlite_testproject;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, database_testcase, builder_testcase;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

