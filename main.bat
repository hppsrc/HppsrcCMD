@ECHO OFF
@REM HppsrcCMD
SETLOCAL EnableDelayedExpansion
@SET "cmd_VERSION=1.7.0" && @SET "cmd_BUILD=25011401"
TITLE HppsrcCMD %cmd_VERSION%
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


@SET /A cmd_STATIC_RANDOM=(%RANDOM%%%(999-100+1))+999
@SET "cmd_RUNTIME=%TIME%"
@SET "cmd_TEMP_FOLDER=%temp%\HppsrcCMD"
@SET "cmd_PATH_FOLDER=%appdata%\Hppsrc\HppsrcCMD"

@SET "cmd_COMMANDS=help version exit restart shutdown code cmd cls calc py python admin folder temp powershell pwsh ps scrcpy random chrome uadng massgrave mas winutil install config ! raw"
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
@SET "cmd_PYTHON_VERSION=3.14.0"
@SET "cmd_PYTHON_SHORT=314"
@SET "cmd_SCRCPY_VERSION=3.3.4"
@SET "cmd_UADNG_VERSION=1.2.0"

MKDIR "%cmd_PATH_FOLDER%" > NUL 2>&1
MKDIR "%cmd_TEMP_FOLDER%" > NUL 2>&1

ECHO Checking user configuration...
IF EXIST "%cmd_PATH_FOLDER%\cmd_config.bat" (
	ECHO User configuration found, loading...
	ECHO.
	SET "cmd_CONFIG_FLAG= ^[CONFIG^]"
	CALL "%cmd_PATH_FOLDER%\cmd_config.bat"
) ELSE (
	ECHO No user configuration found, using default settings.
)
ECHO.

:COMMONS_CHECK

