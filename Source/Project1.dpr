program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Main},
  Unit2 in 'Unit2.pas' {Settings};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TSettings, Settings);
  Application.Run;
end.
