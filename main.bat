@REM Hppsrc Custom Ventoy Terminal
@ECHO OFF && IF /I [%1]==[DEV] (@ECHO DEBUG MODE ENABLE && ECHO ON ) && IF EXIST dev.txt (@ECHO DEBUG MODE ENABLE && ECHO ON )
@SET "cmd_VERSION=1.3.0" && @SET "cmd_BUILD=25110113" && @SET /A cmd_STATIC_RANDOM=(%RANDOM%%%(999-100+1))+999 && @SET "cmd_RUNTIME=%TIME%" && TITLE Hppsrc CMD %cmd_VERSION%
@SET "COMMANDS=help version exit restart shutdown code cmd cls calc py admin"
SETLOCAL EnableDelayedExpansion
CD /d %~dp0





@REM #region PRECONFIG
@REM Section for custom personalization on run actions
:PRECONFIG
ECHO Loading preconfig...
ECHO Checking ShareX...
SET "sharex_folder="
FOR /F "delims=" %%A IN ('DIR /B /AD "%~dp0Programas\ShareX-*-portable" 2^>nul ^| SORT /R') DO (
    SET "sharex_folder=%%A"
    GOTO :found_sharex
)
:found_sharex
IF DEFINED sharex_folder (
    TASKLIST /FI "IMAGENAME eq ShareX.exe" | FIND /I "ShareX.exe" >NUL || START "ShareX Portable" /MIN /REALTIME "%~dp0Programas\%sharex_folder%\ShareX.exe"
)

ECHO Cheking admin...
net session >nul 2>&1
IF %ERRORLEVEL% == 0 (
    SET "cmd_ADMIN=[ADMIN]"
)


GOTO :MAIN
@REM #endregion





@REM #region INTERNAL
:COMMANDS
ECHO --------------------
IF /I [!_cmd!]==[HELP] (GOTO :HELP)
IF /I [!_cmd!]==[VERSION] (GOTO :VERSION)
IF /I [!_cmd!]==[EXIT] (GOTO :EXIT)
IF /I [!_cmd!]==[RESTART] (GOTO :RESTART)
IF /I [!_cmd!]==[SHUTDOWN] (GOTO :SHUTDOWN)
IF /I [!_cmd!]==[CODE] (GOTO :CODE)
IF /I [!_cmd!]==[CMD] (GOTO :CMD)
IF /I [!_cmd!]==[CLS] (GOTO :CLS)
IF /I [!_cmd!]==[CALC] (GOTO :CALC)
IF /I [!_cmd!]==[PY] (GOTO :PY)
IF /I [!_cmd!]==[ADMIN] (GOTO :ADMIN)
@REM #endregion





@REM #region MAIN
:MAIN
IF /I NOT [%1]==[DEV] (@CLS )
ECHO Hppsrc CMD ^| %cmd_VERSION% %cmd_ADMIN%
ECHO Type HELP for help
ECHO ====================
:LOOP
SET "INPUT="
SET /P "INPUT=%time% | %CD%> "
IF NOT DEFINED INPUT GOTO LOOP
FOR /F "tokens=1,*" %%A IN ("!INPUT!") DO (
    SET "_cmd=%%A"
    SET "_args=%%B"
)

ECHO !COMMANDS! | findstr /i "\<!_cmd!\>" >nul
IF NOT ERRORLEVEL 1 ( GOTO :COMMANDS ) ELSE ( !INPUT! )
GOTO :LOOP

@REM #endregion





@REM #region COMMANDS
:HELP
ECHO Hppsrc CMD ^| Made by Hppsrc
ECHO Version: %cmd_VERSION% ^(%cmd_BUILD%^)
ECHO Running since %cmd_RUNTIME%
ECHO.
ECHO Commands:
ECHO    HELP        Show this help message
ECHO    VERSION     Show Hppsrc CMD version
ECHO    EXIT        Close Hppsrc CMD ^*
ECHO    RESTART     Restart the current Hppsrc CMD session
ECHO    SHUTDOWN    Shutdown the PC ^*
ECHO    CODE        Launch VS Code in isolated mode
ECHO    CMD         Open a new Windows CMD window
ECHO    CLS         Clear screen and refresh Hppsrc CMD
ECHO    CALC        Open a simple CLI based calculator
ECHO    PY          Open a Python CLI ^(Args allowed^)
ECHO.
ECHO ^* Requires confirmation code
GOTO :END


:VERSION
ECHO Ventoy CMD ^| Version %cmd_VERSION% ^(%cmd_BUILD%^)
GOTO :END


:EXIT
ECHO Close Hppsrc CMD
ECHO Please type "%cmd_STATIC_RANDOM%" to exit

SET /P "cmd_CONFIRM=> "

IF /I "%cmd_CONFIRM%"=="%cmd_STATIC_RANDOM%" (
    ECHO Closing Ventoy CMD...
    TIMEOUT /T 1 >nul
    GOTO :KILL_UNCONFIG
) ELSE (
    ECHO Incorrect code. Type EXIT again to retry.
    GOTO :LOOP
)

GOTO :END


:RESTART
START /SEPARATE /REALTIME %~f0
GOTO :KILL

:SHUTDOWN
ECHO Shutdown PC
ECHO Please type "%cmd_STATIC_RANDOM%" to exit

SET /P "cmd_CONFIRM=> "

IF /I "%cmd_CONFIRM%"=="%cmd_STATIC_RANDOM%" (
    ECHO Shutdown PC...
    SHUTDOWN /f /t 0 /s
    GOTO :KILL_UNCONFIG
) ELSE (
    ECHO Incorrect code. Type EXIT again to retry.
    GOTO :LOOP
)
GOTO :END


:CODE
ECHO Vscode started...
START "" /SEPARATE /REALTIME code --extensions-dir "%temp%\vs-extension" --user-data-dir "%temp%\vsdata"
GOTO :END


:CMD
ECHO CMD started...
START /SEPARATE /REALTIME "cmd"
GOTO :END


:CLS
GOTO :MAIN


:CALC
ECHO Type operation
SET /P "expr=> "
SET "expr=%expr: =%"

SET /A result=%expr% >nul 2>&1
IF ERRORLEVEL 1 (
    ECHO Invalid expression.
) ELSE (
    ECHO = %result%
)
GOTO :END


:PY
ECHO Starting Python...
IF EXIST "%~dp0Programas\Python\python.exe" (
    START "Python: !_args!" "%~dp0Programas\Python\python.exe" !_args!
) ELSE (
    ECHO Python not found.
)
GOTO :END


:ADMIN
IF DEFINED cmd_ADMIN (
    ECHO You're already admin.
) ELSE (
    ECHO Restarting as admin...
    powershell -command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
    GOTO :KILL
)
GOTO :END


@REM #endregion





@REM #region EXIT ACTIONS
:END
ECHO --------------------
ECHO.
GOTO :LOOP

:KILL_UNCONFIG
ECHO Starting unconfig...

:EXIT
CLS && EXIT /B

:KILL
EXIT

