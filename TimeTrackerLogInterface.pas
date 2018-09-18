unit TimeTrackerLogInterface;

interface

uses
  Classes,
  SysUtils;

type
  ITimeTrackerLog = interface['{E4EB6AD6-1601-4638-955D-B05FFD1AF08E}']
    procedure WriteLogEntry(const TimeStamp :TDateTime; const Description :string);
    procedure ReadLogEntries(Items :TStrings; const MaxEntries :integer);
  end;

implementation

end.
