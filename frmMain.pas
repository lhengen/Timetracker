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
  MAX_MRU_ITEMS = 5;
  DEBUG_TIMER_INTERVAL = 5 * MSecsPerSec;
  RELEASE_TIMER_INTERVAL = 15 * SecsPerMin * MSecsPerSec;

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
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    TrayIconData: TNotifyIconData;
    FTimeTrackerLog :ITimeTrackerLog;
    procedure ActivateAndFocusEdit;
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

procedure TMainForm.ActivateAndFocusEdit;
begin
  SetForegroundWindow(MainForm.Handle);
  edActivityDescription.SetFocus;
  edActivityDescription.SelectAll;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
  PrevForegroundWnd: HWND;
begin
  //form should always be hidden when timer expires
  Timer1.Enabled := False;
  if MainForm.Visible then
  begin
    ActivateAndFocusEdit;
    Timer1.Enabled := True;
  end
  else
  begin
    PrevForegroundWnd := GetForegroundWindow;
    MainForm.ShowModal;  //default action is caHide
    if IsWindow(PrevForegroundWnd) then
      SetForegroundWindow(PrevForegroundWnd);
  end;
end;

procedure TMainForm.TrayMessage(var Msg: TMessage);
begin
  case Msg.lParam of
    WM_LBUTTONDOWN:
    begin
      if MainForm.Visible then
        ActivateAndFocusEdit
      else
      begin
        Timer1.Enabled := False;
        MainForm.ShowModal;
        Timer1.Enabled := True;
      end;
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
    if Count > MAX_MRU_ITEMS then
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
  //don't attempt to write a log entry, revert to last accepted text
  if edActivityDescription.Items.Count > 0 then
    edActivityDescription.ItemIndex := 0
  else
    edActivityDescription.Text := '';
  DismissDialog;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssAlt]) and (Key = Ord('I')) then
  begin
    Key := 0;
    btIgnoreClick(btIgnore);
  end;
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
  FTimeTrackerLog.ReadLogEntries(edActivityDescription.Items,MAX_MRU_ITEMS);
  if edActivityDescription.Items.Count > 0 then
    edActivityDescription.ItemIndex := 0;

  {$ifdef DEBUG}
  Timer1.Interval := DEBUG_TIMER_INTERVAL;
  {$else}
  Timer1.Interval := RELEASE_TIMER_INTERVAL;
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
    ActivateAndFocusEdit
  else
  begin
    Timer1.Enabled := False;
    MainForm.ShowModal;
    Timer1.Enabled := True;
  end;
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
