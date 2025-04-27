@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:: --- Prep variables ---
for /f %%i in ('hostname') do set HOSTNAME=%%i
for /f %%i in ('powershell -NoProfile -Command "[int][double]::Parse((Get-Date -UFormat %%s))"') do set UNIXTIME=%%i

set "OUTPUT=%APPDATA%\..\..\Desktop\%UNIXTIME%-%HOSTNAME%.json"
set "TMPFILE=%TEMP%\ubm_output_%UNIXTIME%.tmp"
set "JSONTMP=%TEMP%\ubm_json_%UNIXTIME%.tmp"
set "UBMRE=%APPDATA%\UserBenchmark\App\RunEngine\UserBenchMarkRunEngine.exe"

REM :: --- Elevate if not admin ---
REM net session >nul 2>&1
REM if %errorlevel% neq 0 (
REM     powershell -Command "Start-Process '%~f0' -Verb RunAs"
REM     exit /b
REM )

:: --- Run UserBenchmark with live output and capture ---
echo Launching UserBenchmark...
start/b powershell -NoProfile -Command ^
  "& { & ' %UBMRE%' jsondebug | Tee-Object -FilePath '%TMPFILE%' }"

:: --- Estimate expected benchmark duration ---
set "EXPECTED=4"
set "UBMAPP=%APPDATA%\UserBenchmark\App\RunEngine"

if exist "%UBMAPP%\FLOCK.exe" set /a EXPECTED+=4
if exist "%UBMAPP%\MCUBES.exe" set /a EXPECTED+=4
if exist "%UBMAPP%\NBODY.exe" set /a EXPECTED+=4
if exist "%UBMAPP%\POM.exe" set /a EXPECTED+=4
if exist "%UBMAPP%\RTAGS.exe" set /a EXPECTED+=4
if exist "%UBMAPP%\SHADOW.exe" set /a EXPECTED+=4
if exist "%UBMAPP%\UBMGPUStats.exe" set /a EXPECTED+=2
if exist "%UBMAPP%\UBMCPUBench.exe" set /a EXPECTED+=32
if exist "%UBMAPP%\UBMRAMBench.exe" set /a EXPECTED+=32
if exist "%UBMAPP%\UBMDriveBench.exe" set /a EXPECTED+=150

echo Estimated benchmark duration: %EXPECTED% seconds.
timeout /t %EXPECTED% /nobreak >nul


:: --- Extract JSON block ---
set INJSON=false
set /a BRACECOUNT=0
del "%JSONTMP%" >nul 2>&1

for /f "delims=" %%L in ('type "%TMPFILE%"') do (
    set "LINE=%%L"

    if "!LINE!"=="{" (
        set INJSON=true
    )

    if "!INJSON!"=="true" (
        >> "%JSONTMP%" echo(!LINE!

        echo !LINE! | findstr /c:"{" >nul && set /a BRACECOUNT+=1
        echo !LINE! | findstr /c:"}" >nul && set /a BRACECOUNT-=1

        if !BRACECOUNT! LEQ 0 (
            goto :endloop
        )
    )
)

:endloop

:: --- Move final JSON to Desktop ---
if exist "%JSONTMP%" (
    move /y "%JSONTMP%" "%OUTPUT%" >nul
    echo.
    echo Benchmark complete.
    echo JSON saved to: %OUTPUT%
    exit /b
) else (
    echo.
    echo ERROR: No JSON extracted. Please check the output.
    exit /b
)

:: --- Cleanup ---
del "%TMPFILE%" >nul 2>&1

echo Done.
:: --- Kill orphaned pause window ---
for /f "tokens=2" %%i in ('tasklist /v /fi "imagename eq conhost.exe" ^| findstr /i "cmd.exe 0x4"') do (
    taskkill /f /pid %%i >nul 2>&1
)

endlocal
