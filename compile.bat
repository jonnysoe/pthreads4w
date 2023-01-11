@echo off

:: Set Nmake args
set ARGS=%*
if "%ARGS%"=="" set ARGS=all

:: MSVC is not installed
if not exist "%ProgramFiles(x86)%\Windows Kits\10\bin\" exit /b 1

set WIN_SDK=
set WIN_ARCH=
set MSVC_YYYY=
set MSVC_EDITION=

:: Get Latest Windows 10 SDK
:: "for /f" will always replaced the result, so the final result is the last line (latest version)
for /f "tokens=* USEBACKQ" %%A in (`dir /a:d /b "%ProgramFiles(x86)%\Windows Kits\10\bin\" ^| findstr "^[0-9]"`) do set WIN_SDK=%%A
if "%WIN_SDK%"=="" exit /b 2

:: Get CPU architecture
:: https://stackoverflow.com/a/62027921/19336104
set lowercase=for /L %%n in (1 1 2) do if %%n==2 ( for %%# in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "result=!result:%%#=%%#!") else setlocal enableDelayedExpansion ^& set result=
%lowercase%%PROCESSOR_ARCHITECTURE%
endlocal & set WIN_ARCH=%result%

:: Get Latest MSVC
:: "for /f" will always replaced the result, so the final result is the last line (latest version)
for /f "tokens=* USEBACKQ" %%A in (`dir /a:d /b "%ProgramFiles(x86)%\Microsoft Visual Studio\" ^| findstr "^[0-9]"`) do set MSVC_YYYY=%%A
if "%MSVC_YYYY%"=="" exit /b 3

:: Get MSVC Edition
:: Make sure only the following are allowed, prefer the lesser license
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\%MSVC_YYYY%\BuildTools" (
    set MSVC_EDITION=BuildTools
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\%MSVC_YYYY%\Community" (
    set MSVC_EDITION=Community
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\%MSVC_YYYY%\Professional" (
    set MSVC_EDITION=Professional
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\%MSVC_YYYY%\Enterprise" (
    set MSVC_EDITION=Enterprise
)
if "%MSVC_EDITION%"=="" exit /b 4

:: Setup compiler environment, this needs to be called before CMake
if "%VSCMD_VER%"=="" call "%ProgramFiles(x86)%\Microsoft Visual Studio\%MSVC_YYYY%\%MSVC_EDITION%\VC\Auxiliary\Build\vcvarsall.bat" %WIN_ARCH% %WIN_SDK%

:: vcvarsall.bat does not return error code VSCMD_VER is the safest way to check
if "%VSCMD_VER%"=="" exit /b 5

:build
call nmake %ARGS%