IF NOT EXIST "%cmd_PATH_FOLDER%\installed" (

	ECHO Common programs folder not found.
	ECHO Current missing tools:
	IF NOT EXIST "%cmd_PATH_FOLDER%\ShareX\ShareX_portable.exe" ( ECHO - ShareX !cmd_SHAREX_VERSION! ^(Screen capture tool^)^ )
	IF NOT EXIST "%cmd_PATH_FOLDER%\Python\Python.exe" ( ECHO - Python !cmd_PYTHON_VERSION! ^(Embedded version^)^ )
	IF NOT EXIST "%cmd_PATH_FOLDER%\ScrCpy\ScrCpy.exe" ( ECHO - ScrCpy !cmd_SCRCPY_VERSION! ^(Android mirroring tool^)^ )
	IF NOT EXIST "%cmd_PATH_FOLDER%\UADNG\UADNG.exe" ( ECHO - Universal Android Debloater Next Generation ^(Optional Android debloating tool^)^ )
	ECHO.
	ECHO This might take a while and up to 500MB of disk space.
	ECHO do you want to install common tools? ^(Y/N^)
	SET /P "cmd_INSTALL_PROGRAMS=>"
	ECHO.

	IF /I "!cmd_INSTALL_PROGRAMS!"=="y" (

		ECHO Installing common programs...

		DEL /Q /S "%cmd_PATH_FOLDER%\installed" > NUL 2>&1

		IF NOT EXIST "%cmd_PATH_FOLDER%\ShareX\ShareX_portable.exe" (
			ECHO Downloading ShareX !cmd_SHAREX_VERSION!...
			START "Downloading ShareX" /WAIT /REALTIME curl.exe -L -o "%cmd_TEMP_FOLDER%\sharex.zip" "https://github.com/ShareX/ShareX/releases/download/v!cmd_SHAREX_VERSION!/ShareX-!cmd_SHAREX_VERSION!-portable.zip"
			ECHO Extracting ShareX...
			START "Extracting ShareX" /WAIT /REALTIME "!cmd_PS_PATH!" -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%cmd_TEMP_FOLDER%\sharex.zip' -DestinationPath '%cmd_PATH_FOLDER%\ShareX' -Force"
			RENAME "%cmd_PATH_FOLDER%\ShareX\ShareX.exe" ShareX_portable.exe
			ECHO.
		)

		IF NOT EXIST "%cmd_PATH_FOLDER%\Python\Python.exe" (
			ECHO Downloading Python !cmd_PYTHON_VERSION!...
			START "Downloading Python" /WAIT /REALTIME curl.exe -L -o "%cmd_TEMP_FOLDER%\python.zip" "https://www.python.org/ftp/python/!cmd_PYTHON_VERSION!/python-!cmd_PYTHON_VERSION!-embed-amd64.zip"
			ECHO Extracting Python...
			START "Extracting Python" /WAIT /REALTIME "!cmd_PS_PATH!" -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%cmd_TEMP_FOLDER%\python.zip' -DestinationPath '%cmd_PATH_FOLDER%\Python' -Force"
			ECHO Installing pip...
			ECHO import site >> "%cmd_PATH_FOLDER%\Python\python!cmd_PYTHON_SHORT!._pth"
			CURL -L -o "%cmd_PATH_FOLDER%\Python\get-pip.py" "https://bootstrap.pypa.io/get-pip.py" >nul 2>&1
			START "Installing pip" /WAIT /REALTIME "%cmd_PATH_FOLDER%\Python\python.exe" "%cmd_PATH_FOLDER%\Python\get-pip.py"
			ECHO.
		)

		IF NOT EXIST "%cmd_PATH_FOLDER%\ScrCpy\ScrCpy.exe" (
			ECHO Downloading ScrCpy !cmd_SCRCPY_VERSION!...
			START "Downloading ScrCpy" /WAIT /REALTIME curl.exe -L -o "%cmd_TEMP_FOLDER%\scrcpy.zip" "https://github.com/Genymobile/scrcpy/releases/download/v!cmd_SCRCPY_VERSION!/scrcpy-win64-v!cmd_SCRCPY_VERSION!.zip"
			ECHO Extracting ScrCpy...
			START "Extracting ScrCpy" /WAIT /REALTIME "!cmd_PS_PATH!" -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%cmd_TEMP_FOLDER%\scrcpy.zip' -DestinationPath '%cmd_PATH_FOLDER%' -Force"

			MKDIR "%cmd_PATH_FOLDER%\ScrCpy"
			MOVE "%cmd_PATH_FOLDER%\scrcpy-win64-v!cmd_SCRCPY_VERSION!\*" "%cmd_PATH_FOLDER%\ScrCpy\"
			RMDIR "%cmd_PATH_FOLDER%\scrcpy-win64-v!cmd_SCRCPY_VERSION!"
			ECHO.

		)

		IF NOT EXIST "%cmd_PATH_FOLDER%\UADNG\UADNG.exe" (
			ECHO Downloading UADNG !cmd_UADNG_VERSION!...
			MKDIR "%cmd_PATH_FOLDER%\UADNG"
			START "Downloading UADNG" /WAIT /REALTIME curl.exe -L -o "%cmd_PATH_FOLDER%\UADNG\UADNG.exe" "https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/releases/download/v!cmd_UADNG_VERSION!/uad-ng-windows.exe"
			ECHO.
		)

		ECHO done > "%cmd_PATH_FOLDER%\installed"

		ECHO Common Programs installed.

	)

) ELSE (

	ECHO Checking Common Programs...
	IF NOT EXIST "%cmd_PATH_FOLDER%\ShareX\ShareX_portable.exe" ( DEL /Q /S "%cmd_PATH_FOLDER%\installed" && CLS && GOTO :COMMONS_CHECK)
	IF NOT EXIST "%cmd_PATH_FOLDER%\Python\Python.exe" ( DEL /Q /S "%cmd_PATH_FOLDER%\installed" && CLS && GOTO :COMMONS_CHECK)
	IF NOT EXIST "%cmd_PATH_FOLDER%\ScrCpy\ScrCpy.exe" ( DEL /Q /S "%cmd_PATH_FOLDER%\installed" && CLS && GOTO :COMMONS_CHECK)
	IF NOT EXIST "%cmd_PATH_FOLDER%\UADNG\UADNG.exe" ( DEL /Q /S "%cmd_PATH_FOLDER%\installed" && CLS && GOTO :COMMONS_CHECK)
	ECHO All Common Programs found.

)
ECHO.

ECHO Starting ShareX...
IF NOT EXIST "%cmd_PATH_FOLDER%\ShareX\ShareX_portable.exe" (
    ECHO ShareX not found. Please install it to use this feature.
) ELSE (
	"%cmd_PS_PATH%" -noprofile -command "if (-not (Get-Process | Where-Object { $_.Name -match 'sharex' })) { Start-Process '%cmd_PATH_FOLDER%\ShareX\ShareX_portable.exe' -WindowStyle Minimized }"
)
ECHO.

ECHO Creating autoclean...
ECHO.
ECHO RMDIR /Q /S %cmd_TEMP_FOLDER% > "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat"
ECHO DEL "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\autoclean.bat"

