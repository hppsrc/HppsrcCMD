@ECHO OFF
@REM Hppsrc CMD
SETLOCAL EnableDelayedExpansion
@SET "_temp="
IF /I [%1]==[DEV] ( @ECHO DEBUG MODE ENABLE && ECHO ON )
IF /I [%1]==[RESTART] ( SET "_temp= ^[RESTARTED^]" )
@SET "cmd_VERSION=1.5.0" && @SET "cmd_BUILD=25111108" && @SET /A cmd_STATIC_RANDOM=(%RANDOM%%%(999-100+1))+999 && @SET "cmd_RUNTIME=%TIME%" && @SET "cmd_TEMP_FOLDER=%temp%\Hppsrc_CMD" && TITLE Hppsrc CMD %cmd_VERSION%
@SET "COMMANDS=help version exit restart shutdown code cmd cls calc py admin folder powershell pwsh ps scrcpy"
CD /d %~dp0





@REM #region PRECONFIG
@REM Section for custom personalization on run actions
:PRECONFIG
ECHO Loading preconfig...

ECHO - Checking ShareX...
SET "sharex_folder="
FOR /F "delims=" %%A IN ('DIR /B /AD "%~dp0Programas\ShareX-*-portable" 2^>nul ^| SORT /R') DO (
    SET "sharex_folder=%%A"
    GOTO :found_sharex
)
:found_sharex
IF DEFINED sharex_folder (
    TASKLIST /FI "IMAGENAME eq ShareX.exe" | FIND /I "ShareX.exe" >NUL || START "ShareX Portable" /MIN /REALTIME "%~dp0Programas\%sharex_folder%\ShareX.exe"
)

ECHO - Start Chrome as guest...
mkdir %cmd_TEMP_FOLDER%\ChromeGuest
mkdir %cmd_TEMP_FOLDER%\ChromeCache
mkdir %cmd_TEMP_FOLDER%\ChromeDownload
start "" /min "chrome" --guest --user-data-dir="%cmd_TEMP_FOLDER%\ChromeGuest" --disk-cache-dir="%cmd_TEMP_FOLDER%\ChromeCache" --download.default_directory="%cmd_TEMP_FOLDER%\ChromeDownload" "https://discord.com/login" "https://accounts.google.com/ServiceLogin"

ECHO - Creating temporal folder...
MKDIR %cmd_TEMP_FOLDER%
ECHO RMDIR %cmd_TEMP_FOLDER% ^/Q ^/S > "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat"
ECHO DEL "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat" >> "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat"

ECHO - Setting ES_ES Keyboard
powershell.exe "Set-WinUserLanguageList (New-WinUserLanguageList es-ES) -Force"

ECHO - Creating ScrCpy data...
powershell.exe Expand-Archive %~dp0\Programas\ScrCpy\data.zip -DestinationPath %cmd_TEMP_FOLDER%\ScrCpyData\

ECHO - Cheking admin...
net session >nul 2>&1
IF %ERRORLEVEL% == 0 (
    SET "cmd_ADMIN=[ADMIN]"
) else (
    GOTO :MAIN
)

ECHO Adding reg keys...
ECHO Copy as Path...
reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /ve /d "Copy &as path" /f
reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /v "Icon" /t REG_SZ /d "imageres.dll,-5302" /f
reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /v "InvokeCommandOnSelection" /t REG_DWORD /d 1 /f
reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /v "VerbHandler" /t REG_SZ /d "{f3d06e7c-1e45-4a26-847e-f9fcdee59be0}" /f
reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /v "VerbName" /t REG_SZ /d "copyaspath" /f

ECHO Open with notepad...
reg add "HKEY_CLASSES_ROOT\*\shell\Open With Notepad" /v "Icon" /t REG_SZ /d "C:\Windows\System32\notepad.exe, 2" /f
reg add "HKEY_CLASSES_ROOT\*\shell\Open With Notepad\command" /ve /d "notepad.exe %1" /f

ECHO Seconds on explorer...
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t REG_DWORD /d 1 /f

ECHO Old volume applet...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" /v "EnableMtcUvc" /t REG_DWORD /d 0 /f

ECHO Theme toggler...
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme" /v "MUIVerb" /d "Set Windows theme" /f
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme" /v "Icon" /d "%%SystemRoot%%\System32\imageres.dll,-183" /f
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme" /v "SubCommands" /d "" /f

REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme\shell\Dark" /v "MUIVerb" /d "Enable Dark mode" /f
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme\shell\Dark\command" /ve /d "cmd /q /c \"taskkill /im explorer.exe /f && reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme REM /t REG_DWORD /d 0 /f && reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f && start explorer.exe\"" /f

REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme\shell\Light" /v "MUIVerb" /d "Enable Light mode" /f
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme\shell\Light\command" /ve /d "cmd /q /c \"taskkill /im explorer.exe /f && reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 1 /f && reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 1 /f && start explorer.exe\"" /f

TASKKILL /im EXPLORER.EXE /F
TIMEOUT /T 1
START EXPLORER.EXE

:FROM_RESTART

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
IF /I [!_cmd!]==[FOLDER] (GOTO :FOLDER)
IF /I [!_cmd!]==[PS] (GOTO :POWERSHELL)
IF /I [!_cmd!]==[PWSH] (GOTO :POWERSHELL)
IF /I [!_cmd!]==[POWERSHELL] (GOTO :POWERSHELL)
IF /I [!_cmd!]==[SCRCPY] (GOTO :SCRCPY)
@REM #endregion





@REM #region MAIN
:MAIN
IF /I NOT [%1]==[DEV] (@CLS )
ECHO Hppsrc CMD ^| %cmd_VERSION% %cmd_ADMIN%%_temp%
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
ECHO    RESTART     Restart the current Hppsrc CMD session ^*^*
ECHO    SHUTDOWN    Shutdown the PC ^*
ECHO    CODE        Launch VS Code in isolated mode
ECHO    CMD         Open a new CMD window
ECHO    CLS         Clear screen and refresh Hppsrc CMD
ECHO    CALC        Open a simple CLI based calculator
ECHO    PY          Open a Python CLI ^(Args allowed^)
ECHO    ADMIN       Tries to restart as admin
ECHO    PS^/PWSH    Open a new Powershell window
ECHO.
ECHO ^*    Requires confirmation code
ECHO ^*^*   Doesn^'t unset any config
GOTO :END


:VERSION
ECHO Hppsrc CMD ^| Version %cmd_VERSION% ^(%cmd_BUILD%^)
GOTO :END


:EXIT
ECHO Close Hppsrc CMD
ECHO Please type "%cmd_STATIC_RANDOM%" to exit

SET /P "cmd_CONFIRM=> "

IF /I "%cmd_CONFIRM%"=="%cmd_STATIC_RANDOM%" (
    ECHO Closing Ventoy CMD...
    TIMEOUT /T 1 >nul
    GOTO :KILL_UNCONFIG
    GOTO :EXIT
) ELSE (
    ECHO Incorrect code. Type EXIT again to retry.
    GOTO :LOOP
)

GOTO :END


:RESTART
START /SEPARATE /REALTIME %~f0 RESTART
GOTO :KILL


:SHUTDOWN
ECHO Shutdown PC
ECHO Please type "%cmd_STATIC_RANDOM%" to exit

SET /P "cmd_CONFIRM=> "

IF /I "%cmd_CONFIRM%"=="%cmd_STATIC_RANDOM%" (
    ECHO Shutdown PC...
    GOTO :KILL_UNCONFIG
    shutdown /f /t 0 /s
) ELSE (
    ECHO Incorrect code. Type EXIT again to retry.
    GOTO :LOOP
)
GOTO :END


:CODE
ECHO VScode started...
START "" /SEPARATE /REALTIME code --extensions-dir "%cmd_TEMP_FOLDER%\vs-extension" --user-data-dir "%cmd_TEMP_FOLDER%\vsdata"
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


:FOLDER
ECHO Starting temp folder...
START %cmd_TEMP_FOLDER%
GOTO :END


:POWERSHELL
ECHO Starting Powershell...
REM Add 5/7 check
START powershell.exe
GOTO :END


:SCRCPY
ECHO Starting ScrCpy...
start "ScrCpy" /separate "%cmd_TEMP_FOLDER%\ScrCpyData\scrcpy.exe" -b 5M -m 900 --max-fps=40 --video-codec=h264 --no-audio-playbackreGOTO :END
@REM #endregion





@REM #region EXIT ACTIONS
:END
ECHO --------------------
ECHO.
GOTO :LOOP

:KILL_UNCONFIG
ECHO Starting unconfig...
ECHO Killing ShareX...
TASKKILL /IM ShareX.exe /F

ECHO Removing RegKeys...
reg delete "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /f
reg delete "HKEY_CLASSES_ROOT\*\shell\Open With Notepad" /f
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" /v "EnableMtcUvc" /f
reg delete "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme" /f

GOTO :EOF

:EXIT
ENDLOCAL
%cmd_POST_EXECUTION%
CLS && EXIT /B

:KILL
ENDLOCAL
EXIT

