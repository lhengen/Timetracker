@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
cd /d "C:\Data\Tools\Timetracker"
set CONFIG=Debug
if /i "%~1"=="release" set CONFIG=Release
msbuild TimeTracker.dproj /t:Build /p:Config=%CONFIG% /p:Platform=Win64 /v:normal
exit /b %ERRORLEVEL%
