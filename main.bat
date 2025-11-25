@ECHO OFF
@REM Hppsrc CMD
SETLOCAL EnableDelayedExpansion
TITLE Hppsrc CMD %cmd_VERSION%
@SET "cmd_RESTART_FLAG="
@SET "cmd_CONFIG_FLAG="

:PARSE_ARGS
IF "%~1"=="" GOTO :END_PARSE_ARGS
IF /I "%~1"=="DEV" ( @ECHO ========== DEBUG MODE ENABLE ========== && ECHO ON && @SET "cmd_DEV_FLAG=1" )
IF /I "%~1"=="RESTART" ( SET "cmd_RESTART_FLAG= ^[RESTARTED^]" )
IF /I "%~1"=="SKIP_CONFIG" ( SET "cmd_SKIP_CONFIG_FLAG=1" )
SHIFT
GOTO :PARSE_ARGS
:END_PARSE_ARGS

@SET "cmd_VERSION=1.6.0" && @SET "cmd_BUILD=25112500"
@SET /A cmd_STATIC_RANDOM=(%RANDOM%%%(999-100+1))+999 && @SET "cmd_RUNTIME=%TIME%" && @SET "cmd_TEMP_FOLDER=%temp%\HppsrcCMD"
@SET "COMMANDS=help version exit restart shutdown code cmd cls calc py python admin folder powershell pwsh ps scrcpy random chrome config"
@SET "cmd_CHROME_SITES="
@SET "cmd_PS_PATH=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
IF EXIST "C:\Program Files\PowerShell\7\pwsh.exe" (
	SET "cmd_PS_PATH=C:\Program Files\PowerShell\7\pwsh.exe"
)
CD /d %~dp0

IF DEFINED cmd_SKIP_CONFIG_FLAG GOTO :FROM_RESTART

GOTO :PRECONFIG





@REM #region PRECONFIG
@REM Section for custom personalization on run actions
:PRECONFIG
ECHO Loading preconfig...
ECHO.
@SET "cmd_SHAREX_VERSION=18.0.1"
@SET "cmd_PYTHON_VERSION=3.13.9"
@SET "cmd_PYTHON_SHORT=313"
@SET "cmd_SCRCPY_VERSION=3.3.3"

MKDIR "%appdata%\Hppsrc\HppsrcCMD"
MKDIR "%cmd_TEMP_FOLDER%"

ECHO Checking user configuration...
IF EXIST "%appdata%\Hppsrc\HppsrcCMD\cmd_config.bat" (
	ECHO User configuration found, loading...
	ECHO.
	SET "cmd_CONFIG_FLAG= ^[CONFIG^]"
	CALL "%appdata%\Hppsrc\HppsrcCMD\cmd_config.bat"
) ELSE (
	ECHO No user configuration found, using default settings.
)

:COMMONS_CHECK

