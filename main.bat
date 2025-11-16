@REM Hppsrc Custom Ventoy Terminal
@ECHO OFF && IF /I [%1]==[DEV] (@ECHO DEBUG MODE ENABLE && ECHO ON )
@SET "cmd_VERSION=1.1.0" && @SET "cmd_BUILD=25110109" && @SET /A cmd_STATIC_RANDOM=(%RANDOM%%%(999-100+1))+999 && @SET "cmd_RUNTIME=%TIME%"
@SET "COMMANDS=help version exit restart"
SETLOCAL EnableDelayedExpansion
CD %~dp0





@REM #region PRECONFIG
@REM Section for custom personalization on run actions
ECHO Loading preconfig...
ECHO ShareX...
START /MIN /SEPARATE /REALTIME %~dp0\Programas\ShareX-18.0.1-portable\ShareX.exe

@REM ECHO Restart as admin...

GOTO :MAIN
@REM #endregion





@REM #region
@REM Section for custom personalization on run actions
ECHO Loading preconfig...
ECHO ShareX...
START /MIN /SEPARATE /REALTIME %~dp0\Programas\ShareX-18.0.1-portable\ShareX.exe

@REM ECHO Restart as admin...

GOTO :MAIN
@REM #endregion





@REM #region INTERNAL
:INTERNAL
ECHO --------------------
IF /I [%INPUT%]==[HELP] (GOTO :HELP)
IF /I [%INPUT%]==[VERSION] (GOTO :VERSION)
IF /I [%INPUT%]==[EXIT] (GOTO :EXIT)
IF /I [%INPUT%]==[RESTART] (GOTO :RESTART)
IF /I [%INPUT%]==[SHUTDOWN] (GOTO :SHUTDOWN)

@REM #endregion





@REM #region MAIN
:MAIN
IF /I NOT [%1]==[DEV] (@CLS )
ECHO Ventoy CMD ^| %cmd_VERSION%
ECHO Type HELP for help
ECHO ====================
:LOOP
SET /P "INPUT=%time% | %CD%> "
ECHO !COMMANDS! | findstr /i "\<%INPUT%\>" >nul
IF NOT ERRORLEVEL 1 ( GOTO :INTERNAL ) ELSE ( %INPUT% )
GOTO :LOOP
@REM #endregion





@REM #region COMMANDS
:HELP
ECHO Ventoy CMD ^| Made by Hppsrc
ECHO Version: %cmd_VERSION% ^(%cmd_BUILD%^)
ECHO Running since %cmd_RUNTIME%
ECHO.
ECHO Commands:
ECHO    HELP:       This output
ECHO    VERSION:    Version output
GOTO :END


:VERSION
ECHO Ventoy CMD ^| Version %cmd_VERSION% ^(%cmd_BUILD%^)
GOTO :END


:EXIT
IF /I [%1]==[DEV] ( ECHO DISABLED && GOTO :END )
ECHO Close Ventoy CMD
ECHO Please type "%cmd_STATIC_RANDOM%^" to exit

SET /P "CONFIRM=> "

IF /I "%CONFIRM%"=="EXIT %STATIC_RANDOM%" (
    ECHO Closing Ventoy CMD...
    TIMEOUT /T 1 >nul
    GOTO :EXIT_
) ELSE (
    ECHO Incorrect code. Type EXIT again to retry.
    GOTO :LOOP
)

GOTO :END


:RESTART
START /SEPARATE /REALTIME %~f0
GOTO :KILL


:END
ECHO --------------------
ECHO.
GOTO :LOOP


:KILL
EXIT