@echo off
setlocal EnableDelayedExpansion
title UBM Monitor
cd /d %APPDATA%\..\..\Desktop\

:: Default disk index
set "DISK_INDEX=0"
for %%A in (%*) do (
  if /i "%%~A"=="-d0" set DISK_INDEX=0
  if /i "%%~A"=="-d1" set DISK_INDEX=1
  if /i "%%~A"=="-d2" set DISK_INDEX=2
  if /i "%%~A"=="-d3" set DISK_INDEX=3
  if /i "%%~A"=="-d4" set DISK_INDEX=4
  if /i "%%~A"=="-d5" set DISK_INDEX=5
)

:: Keys to extract, format: label:jsonkey:component
set KEYS= sysUpTimeDays:sysUpTimeDays:0  smbiosFirmware:smbiosFirmware:0  smbiosVersion:smbiosVersion:0  ubmVersion:ubmVersion:0  userRunDurationSecs:userRunDurationSecs:0  bioName:bioName:0  freeGB:freeGB:0  phyCapacityGB:phyCapacityGB:0  phyMinFreeGB:phyMinFreeGB:0  ClockFreq:actualClockFreq:0  1CoreInt:1CoreIntCPUBench:0  2CoreFloat:2CoreFloatCPUBench:0  4CoreMixed:4CoreMixedCPUBench:0  RAMBench:16CoreMixedRAMBench:1  Latency:Latency128MB:1  1CoreIntCPUBench:1CoreIntCPUBench:0  1CoreFloatCPUBench:1CoreFloatCPUBench:0  1CoreMixedCPUBench:1CoreMixedCPUBench:0  2CoreIntCPUBench:2CoreIntCPUBench:0  2CoreFloatCPUBench:2CoreFloatCPUBench:0  2CoreMixedCPUBench:2CoreMixedCPUBench:0  4CoreIntCPUBench:4CoreIntCPUBench:0  4CoreFloatCPUBench:4CoreFloatCPUBench:0  4CoreMixedCPUBench:4CoreMixedCPUBench:0  8CoreIntCPUBench:8CoreIntCPUBench:0  8CoreFloatCPUBench:8CoreFloatCPUBench:0  8CoreMixedCPUBench:8CoreMixedCPUBench:0  32CoreIntCPUBench:32CoreIntCPUBench:0  32CoreFloatCPUBench:32CoreFloatCPUBench:0  32CoreMixedCPUBench:32CoreMixedCPUBench:0  ramFrequency:ramFrequency:0  totalRamGB:totalRamGB:0  freeRamGB:freeRamGB:0  Latency128MB:Latency128MB:0   1KB:1KB:1  2KB:2KB:1  4KB:4KB:1  8KB:8KB:1  16KB:16KB:1  32KB:32KB:1  64KB:64KB:1  128KB:128KB:1  256KB:256KB:1  512KB:512KB:1  1MB:1MB:1  2MB:2MB:1  4MB:4MB:1  8MB:8MB:1  16MB:16MB:1  32MB:32MB:1  64MB:64MB:1  128MB:128MB:1  256MB:256MB:1  dx09Plane:dx09Plane:4  dx09Cube:dx09Cube:4  dx09Stones:dx09Stones:4  dx10Swarm:dx10Swarm:4  dx10Galaxy:dx10Galaxy:4  dx10Sphere:dx10Sphere:4  gpuRamMB:gpuRamMB:0  SeqRead:sequentialRead:%DISK_INDEX%  SeqWrite:sequentialWrite:%DISK_INDEX%  SeqMixed:sequentialMixed:%DISK_INDEX%  4kRead:4kRead:%DISK_INDEX%  4kWrite:4kWrite:%DISK_INDEX%  4kMixed:4kMixed:%DISK_INDEX%  SeqWrite60:sequentialWrite60:%DISK_INDEX%


:refresh
cls
echo.
echo       UBM Monitor V Most Recent Benchmark Snapshots (Disk Index %DISK_INDEX%)
echo ==================V=======V=======V=======V=======V=======V=======V=======V=======V=======V=======V=======V=======V=======V=======V=======V=======V
echo KEY               V T-1   V T-2   V T-3   V T-4   V T-5   V T-6   V T-7   V T-8   V T-9   V T-10  V T-11  V T-12  V T-13  V T-14  V T-15  V T-16  V
echo ------------------V-------V-------V-------V-------V-------V-------V-------V-------V-------V-------V-------V-------V-------V-------V-------V-------V

:: Get hostname dynamically
for /f %%H in ('hostname') do set "HOSTNAME=%%H"

:: Get up to 8 most recent matching files for this host
set i=0
for /f "delims=" %%F in ('dir /b /a:-d /o-d *-%HOSTNAME%.json 2^>nul') do (
    set /a i+=1
    set "file[!i!]=%%F"
    if !i! geq 16 goto :gotfiles
)
:gotfiles

:: Loop through each key line
for %%K in (%KEYS%) do (
    for /f "tokens=1,2,3 delims=:" %%a in ("%%K") do (
        set "label=%%a"
        set "jsonkey=%%b"
        set "comp=%%c"
    )

    set "line=!label!"
    call :pad "line" 18

    for /L %%I in (1,1,!i!) do (
        set "f=!file[%%I]!"
        set "val=-"

        :: Search JSON line for matching component and key
        for /f "usebackq tokens=*" %%L in (`findstr /r /c:"\"!jsonkey!\"\s*:" "!f!"`) do (
            set "lineRaw=%%L"
            call :extractval "!lineRaw!" "val"
        )

        call :pad "val" 8
        set "line=!line!!val!"
    )
    echo !line!
)

REM :: Add a timeout to give the user a brief pause
REM timeout /t 1 >nul

:: Clear the previous value of inp to avoid carrying over old values
set inp=

echo.
echo Press ENTER to refresh, or Q to quit.
set /p inp=Input: 
echo You pressed: "!inp!"  :: Debugging the input

if /i "!inp!"=="q" exit /b
if /i "!inp!"=="x" exit /b
if /i "!inp!"=="w" exit /b

:: Ensuring the loop continues
goto :refresh

:: --- Pad helper ---
:pad
setlocal EnableDelayedExpansion
set "s=!%~1!"
set "pad=                "
set "s=!s!!pad!"
set "s=!s:~0,%~2!"
endlocal & set "%~1=%s%"
goto :eof

:: --- Extract value from JSON line (format: "key": 123.45,) ---
:extractval
setlocal EnableDelayedExpansion
set "raw=%~1"
set "val=-"
for /f "tokens=2 delims=:" %%V in ("!raw!") do (
    set "tmp=%%V"
    set "tmp=!tmp:,=!"
    set "tmp=!tmp:"=!"
    set "tmp=!tmp: =!"
    set "val=!tmp!"
)
endlocal & set "%~2=%val%"
goto :eof