ECHO Cheking admin...
ECHO.
fsutil dirty query %systemdrive% >nul 2>&1
IF %ERRORLEVEL% == 0 (
    SET "cmd_ADMIN_FLAG= ^[ADMIN^]"
) else (
    GOTO :MAIN
)

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
IF /I [!_cmd!]==[TEMP]       (GOTO :TEMP)
IF /I [!_cmd!]==[PS]         (GOTO :PS)
IF /I [!_cmd!]==[PWSH]       (GOTO :PS)
IF /I [!_cmd!]==[POWERSHELL] (GOTO :PS)
IF /I [!_cmd!]==[SCRCPY]     (GOTO :SCRCPY)
IF /I [!_cmd!]==[RANDOM]     (GOTO :RANDOM)
IF /I [!_cmd!]==[CHROME]     (GOTO :CHROME)
IF /I [!_cmd!]==[UADNG]      (GOTO :UADNG)
IF /I [!_cmd!]==[MASSGRAVE]  (GOTO :MASSGRAVE)
IF /I [!_cmd!]==[MAS]        (GOTO :MASSGRAVE)
IF /I [!_cmd!]==[WINUTIL]    (GOTO :WINUTIL)
IF /I [!_cmd!]==[CONFIG]     (GOTO :CONFIG)
IF /I [!_cmd!]==[INSTALL]    (GOTO :INSTALL)
IF /I [!_cmd!]==[!]          (GOTO :RAW)
IF /I [!_cmd!]==[RAW]        (GOTO :RAW)
@REM #endregion





@REM #region MAIN
:MAIN
IF NOT DEFINED cmd_DEV_FLAG ( @CLS )
ECHO HppsrcCMD ^| %cmd_VERSION%%cmd_ADMIN_FLAG%%cmd_RESTART_FLAG%%cmd_CONFIG_FLAG%
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

ECHO !cmd_COMMANDS! | findstr /i "\<!_cmd!\>" >nul
IF NOT ERRORLEVEL 1 ( GOTO :COMMANDS ) ELSE ( !INPUT! )
GOTO :LOOP

@REM #endregion





@REM #region COMMANDS
:HELP
ECHO HppsrcCMD ^| Made by Hppsrc
ECHO Version: %cmd_VERSION% ^(%cmd_BUILD%^)
ECHO Running since %cmd_RUNTIME%
ECHO.
ECHO This version feature: More commands, stability
ECHO.
ECHO Commands:
ECHO    HELP        Show this help message.
ECHO    VERSION     Show HppsrcCMD version.
ECHO    EXIT        Close HppsrcCMD. ^*
ECHO    RESTART     Restart the current HppsrcCMD session. ^*^*
ECHO    SHUTDOWN    Shutdown the PC. ^*
ECHO    CODE        Launch VS Code in isolated mode.
ECHO    CMD         Open a new CMD window.
ECHO    CLS         Clear screen and refresh HppsrcCMD.
ECHO    CALC        Open a simple CLI based calculator.
ECHO    PY^/PYTHON   Open a Python CLI. ^(Args allowed^)
ECHO    ADMIN       Tries to restart as admin.
ECHO    FOLDER      Open the Hppsrc config folder.
ECHO    TEMP        Open the temp folder.
ECHO    PS^/PWSH     Open a new Powershell window.
ECHO    SCRCPY      Launch ScrCpy to mirror Android devices.
ECHO    RANDOM      Get a random number.
ECHO    CHROME      Launch Chrome in guest mode. ^(hardcoded path^)
ECHO    UADNG       Launch Universal Android Debloater Next Generation.
ECHO    MASSGRAVE   Launch MassGravel Microsoft Activation Scripts.
ECHO    WINUTIL     Launch Chris Titus Tech's Windows Utility.
ECHO    RAW^/"^!"     Execute raw command. ^(Use with caution^) ^(Args required^)
ECHO    CONFIG      Show configuration info.
ECHO.
ECHO ^*    Requires confirmation code
ECHO ^*^*   Doesn^'t unset any config
GOTO :END

:CONFIG
IF /I "!_args!"=="CREATE" (
    IF EXIST "%cmd_PATH_FOLDER%\cmd_config.bat" (
		ECHO User configuration file already exists at "%cmd_PATH_FOLDER%\cmd_config.bat"
	) ELSE (
		ECHO ^@^REM HppsrcCMD User Configuration File > "%cmd_PATH_FOLDER%\cmd_config.bat"
	)
	ECHO Opening configuration file...
	START /SEPARATE /REALTIME "notepad" "notepad.exe" "%cmd_PATH_FOLDER%\cmd_config.bat"
) ELSE (
	ECHO HppsrcCMD Configuration
	ECHO.
	ECHO Hppsrc uses a customization file format to edit some settings.
	ECHO The configuration file should be located at %cmd_PATH_FOLDER%\cmd_config.bat
	ECHO User "CONFIG CREATE" to create a base file.
	ECHO.
	ECHO Some example variables:
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

	IF EXIST "%cmd_PATH_FOLDER%\cmd_config.bat" (
		ECHO A user configuration was found.
		ECHO ====================
		TYPE "%cmd_PATH_FOLDER%\cmd_config.bat"
		ECHO ====================
		ECHO.
	) ELSE (
		ECHO No user configuration found, you're using default settings.
	)
)
GOTO :END


