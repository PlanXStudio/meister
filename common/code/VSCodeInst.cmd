@echo off
setlocal enabledelayedexpansion

REM ================================================
REM Set working directories
REM ================================================
set "VSCodeDir=C:\VSCode"
set "TempDir=C:\Temp"

if not exist "%TempDir%" mkdir "%TempDir%"
if exist "%VSCodeDir%" (
    echo The path %VSCodeDir% already exists.
    exit /b 1
)

REM ================================================
REM Install VSCode Portable
REM ================================================
set "ZipPath=%TempDir%\VSCode-win-x64.zip"
set "VersionFile=%VSCodeDir%\version.txt"
set "SettingsDir=%VSCodeDir%\data\user-data\User"
set "SettingsJson=%SettingsDir%\settings.json"
set "CodeCLI=%VSCodeDir%\bin\code.cmd"

echo Get latest VSCode version...
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "$r = [System.Net.HttpWebRequest]::Create('https://update.code.visualstudio.com/latest/win32-x64-archive/stable'); $r.Method = 'HEAD'; $r.AllowAutoRedirect = $false; $res = $r.GetResponse(); $loc = $res.Headers['Location']; $res.Close(); if ($loc -match 'VSCode-win32-x64-([\d\.]+)\.zip') { $matches[1] }"`) do (
    set "WebVersion=%%A"
)

if "!WebVersion!"=="" (
    echo Failed to retrieve the latest VSCode version.
    exit /b 1
)

echo Downloading VSCode version !WebVersion!...
curl -L -o "%ZipPath%" "https://update.code.visualstudio.com/%WebVersion%/win32-x64-archive/stable" || exit /b 1

taskkill /f /im code-tunnel.exe >nul 2>nul
mkdir "%VSCodeDir%"
tar -xf "%ZipPath%" -C "%VSCodeDir%"
del /f /q "%ZipPath%"
echo !WebVersion! > "%VersionFile%"
mkdir "%SettingsDir%"

echo Installing extensions...
for %%E in (
    "ms-vscode-remote.remote-ssh"
    "ms-python.python"
    "ms-toolsai.jupyter"
    "KevinRose.vsc-python-indent"
    "GitHub.copilot"
    "usernamehw.errorlens"
    "Gerrnperl.outline-map"
    "zhuangtongfa.material-theme"
    "teabyii.ayu"
) do (
    call "%CodeCLI%" --install-extension %%~E --force --force-node-api-uncaught-exceptions-policy=true
)

echo Writing VSCode settings...
(
echo {
echo     "files.autoSave": "onFocusChange",
echo     "files.autoSaveDelay": 500,
echo     "files.exclude": {
echo       "**/largeFolder": true,    
echo       "**/__pycache__": true,
echo       "**/.venv": true
echo     },
echo     "editor.mouseWheelZoom": true,
echo     "editor.fontFamily": "'0xProto Nerd Font Mono', DalseoHealing, Consolas, 'Courier New', monospace",
echo     "editor.minimap.enabled": false,
echo     "editor.renderWhitespace": "boundary",
echo     "editor.cursorSmoothCaretAnimation": "on",
echo     "editor.smoothScrolling": true,
echo     "workbench.colorTheme": "One Dark Pro Darker",
echo     "workbench.iconTheme": "ayu",
echo     "workbench.startupEditor": "none",
echo     "security.workspace.trust.untrustedFiles": "newWindow",
echo     "window.commandCenter": false,
echo     "terminal.integrated.mouseWheelZoom": true,
echo     "terminal.integrated.fontSize": 14,
echo     "terminal.integrated.defaultProfile.windows": "pwsh",
echo     "terminal.explorerKind": "integrated",
echo     "terminal.integrated.env.windows": {
echo         "PATH": "${execPath}\\..\\bin;${execPath}\\..\\data\\lib\\python;${execPath}\\..\\data\\lib\\python\\Scripts;${env:PATH}"
echo     },
echo     "python.defaultInterpreterPath": "${execPath}\\..\\data\\lib\\python\\python.exe",
echo     "python.createEnvironment.trigger": "off",
echo     "explorer.confirmDelete": false,
echo     "explorer.confirmPasteNative": false,
echo }
) > "%SettingsJson%"

echo VSCode installation has been completed.
exit /b 0