IF NOT EXIST "%appdata%\Hppsrc\HppsrcCMD" (

	ECHO Common programs folder not found, do you want to install common tools? ^[ShareX, Python, ScrCpy^] ^(Y/N^)
	ECHO This might take a while and up to 500MB of disk space.
	SET /P "cmd_INSTALL_PROGRAMS=>"
	ECHO.

	IF /I "!cmd_INSTALL_PROGRAMS!"=="y" (

		ECHO Installing common programs...

		ECHO Downloading ShareX !cmd_SHAREX_VERSION!...
		START "Downloading ShareX" /WAIT /REALTIME curl.exe -L -o "%cmd_TEMP_FOLDER%\sharex.zip" "https://github.com/ShareX/ShareX/releases/download/v!cmd_SHAREX_VERSION!/ShareX-!cmd_SHAREX_VERSION!-portable.zip"
		ECHO Extracting ShareX...
		START "Extracting ShareX" /WAIT /REALTIME "!cmd_PS_PATH!" -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%cmd_TEMP_FOLDER%\sharex.zip' -DestinationPath '%appdata%\Hppsrc\HppsrcCMD\ShareX' -Force"
		RENAME "%appdata%\Hppsrc\HppsrcCMD\ShareX\ShareX.exe" ShareX_portable.exe
		ECHO.

		ECHO Downloading Python !cmd_PYTHON_VERSION!...
		START "Downloading Python" /WAIT /REALTIME curl.exe -L -o "%cmd_TEMP_FOLDER%\python.zip" "https://www.python.org/ftp/python/!cmd_PYTHON_VERSION!/python-!cmd_PYTHON_VERSION!-embed-amd64.zip"
		ECHO Extracting Python...
		START "Extracting Python" /WAIT /REALTIME "!cmd_PS_PATH!" -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%cmd_TEMP_FOLDER%\python.zip' -DestinationPath '%appdata%\Hppsrc\HppsrcCMD\Python' -Force"
		ECHO Installing pip...
		ECHO import site >> "%appdata%\Hppsrc\HppsrcCMD\Python\python!cmd_PYTHON_SHORT!._pth"
		CURL -L -o "%appdata%\Hppsrc\HppsrcCMD\Python\get-pip.py" "https://bootstrap.pypa.io/get-pip.py" >nul 2>&1
		START "Installing pip" /WAIT /REALTIME "%appdata%\Hppsrc\HppsrcCMD\Python\python.exe" "%appdata%\Hppsrc\HppsrcCMD\Python\get-pip.py"
		ECHO.

		ECHO Downloading ScrCpy !cmd_SCRCPY_VERSION!...
		START "Downloading ScrCpy" /WAIT /REALTIME curl.exe -L -o "%cmd_TEMP_FOLDER%\scrcpy.zip" "https://github.com/Genymobile/scrcpy/releases/download/v!cmd_SCRCPY_VERSION!/scrcpy-win64-v!cmd_SCRCPY_VERSION!.zip"
		ECHO Extracting ScrCpy...
		START "Extracting ScrCpy" /WAIT /REALTIME "!cmd_PS_PATH!" -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%cmd_TEMP_FOLDER%\scrcpy.zip' -DestinationPath '%appdata%\Hppsrc\HppsrcCMD' -Force"

		MKDIR "%appdata%\Hppsrc\HppsrcCMD\ScrCpy"
		MOVE "%appdata%\Hppsrc\HppsrcCMD\scrcpy-win64-v!cmd_SCRCPY_VERSION!\*" "%appdata%\Hppsrc\HppsrcCMD\ScrCpy\"
		RMDIR "%appdata%\Hppsrc\HppsrcCMD\scrcpy-win64-v!cmd_SCRCPY_VERSION!"
		ECHO.

		ECHO Common Programs installed.

	)

) ELSE (

	ECHO Checking Common Programs...
	IF NOT EXIST "%appdata%\Hppsrc\HppsrcCMD\ShareX\ShareX_portable.exe" ( RMDIR "%appdata%\Hppsrc\HppsrcCMD" /Q /S && GOTO :COMMONS_CHECK)
	IF NOT EXIST "%appdata%\Hppsrc\HppsrcCMD\Python\Python.exe" ( RMDIR "%appdata%\Hppsrc\HppsrcCMD" /Q /S && GOTO :COMMONS_CHECK)
	IF NOT EXIST "%appdata%\Hppsrc\HppsrcCMD\ScrCpy\ScrCpy.exe" ( RMDIR "%appdata%\Hppsrc\HppsrcCMD" /Q /S && GOTO :COMMONS_CHECK)

)
ECHO.

ECHO Starting ShareX...
IF NOT EXIST "%appdata%\Hppsrc\HppsrcCMD\ShareX\ShareX_portable.exe" (
    ECHO ShareX not found. Please install it to use this feature.
) ELSE (
	TASKLIST /FI "IMAGENAME eq ShareX_portable.exe" | FIND /I "ShareX_portable.exe" >NUL || START "ShareX Portable" /MIN /REALTIME "%appdata%\Hppsrc\HppsrcCMD\ShareX\ShareX_portable.exe"
)
ECHO.

ECHO Creating autoclean...
ECHO.
ECHO RMDIR %cmd_TEMP_FOLDER% ^/Q ^/S > "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat"
ECHO DEL "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat" >> "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat"

ECHO Setting ES_ES Keyboard...
ECHO.
powershell.exe "Set-WinUserLanguageList (New-WinUserLanguageList es-ES) -Force"

IF /I [%1]==[RESTART] ( PAUSE )

ECHO Cheking admin...
ECHO.
net session >nul 2>&1
IF %ERRORLEVEL% == 0 (
    SET "cmd_ADMIN=[ADMIN]"
) else (
    GOTO :MAIN
)

ECHO Registry keys setup disabled.

