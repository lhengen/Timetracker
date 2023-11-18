{
Article:
System Tray Delphi application - quick and easy

http://delphi.about.com/library/weekly/aa121801a.htm

Placing Delphi applications in the System Tray
in easy steps. The perfect place for programs
that are left running for long periods of time
with no user interaction.
}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, shellapi, AppEvnts, StdCtrls, TimeTrackerLogInterface, Menus, ExtCtrls,
  ComCtrls;

const
  WM_ICONTRAY = WM_USER + 1;

type
  TMainForm = class(TForm)
    btOk: TButton;
    Label1: TLabel;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    Timer1: TTimer;
    btIgnore: TButton;
    mnuOpenLog: TMenuItem;
    mnuOpen: TMenuItem;
    edActivityDescription: TComboBoxEx;
    mnuShowFolderinExplorer: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btIgnoreClick(Sender: TObject);
    procedure mnuOpenLogClick(Sender: TObject);
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuShowFolderinExplorerClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    TrayIconData: TNotifyIconData;
    FTimeTrackerLog :ITimeTrackerLog;
    procedure DismissDialog;
  public
    procedure TrayMessage(var Msg: TMessage); message WM_ICONTRAY;
  end;


var
  MainForm: TMainForm;

implementation

uses
  TimeTrackerLog.TextFile, FileLoggerInterface;

{$R *.dfm}

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  //form should always be hidden when timer expires
  Timer1.Enabled := False;
  if not MainForm.Visible then
    MainForm.ShowModal  //default action is caHide
  else
  begin
    MainForm.Activate;
    MainForm.BringToFront;
  end;
end;

procedure TMainForm.TrayMessage(var Msg: TMessage);
begin
  case Msg.lParam of
    WM_LBUTTONDOWN:
    begin
      if MainForm.Visible then
        MainForm.SetFocus
      else
        MainForm.ShowModal;
    end;
    WM_RBUTTONDOWN:
    begin
      PopupMenu1.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
    end;
  end;
end;

procedure TMainForm.btOkClick(Sender: TObject);
begin
  FTimeTrackerLog.WriteLogEntry(Now,edActivityDescription.Text);
  with edActivityDescription.Items do
  begin
    Insert(0,edActivityDescription.Text);
    //only keep 5 items in the MRU list
    if Count > 5 then
       Delete(Count - 1);
  end;
  edActivityDescription.ItemIndex := 0;  //make last entered text current one
  DismissDialog;
end;

procedure TMainForm.DismissDialog;
begin
  ModalResult := mrOk;
  //only start timer again after dialog has been dismissed so popup Interval is
  //consistent and manual popups don't cause short intervals
  //this means user must always dismiss dialog in order to ensure time tracking works
  //it also means user can take their time entering in the comment without affecting interval
  Timer1.Enabled := True;
end;

procedure TMainForm.btIgnoreClick(Sender: TObject);
begin
  //don't attempt to write a log entry
  DismissDialog;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  //select all text so user can easily replace last description with current one
  edActivityDescription.SetFocus;
  edActivityDescription.SelectAll;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  with TrayIconData do
  begin
    cbSize := SizeOf;  //(TrayIconData);
    Wnd := Handle;
    uID := 0;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := Application.Icon.Handle;
    StrPCopy(szTip, Application.Title);
  end;

  Shell_NotifyIcon(NIM_ADD, @TrayIconData);
  FTimeTrackerLog := TTimeTrackerLog.Create;
  FTimeTrackerLog.ReadLogEntries(edActivityDescription.Items,5);
  if edActivityDescription.Items.Count > 0 then
    edActivityDescription.ItemIndex := 0;

  {$ifdef DEBUG}
  Timer1.Interval := 5 * MSecsPerSec; //when debugging prompt every 5 secs
  {$else}
  Timer1.Interval := 15 * SecsPerMin * MSecsPerSec;  //default prompt every 15 minutes
  {$endif}
  Timer1.Enabled := True;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
end;

procedure TMainForm.mnuOpenClick(Sender: TObject);
begin
  if MainForm.Visible then
    MainForm.Activate
  else
    MainForm.ShowModal;
end;

procedure TMainForm.mnuOpenLogClick(Sender: TObject);
var
  FileLogger :IFileLogger;
begin
  if Supports(FTimeTrackerLog,IFileLogger,FileLogger) and FileExists(FileLogger.FileName) then
    ShellExecute(0, 'open', PChar(FileLogger.FileName), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainForm.mnuShowFolderinExplorerClick(Sender: TObject);
begin
  ShellExecute(0, 'explore', PChar(ExtractFilePath(Application.ExeName)),nil, nil, SW_SHOWNORMAL);
end;

end.
