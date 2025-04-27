@echo off
setlocal EnableDelayedExpansion
title UBM Monitor - ASCII Bar Chart
cd /d %APPDATA%\..\..\Desktop\

:: Accept key argument for comparison
set "KEY=%1"
if "%KEY%"=="" (
    set "KEY=actualClockFreq"
)

:: Get hostname dynamically
for /f %%H in ('hostname') do set "HOSTNAME=%%H"

:: Get up to 8 most recent matching files for this host
set i=0
for /f "delims=" %%F in ('dir /b /a:-d /o-d *-%HOSTNAME%.json 2^>nul') do (
    set /a i+=1
    set "file[!i!]=%%F"
    if !i! geq 8 goto :gotfiles
)
:gotfiles

:: Prepare to store values of the selected key for normalization
set min=999999999
set max=-1
set values=
set range=0

:: Loop through each file and extract the key values
for /L %%I in (1,1,!i!) do (
    set "f=!file[%%I]!"
    set "val=-"

    :: Search JSON line for matching key
    for /f "usebackq tokens=*" %%L in (`findstr /r /c:"\"!KEY!\"\s*:" "!f!"`) do (
        set "lineRaw=%%L"
        call :extractval "!lineRaw!" "val"
    )

    if "!val!" neq "-" (
        :: Clean the extracted value before appending
        set "val=!val:"=!"  :: Remove quotes
        set "val=!val: =!"  :: Remove spaces
        set "val=!val:,=!"  :: Remove commas
        set "values=!values! !val!"
        if !val! lss !min! set min=!val!
        if !val! gtr !max! set max=!val!
    )
)

:: Check if any values were found
if "!values!"=="" (
    echo No data found for the key: %KEY%
    exit /b
)

:: Calculate the range
set /a range=!max! - !min!

:: Ensure range is not zero (to avoid division by zero)
if !range! lss 1 (
    set range=1
)

echo Comparing key: %KEY%
echo.

:: Loop through the values and print the bar chart
for %%V in (!values!) do (
    if "%%V" neq "" (
        set "value=%%V"
        set "value=!value: =!"  :: Remove spaces
        set "value=!value:"=!"  :: Remove quotes
        set "value=!value:,=!"  :: Remove commas

        :: Ensure the value is a valid number (keeping the decimal intact)
        for /f %%A in ("!value!") do (
            set /a temp=%%A 2>nul
            if "!temp!"=="" (
                echo ERROR: Invalid number format: !value!
                exit /b
            )
        )

        :: Normalize the value (fix division issue)
        set /a normalized=(!value!*100) / !range!

        :: Prevent negative values
        if !normalized! lss 0 set normalized=0
        if !normalized! gtr 100 set normalized=100

        :: Adjust the bar length based on max_bar_length (scaled to fit within the range)
        set /a bar_length=!normalized!*50/100  :: Cap the max bar length to 50

        :: Create the bar
        set "bar="
        for /L %%B in (1,1,!bar_length!) do set "bar=!bar!="

        :: Display the bar chart
        echo !bar! !value!
    )
)

echo.
echo Press ENTER to refresh, or Q to quit.
set /p inp=Input: 
if /i "!inp!"=="q" exit /b
goto :eof

:: --- Extract value from JSON line (format: "key": 123.45,) ---
:extractval
setlocal EnableDelayedExpansion
set "raw=%~1"
set "val=-"
for /f "tokens=2 delims=:" %%V in ("!raw!") do (
    set "tmp=%%V"
    set "tmp=!tmp:,=!"" 
    set "tmp=!tmp:"=!"" 
    set "tmp=!tmp: =!"
    set "val=!tmp!"
)
endlocal & set "%~2=%val%"
goto :eof 