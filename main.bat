@REM Hppsrc Custom Ventoy Terminal
@ECHO OFF && IF /I [%1]==[DEV] (@ECHO DEBUG MODE ENABLE && ECHO ON ) && IF EXIST dev.txt (@ECHO DEBUG MODE ENABLE && ECHO ON )
@SET "cmd_VERSION=1.2.0" && @SET "cmd_BUILD=25110111" && @SET /A cmd_STATIC_RANDOM=(%RANDOM%%%(999-100+1))+999 && @SET "cmd_RUNTIME=%TIME%" && TITLE Hppsrc CMD %cmd_VERSION%
@SET "COMMANDS=help version exit restart shutdown code cmd cls calc py"
SETLOCAL EnableDelayedExpansion
CD %~dp0





@REM #region PRECONFIG
@REM Section for custom personalization on run actions
:PRECONFIG
ECHO Loading preconfig...
ECHO Checking ShareX...
@REM Busca la carpeta de ShareX mas reciente. El GOTO rompe el bucle al encontrar la primera (y mas nueva).
SET "sharex_folder="
FOR /F "delims=" %%A IN ('DIR /B /AD "%~dp0Programas\ShareX-*-portable" 2^>nul ^| SORT /R') DO (
    SET "sharex_folder=%%A"
    GOTO :found_sharex
)
:found_sharex

@REM Si se encontro la carpeta, revisa si el proceso ya existe. Si no existe (||), lo inicia.
IF DEFINED sharex_folder (
    TASKLIST /FI "IMAGENAME eq ShareX.exe" | FIND /I "ShareX.exe" >NUL || START "ShareX Portable" /MIN "%~dp0Programas\%sharex_folder%\ShareX.exe"
)

@REM GOTO ADMIN_CHECK

@REM GOTO ADMIN_CHECK

GOTO :MAIN
@REM #endregion





@REM #region INTERNAL
:COMMANDS
ECHO --------------------
IF /I [%INPUT%]==[HELP] (GOTO :HELP)
IF /I [%INPUT%]==[VERSION] (GOTO :VERSION)
IF /I [%INPUT%]==[EXIT] (GOTO :EXIT)
IF /I [%INPUT%]==[RESTART] (GOTO :RESTART)
IF /I [%INPUT%]==[SHUTDOWN] (GOTO :SHUTDOWN)
IF /I [%INPUT%]==[CODE] (GOTO :CODE)
IF /I [%INPUT%]==[CMD] (GOTO :CMD)
IF /I [%INPUT%]==[CLS] (GOTO :CLS)
IF /I [%INPUT%]==[CALC] (GOTO :CALC)
IF /I [%INPUT%]==[PY] (GOTO :PY)
@REM #endregion





@REM #region MAIN
:MAIN
IF /I NOT [%1]==[DEV] (@CLS )
ECHO Hppsrc CMD ^| %cmd_VERSION%
ECHO Type HELP for help
ECHO ====================
:LOOP
SET /P "INPUT=%time% | %CD%> "
ECHO !COMMANDS! | findstr /i "\<%INPUT%\>" >nul
IF NOT ERRORLEVEL 1 ( GOTO :COMMANDS ) ELSE ( %INPUT% )
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
ECHO Python started...
IF EXIST "%~dp0Programas\Python\python.exe" (
    START "Python Embedded" "%~dp0Programas\Python\python.exe"
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

