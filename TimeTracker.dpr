program TimeTracker;

{
********************************************
Zarko Gajic
About.com Guide to Delphi Programming
http://delphi.about.com
email: delphi@aboutguide.com
free newsletter: http://delphi.about.com/library/blnewsletter.htm
forum: http://forums.about.com/ab-delphi/start/
********************************************
}
uses
  Forms,
  frmMain in 'frmMain.pas' {MainForm},
  TimeTrackerLog.TextFile in 'TimeTrackerLog.TextFile.pas',
  TimeTrackerLogInterface in 'TimeTrackerLogInterface.pas',
  FileLoggerInterface in 'FileLoggerInterface.pas',
  uSingleAppInstance in 'uSingleAppInstance.pas';

{$R *.res}

begin
  if IsSingleInstance('TimeTracker') then
  begin
    Application.Initialize;
    Application.ShowMainForm := False;
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  end;
end.