@REM ECHO Adding reg keys...
@REM ECHO Copy as Path...
@REM reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /ve /d "Copy &as path" /f
@REM reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /v "Icon" /t REG_SZ /d "imageres.dll,-5302" /f
@REM reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /v "InvokeCommandOnSelection" /t REG_DWORD /d 1 /f
@REM reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /v "VerbHandler" /t REG_SZ /d "{f3d06e7c-1e45-4a26-847e-f9fcdee59be0}" /f
@REM reg add "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /v "VerbName" /t REG_SZ /d "copyaspath" /f

@REM ECHO Open with notepad...
@REM reg add "HKEY_CLASSES_ROOT\*\shell\Open With Notepad" /v "Icon" /t REG_SZ /d "C:\Windows\System32\notepad.exe, 2" /f
@REM reg add "HKEY_CLASSES_ROOT\*\shell\Open With Notepad\command" /ve /d "notepad.exe %1" /f

@REM ECHO Seconds on explorer...
@REM reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t REG_DWORD /d 1 /f

@REM ECHO Old volume applet...
@REM reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" /v "EnableMtcUvc" /t REG_DWORD /d 0 /f

@REM ECHO Theme toggler...
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme" /v "MUIVerb" /d "Set Windows theme" /f
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme" /v "Icon" /d "%%SystemRoot%%\System32\imageres.dll,-183" /f
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme" /v "SubCommands" /d "" /f

REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme\shell\Dark" /v "MUIVerb" /d "Enable Dark mode" /f
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme\shell\Dark\command" /ve /d "cmd /q /c \"taskkill /im explorer.exe /f && reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme REM /t REG_DWORD /d 0 /f && reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f && start explorer.exe\"" /f

REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme\shell\Light" /v "MUIVerb" /d "Enable Light mode" /f
REM reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme\shell\Light\command" /ve /d "cmd /q /c \"taskkill /im explorer.exe /f && reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 1 /f && reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 1 /f && start explorer.exe\"" /f

@REM ECHO Restarting Explorer...
@REM TASKKILL /im EXPLORER.EXE /F
@REM START EXPLORER.EXE

IF /I [%1]==[RESTART] ( PAUSE )

:FROM_RESTART

GOTO :MAIN
@REM #endregion





@REM #region INTERNAL
:COMMANDS
ECHO --------------------
IF /I [!_cmd!]==[HELP]       (GOTO :HELP)
IF /I [!_cmd!]==[VERSION]    (GOTO :VERSION)
IF /I [!_cmd!]==[EXIT]       (GOTO :EXIT)
IF /I [!_cmd!]==[RESTART]    (GOTO :RESTART)
IF /I [!_cmd!]==[SHUTDOWN]   (GOTO :SHUTDOWN)
IF /I [!_cmd!]==[CODE]       (GOTO :CODE)
IF /I [!_cmd!]==[CMD]        (GOTO :CMD)
IF /I [!_cmd!]==[CLS]        (GOTO :CLS)
IF /I [!_cmd!]==[CALC]       (GOTO :CALC)
IF /I [!_cmd!]==[PY]         (GOTO :PY)
IF /I [!_cmd!]==[PYTHON]     (GOTO :PY)
IF /I [!_cmd!]==[ADMIN]      (GOTO :ADMIN)
IF /I [!_cmd!]==[FOLDER]     (GOTO :FOLDER)
IF /I [!_cmd!]==[PS]         (GOTO :PS)
IF /I [!_cmd!]==[PWSH]       (GOTO :PS)
IF /I [!_cmd!]==[POWERSHELL] (GOTO :PS)
IF /I [!_cmd!]==[SCRCPY]     (GOTO :SCRCPY)
IF /I [!_cmd!]==[RANDOM]     (GOTO :RANDOM)
IF /I [!_cmd!]==[CHROME]     (GOTO :CHROME)
IF /I [!_cmd!]==[CONFIG]     (GOTO :CONFIG)
@REM #endregion





