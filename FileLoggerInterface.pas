unit FileLoggerInterface;

interface

uses
  SysUtils;

type
  IFileLogger = interface['{31286155-9B2E-4BCD-A97F-8BEF261BA62B}']
    function GetFileName :string;
    property FileName :string read GetFileName;
  end;

implementation

end.
