unit uSingleAppInstance;

interface

uses
  Winapi.Windows;

function IsSingleInstance(MutexName : string; KeepMutex : boolean = true):boolean;

implementation

//Creates a mutex to see if the program is already running.
function IsSingleInstance(MutexName : string; KeepMutex : boolean = true):boolean;
const MUTEX_GLOBAL = 'Global\'; //Prefix to explicitly create the object in the global or session namespace. I.e. both client app (local user) and service (system account)

var MutexHandel : THandle;
    SecurityDesc: TSecurityDescriptor;
    SecurityAttr: TSecurityAttributes;
    ErrCode : integer;
begin
  //  By default (lpMutexAttributes =nil) created mutexes are accessible only by
  //  the user running the process. We need our mutexes to be accessible to all
  //  users, so that the mutex detection can work across user sessions.
  //  I.e. both the current user account and the System (Service) account.
  //  To do this we use a security descriptor with a null DACL.
  InitializeSecurityDescriptor(@SecurityDesc, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@SecurityDesc, True, nil, False);
  SecurityAttr.nLength:=SizeOf(SecurityAttr);
  SecurityAttr.lpSecurityDescriptor:=@SecurityDesc;
  SecurityAttr.bInheritHandle:=False;

  //  The mutex is created in the global name space which makes it possible to
  //  access across user sessions.
  MutexHandel := CreateMutex(@SecurityAttr, True, PChar(MUTEX_GLOBAL + MutexName));
  ErrCode := GetLastError;

  //  If the function fails, the return value is 0
  //  If the mutex is a named mutex and the object existed before this function
  //  call, the return value is a handle to the existing object, GetLastError
  //  returns ERROR_ALREADY_EXISTS.
  if {(MutexHandel = 0) or }(ErrCode = ERROR_ALREADY_EXISTS) then
  begin
    result := false;
    closeHandle(MutexHandel);
  end
  else
  begin
    //  Mutex object has not yet been created, meaning that no previous
    //  instance has been created.
    result := true;

    if not KeepMutex then
       CloseHandle(MutexHandel);
  end;

  // The Mutexhandle is not closed because we want it to exist during the
  // lifetime of the application. The system closes the handle automatically
  //when the process terminates.
end;

end.