@REM #region MAIN
:MAIN
IF /I NOT [%1]==[DEV] (@CLS )
ECHO Hppsrc CMD ^| %cmd_VERSION%%cmd_ADMIN%%cmd_RESTART_FLAG%%cmd_CONFIG_FLAG%
ECHO Type HELP for help
ECHO ====================
:LOOP
SET "INPUT="
SET /P "INPUT=%time% | %CD%>"
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
ECHO This version feature: User config, common programs auto install, args parsing.
ECHO.
ECHO Commands:
ECHO    HELP        Show this help message.
ECHO    VERSION     Show Hppsrc CMD version.
ECHO    EXIT        Close Hppsrc CMD. ^*
ECHO    RESTART     Restart the current Hppsrc CMD session. ^*^*
ECHO    SHUTDOWN    Shutdown the PC. ^*
ECHO    CODE        Launch VS Code in isolated mode.
ECHO    CMD         Open a new CMD window.
ECHO    CLS         Clear screen and refresh Hppsrc CMD.
ECHO    CALC        Open a simple CLI based calculator.
ECHO    PY^/PYTHON   Open a Python CLI. ^(Args allowed^)
ECHO    ADMIN       Tries to restart as admin.
ECHO    FOLDER      Open the temp folder.
ECHO    PS^/PWSH     Open a new Powershell window.
ECHO    SCRCPY      Launch ScrCpy to mirror Android devices.
ECHO    RANDOM      Get a random number.
ECHO    CHROME      Launch Chrome in guest mode. ^(hardcoded path^)
ECHO    CONFIG      Show configuration info.
ECHO.
ECHO ^*    Requires confirmation code
ECHO ^*^*   Doesn^'t unset any config
GOTO :END

:CONFIG
ECHO Hppsrc CMD Configuration
ECHO.
ECHO Hppsrc uses a customization file format to edit some settings.
ECHO The configuration file should be located at %appdata%\Hppsrc\HppsrcCMD\cmd_config.bat
ECHO.
ECHO Current supported variables:
ECHO.
ECHO @SET "cmd_CHROME_SITES=https://example.com https://example2.com"
ECHO @SET "cmd_SHAREX_VERSION=X.X.X"
ECHO @SET "cmd_PYTHON_VERSION=X.X.X"
ECHO @SET "cmd_PYTHON_SHORT=XXX"
ECHO @SET "cmd_SCRCPY_VERSION=X.X.X"
ECHO.
ECHO This will override the default settings on next run.
ECHO You can add any other custom variable as needed, if the variable is extended it will work.
ECHO Also any other command can be added and it will be executed on start. SO BE CAREFUL.
ECHO.

IF EXIST "%appdata%\Hppsrc\HppsrcCMD\cmd_config.bat" (
	ECHO A user configuration was found.
	ECHO --------------------
	TYPE "%appdata%\Hppsrc\HppsrcCMD\cmd_config.bat"
	ECHO.
) ELSE (
	ECHO No user configuration found, you're using default settings.
)
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
START "" /SEPARATE /REALTIME "%~f0" RESTART
GOTO :KILL


:SHUTDOWN
ECHO Shutdown PC
ECHO Please type "%cmd_STATIC_RANDOM%" to exit

SET /P "cmd_CONFIRM=> "

IF /I "%cmd_CONFIRM%"=="%cmd_STATIC_RANDOM%" (
    ECHO Shutdown PC...
    SET "cmd_KILL_UNCONFIG=1"
    GOTO :KILL_UNCONFIG
) ELSE (
    ECHO Incorrect code. Type EXIT again to retry.
    GOTO :LOOP
)
GOTO :END


:CODE
IF NOT EXIST "C:\Program Files\Microsoft VS Code\Code.exe" (
	ECHO VS Code not found. Please install it to use this feature.
	GOTO :END
)
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
IF NOT EXIST "%appdata%\Hppsrc\HppsrcCMD\Python\python.exe" (
    ECHO Python not found. Please install it to use this feature.
	GOTO :END
)
ECHO Starting Python...
START "Python" "%appdata%\Hppsrc\HppsrcCMD\Python\python.exe" !_args!
GOTO :END


:ADMIN
IF DEFINED cmd_ADMIN (
    ECHO You're already admin.
) ELSE (
    ECHO Restarting as admin...
    powershell -command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1

    IF ERRORLEVEL 1 (
		ECHO Admin privileges denied.
		GOTO :END
	) ELSE (
		GOTO :KILL
	)

)
GOTO :END


:FOLDER
ECHO Starting temp folder...
START %cmd_TEMP_FOLDER%
GOTO :END


