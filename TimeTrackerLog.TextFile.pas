unit TimeTrackerLog.TextFile;

interface

uses
  TimeTrackerLogInterface,
  FileLoggerInterface,
  Classes,
  SysUtils;

type
  TTimeTrackerLog = class(TInterfacedObject,ITimeTrackerLog, IFileLogger)
  private
    FLogDate :TDateTime;
    FDailyLog :TStringList;
    FDailyLogFileName :TFileName;
    function GetLogFileName: string;
    function GetFileName :string;
  public
    procedure WriteLogEntry(const TimeStamp :TDateTime; const Description :string);
    procedure ReadLogEntries(Items :TStrings; const MaxEntries :integer);
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;


implementation

uses
  Vcl.Forms;


{ TTimeTrackerLog }

procedure TTimeTrackerLog.AfterConstruction;
begin
  inherited;
  FDailyLog := TStringList.Create;
  FLogDate := Now;
  FDailyLogFileName := GetLogFileName;

  //if the file exists, re-load it so we only create 1 file per day and we never lose information if user exits or program crashes
  if FileExists(FDailyLogFileName) then
    FDailyLog.LoadFromFile(FDailyLogFileName);
end;

procedure TTimeTrackerLog.BeforeDestruction;
begin
  FDailyLog.Free;
  inherited;
end;

function TTimeTrackerLog.GetFileName: string;
begin
  Result :=  IncludeTrailingPathDelimiter(ExtractFilePath(Application.EXEName)) + GetLogFileName;
end;

function TTimeTrackerLog.GetLogFileName :string;
begin
  Result := FormatDateTime('yyyymmdd',FLogDate)+ ' TimeTrackerLog.txt';
end;

procedure TTimeTrackerLog.ReadLogEntries(Items: TStrings; const MaxEntries: integer);
//copies the text from MaxEntries from the end of the log (most recent ones) to the Items passed.
var
  Entries :TStringList;
  J,
  I: Integer;
  Sections :TArray<string>;
  FileName :string;
begin
  Items.Clear;
  FileName := GetLogFileName;
  if not FileExists(FileName) then
    Exit;

  Entries := TStringList.Create;
  Entries.LoadFromFile(GetLogFileName);
  J := Entries.Count - 1;
  for I := 1 to MaxEntries do
  begin
    if J >= 0 then
    begin
      //parse out the description portion only
      Sections := Entries[J].Split(['|']);
      Items.Add(Trim(Sections[1]));
      Dec(J,1);
    end;
  end;
end;

procedure TTimeTrackerLog.WriteLogEntry(const TimeStamp: TDateTime; const Description: string);
begin
  //check if logging has spanned a daily boundary
  if Trunc(FLogDate) <> Trunc(TimeStamp) then
  begin
    //save the current entries
    FDailyLog.SaveToFile(FDailyLogFileName);
    //generate a new log filename and re-start the buffering
    FDailyLog.Clear;
    FLogDate := TimeStamp;
    FDailyLogFileName := GetLogFileName;
  end;

  //if the description is the same do not create a log entry
  if ((FDailyLog.Count > 0) and not FDailyLog[FDailyLog.Count-1].Contains(Description)) or (FDailyLog.Count = 0) then
  begin
    FDailyLog.Add(DateTimeToStr(TimeStamp)+' | '+Description);
    FDailyLog.SaveToFile(FDailyLogFileName);
  end;
end;

end.
