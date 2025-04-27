@echo off
setlocal ENABLEDELAYEDEXPANSION
cd /d "%~dp0"

:: Change to directory where UBM tools are located
cd /d "%APPDATA%\UserBenchmark\App\RunEngine"

:: Map keys to executables
set "F=FLOCK.exe"
set "M=MCUBES.exe"
set "N=NBODY.exe"
set "P=POM.exe"
set "T=RTAGS.exe"
set "S=SHADOW.exe"
set "G=UBMGPUStats.exe"
set "C=UBMCPUBench.exe"
set "R=UBMRAMBench.exe"
set "D=UBMDriveBench.exe"

:menu
cls
echo(
echo ================================================================================
echo                             UserBenchmark CLI Controller
echo ================================================================================
echo(
   call :show_status C "C      CPU Bench"
   call :show_status R " R     RAM Bench"
   call :show_status G "  G    GPU Stats"
echo(
   call :show_status F "F      FLOCK"
   call :show_status M " M     MCUBES"
   call :show_status N "  N    NBODY"
   call :show_status P "   P   POM"
   call :show_status T "    T  RTAGS"
   call :show_status S "     S SHADOW"
echo(
   call :show_status D "D      Drive Bench"
echo(
echo       GO  Run Benchmarks
echo        W  UBM Monitor

echo        X  Exit
echo(
set /p "choice=Select a test to toggle or GO to run: "
if /i "%choice%"=="W" (
  set "UBMMONITOR=ubm_monitor.bat"

  if exist "%~dp0!UBMMONITOR!" (
    start /wait cmd /c "%~dp0!UBMMONITOR!"
  ) else if exist "%APPDATA%\UserBenchmark\App\RunEngine\!UBMMONITOR!" (
    start /wait cmd /c "%APPDATA%\UserBenchmark\App\RunEngine\!UBMMONITOR!"
  ) else (
    echo.
    echo ERROR: Could not find !UBMMONITOR! in either location.
  )
  goto menu
)


if /i "%choice%"=="X" exit /b
if /i "%choice%"=="GO" (
  set "UBMSCRIPT=run_ubm_jsondebug_admin.bat"

  if exist "%~dp0!UBMSCRIPT!" (
  call "%~dp0!UBMSCRIPT!"
  ) else if exist "%APPDATA%\UserBenchmark\App\RunEngine\!UBMSCRIPT!" (
  call "%APPDATA%\UserBenchmark\App\RunEngine\!UBMSCRIPT!"
  ) else (
  echo.
  echo ERROR: Could not find !UBMSCRIPT! in either location.
  pause
  )

  pause
  goto menu
)

if "%choice%"=="" goto menu

:: Handle toggle
call :toggle %choice:~0,1%
goto menu

:: === Subroutine to show status ===
:show_status
set "file=!%~1!"
if exist "!file!" (
  echo       [   ON] %~2
) else if exist "!file:.exe=.bak!" (
  echo       [OFF  ] %~2
) else (
  echo       [ ERR ] %~2 not found
)
exit /b

:: === Subroutine to toggle on/off ===
:toggle
set "key=%~1"
set "target=!%key%!"
set "bakfile=!target:.exe=.bak!"

:: Special logic for 'G' - GPUStats combo toggle
if /i "!key!"=="G" (
  :: Check if G is currently OFF
  if exist "!bakfile!" (
  :: Check if F, M, N, P, T, S are all OFF
  set "all_gpu_off=1"
  for %%x in (F M N P T S) do (
   if exist "!%%x!" set "all_gpu_off=0"
  )
  if "!all_gpu_off!"=="1" (
   echo Enabling GPUStats and all GPU tests...
   ren "!bakfile!" "!bakfile:.bak=.exe!"
   for %%x in (F M N P T S) do (
    ren "!%%x:.exe=.bak!" "!%%x!"
   )
   exit /b
  )
  )
)

:: Normal toggle behavior
if exist "!target!" (
  ren "!target!" "!target:.exe=.bak!"
) else if exist "!bakfile!" (
  ren "!bakfile!" "!bakfile:.bak=.exe!"
)
exit /b