:VERSION
ECHO HppsrcCMD ^| Version %cmd_VERSION% ^(%cmd_BUILD%^)
GOTO :END


:EXIT
ECHO Close HppsrcCMD
ECHO Please type "%cmd_STATIC_RANDOM%" to exit

SET /P "cmd_CONFIRM=> "

IF /I "%cmd_CONFIRM%"=="%cmd_STATIC_RANDOM%" (
    ECHO Closing HppsrcCMD...
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
ECHO Simple Calculator v1.0
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
IF NOT EXIST "%cmd_PATH_FOLDER%\Python\python.exe" (
    ECHO Python not found. Please install it to use this feature.
	GOTO :END
)
ECHO Starting Python...
START "Python" "%cmd_PATH_FOLDER%\Python\python.exe" !_args!
GOTO :END


:ADMIN
IF DEFINED cmd_ADMIN_FLAG (
    ECHO You're already admin.
) ELSE (
    ECHO Restarting as admin...
    powershell -command "Start-Process -FilePath '%~f0' -Verb RunAs" >NUL 2>&1

    IF ERRORLEVEL 1 (
		ECHO Admin privileges denied.
	) ELSE (
		GOTO :RESTART
	)

)
GOTO :END


:FOLDER
ECHO Starting Hppsrc config folder...
START %cmd_PATH_FOLDER%
GOTO :END


:TEMP
ECHO Starting temp folder...
START %cmd_TEMP_FOLDER%
GOTO :END

:PS
ECHO Starting Powershell...
IF EXIST "C:\Program Files\PowerShell\7\pwsh.exe" (
	ECHO Running with Powershell 7...
)
START "!cmd_PS_PATH!" /SEPARATE /REALTIME "!cmd_PS_PATH!"
GOTO :END


:SCRCPY
IF NOT EXIST "%cmd_PATH_FOLDER%\ScrCpy\scrcpy.exe" (
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
ECHO x. Cancel
ECHO.
SET /P "cmd_SCRCPY_OPTION=Choose an option (1-6): "
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
	ECHO ScrCpy launch cancelled.
	GOTO :END
)

START "ScrCpy" /SEPARATE /REALTIME "%cmd_PATH_FOLDER%\ScrCpy\scrcpy.exe" !cmd_SCRCPY_ARGS!
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
GOTO :END

:UADNG
IF NOT EXIST "%cmd_PATH_FOLDER%\UADNG\UADNG.exe" (
	ECHO UADNG not found. Please install it to use this feature.
	GOTO :END
)
ECHO Starting UADNG...
START "UADNG" /SEPARATE /REALTIME "%cmd_PATH_FOLDER%\UADNG\UADNG.exe"
GOTO :END


:MASSGRAVE
ECHO Starting MassGrave MAS...
ECHO @echo off ^&^& powershell "irm https://get.activated.win | iex" ^&^& exit > "%cmd_TEMP_FOLDER%\MAS.cmd"
START "MAS" /SEPARATE /REALTIME "%cmd_TEMP_FOLDER%\MAS.cmd"
GOTO :END


:WINUTIL
ECHO Starting Chris Titus Tech's Windows Utility...
ECHO @echo off ^&^& powershell "irm https://christitus.com/win | iex" ^&^& exit > "%cmd_TEMP_FOLDER%\winutil.cmd"
START "WinUtil" /SEPARATE /REALTIME "%cmd_TEMP_FOLDER%\winutil.cmd"
GOTO :END


:INSTALL
IF EXIST "%SystemRoot%\System32\Hppsrc.bat" (
	ECHO HppsrcCMD is already installed.
) ELSE (
	ECHO Install HppsrcCMD into your system PATH
	IF DEFINED cmd_ADMIN_FLAG (
		IF DEFINED cmd_RESTART_FLAG (
			ECHO "RESTART" flag detected, please run the script with admin privileges.
		) ELSE (
			ECHO Installing...
			COPY "%~f0" "%SystemRoot%\System32\hppsrc.bat" /Y
			ECHO Installed HppsrcCMD into system PATH. You can now use "Hppsrc" command from any CMD window.
		)
	) ELSE (
		ECHO Missing admin privileges, don't use the "ADMIN", use explorer context "Run as administrator" option.
	)
)
GOTO :END


:RAW
!_args!
GOTO :END
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


IF DEFINED cmd_KILL_UNCONFIG (
	ECHO Shutdown PC...
    SHUTDOWN /f /t 0 /s
)


:EXIT
ENDLOCAL
CLS && EXIT /B


:KILL
ENDLOCAL
EXIT