:PS
ECHO Starting Powershell...
IF EXIST "C:\Program Files\PowerShell\7\pwsh.exe" (
	ECHO Running with Powershell 7...
)
@REM IF !_args! NEQ "" (
@REM 	ECHO Running with arguments... !_args!
@REM 	START "Powershel" /SEPARATE /REALTIME "!cmd_PS_PATH!" -Command !_args!
@REM 	GOTO :END
@REM )
START "!cmd_PS_PATH!" /SEPARATE /REALTIME "!cmd_PS_PATH!"
GOTO :END


:SCRCPY
IF NOT EXIST "%appdata%\Hppsrc\HppsrcCMD\ScrCpy\scrcpy.exe" (
	ECHO ScrCpy not found. Please install it to use this feature.
	GOTO :END
)

ECHO ScrCpy options
ECHO.
ECHO 1. Default
ECHO 2. Low latency mode
ECHO 3. Balanced mode
ECHO 4. HQ mode
ECHO 5. OTG mode
ECHO 6. Custom mode
ECHO.
SET /P "cmd_SCRCPY_OPTION=Choose an option (1-5): "
SET "cmd_SCRCPY_ARGS="
IF "%cmd_SCRCPY_OPTION%"=="1" (
	SET "cmd_SCRCPY_ARGS="
) ELSE IF "%cmd_SCRCPY_OPTION%"=="2" (
	SET "cmd_SCRCPY_ARGS=-b 1M -m 720 --max-fps=144 --video-codec=h264 --no-audio-playback"
) ELSE IF "%cmd_SCRCPY_OPTION%"=="3" (
	SET "cmd_SCRCPY_ARGS=-b 5M -m 900 --max-fps=60 --video-codec=h264 --no-audio-playback"
) ELSE IF "%cmd_SCRCPY_OPTION%"=="4" (
	SET "cmd_SCRCPY_ARGS=-b 10M -m 1080 --max-fps=30 --video-codec=h265 --no-audio-playback"
) ELSE IF "%cmd_SCRCPY_OPTION%"=="5" (
	SET "cmd_SCRCPY_ARGS=--otg"
) ELSE IF "%cmd_SCRCPY_OPTION%"=="6" (
	ECHO Enter custom ScrCpy arguments:
	SET /P "cmd_SCRCPY_ARGS=> "
) ELSE (
	ECHO Invalid option. Using default settings.
	SET "cmd_SCRCPY_ARGS="
)

START "ScrCpy" /SEPARATE /REALTIME "%appdata%\Hppsrc\HppsrcCMD\ScrCpy\scrcpy.exe" -b 5M -m 900 --max-fps=40 --video-codec=h264 --no-audio-playback

GOTO :END


:RANDOM
ECHO Random number copied on your clipboard...
ECHO %RANDOM% | CLIP
GOTO :END


:CHROME
IF NOT EXIST "C:\Program Files\Google\Chrome\Application\chrome.exe" (
	ECHO Chrome not found. Please install it to use this feature.
	ECHO This script uses hardcoded path.
	GOTO :END
)
ECHO Starting Chrome...
START "" /REALTIME "C:\Program Files\Google\Chrome\Application\chrome.exe" --guest --user-data-dir="%cmd_TEMP_FOLDER%\ChromeGuest" --disk-cache-dir="%cmd_TEMP_FOLDER%\ChromeCache" --download.default_directory="%cmd_TEMP_FOLDER%\ChromeDownload" !cmd_CHROME_SITES!
@REM #endregion





@REM #region EXIT ACTIONS
:END
ECHO --------------------
ECHO.
GOTO :LOOP


:KILL_UNCONFIG
ECHO Starting unconfig...
ECHO Killing Common Programs...
TASKKILL /IM ShareX_portable.exe /F
TASKKILL /IM scrcpy.exe /F
TASKKILL /IM adb.exe /F


@REM ECHO Removing RegKeys...
@REM reg delete "HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath" /f
@REM reg delete "HKEY_CLASSES_ROOT\*\shell\Open With Notepad" /f
@REM reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /f
@REM reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" /v "EnableMtcUvc" /f
@REM reg delete "HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTheme" /f

IF DEFINED cmd_KILL_UNCONFIG (
	ECHO Shutdown PC...
    SHUTDOWN /f /t 0 /s
)


:EXIT
ENDLOCAL
@REM CLS && EXIT /B


:KILL
ENDLOCAL
EXIT

