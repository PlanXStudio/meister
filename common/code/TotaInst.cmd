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
REM Install Fonts
REM ================================================
set "FontsDir=%TempDir%\fonts"
set "UserFontDir=%LOCALAPPDATA%\Microsoft\Windows\Fonts"

mkdir "%FontsDir%"
pushd "%FontsDir%"

echo Downloading 0xProto fonts...
curl -L -o "0xProto.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/0xProto.zip" || exit /b 1
tar -xf "0xProto.zip" -C "%FontsDir%" && del /f /q "0xProto.zip"
powershell -Command "Get-ChildItem '%FontsDir%\*' | Where-Object { $_.Name -notlike '*0xProtoNerdFontMono-Regular.ttf' } | Remove-Item -Force"

echo Downloading Dalseo fonts...
curl -L -o "font_ttf2.zip" "https://dalseo.daegu.kr/cmsh/dalseo.daegu.kr/images/content/font_ttf2.zip" || exit /b 1
tar -xf "font_ttf2.zip" -C "%FontsDir%" && del /f /q "font_ttf2.zip"
powershell -Command "Get-ChildItem '%FontsDir%\Dalseo*' | Where-Object { $_.Name -notlike '*DalseoHealingMedium.ttf*' } | Remove-Item -Force"

echo Installing fonts...
powershell -Command ^
  "$shell = New-Object -ComObject Shell.Application; $fonts = $shell.Namespace(0x14); " ^
  "Get-ChildItem '%FontsDir%\*.ttf' | ForEach-Object { $fonts.CopyHere($_.FullName, 4); Start-Sleep -Milliseconds 500 }"

popd
rmdir /s /q "%FontsDir%"
echo Fonts installed successfully!
echo.

REM ================================================
REM Install PowerShell 7, OhMyPosh, Modules
REM ================================================
set "ThemesPath=%LocalAppData%\Programs\oh-my-posh\themes"
for /f "delims=" %%i in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"') do set "DocPath=%%i"
set "PowerShellRoot=%DocPath%\PowerShell"

echo Install OhMyPosh...
winget install JanDeDobbeleer.OhMyPosh -s winget

mkdir "%ThemesPath%" >nul 2>nul
curl -L -o "%ThemesPath%\tos-term.omp.json" "https://raw.githubusercontent.com/PlanXStudio/tos/main/win/oh-my-posh/tos-term.omp.json"

echo Install PowerShell 7...
set "DEST_DIR=%LOCALAPPDATA%\PackageManagement\ProviderAssemblies\nuget\2.8.5.208"
set "DEST_DLL=%DEST_DIR%\Microsoft.PackageManagement.NuGetProvider.dll"
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"
powershell -Command "Invoke-WebRequest 'https://onegetcdn.azureedge.net/providers/Microsoft.PackageManagement.NuGetProvider-2.8.5.208.dll' -OutFile '%DEST_DLL%'"

winget install Microsoft.PowerShell -s winget

start "" pwsh -NoProfile -ExecutionPolicy Bypass -Command "Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted; Install-Module 'Terminal-Icons','modern-unix-win','PSFzf' -Scope CurrentUser -Force -AllowClobber; if (-not (Test-Path $env:PowerShellRoot)) { New-Item -ItemType Directory -Path $env:PowerShellRoot | Out-Null }; Push-Location -Path $env:PowerShellRoot; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/PlanXStudio/tos/main/win/pwsh7/Microsoft.PowerShell_profile.ps1' -OutFile 'Microsoft.PowerShell_profile.ps1'; Pop-Location"

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
echo     "editor.mouseWheelZoom": true,
echo     "editor.fontFamily": "'0xProto Nerd Font Mono', DalseoHealing",
echo     "editor.minimap.enabled": false,
echo     "workbench.colorTheme": "One Dark Pro Darker",
echo     "workbench.iconTheme": "ayu",
echo     "workbench.startupEditor": "none",
echo     "security.workspace.trust.untrustedFiles": "open",
echo     "terminal.integrated.mouseWheelZoom": true,
echo     "terminal.integrated.fontSize": 14,
echo     "terminal.integrated.profiles.windows": "pwsh",
echo     "terminal.explorerKind": "external",
echo     "terminal.integrated.env.windows": {
echo         "PATH": "${execPath}\\..\\bin;${execPath}\\..\\data\\lib\\python;${execPath}\\..\\data\\lib\\python\\Scripts;${env:PATH}"
echo     },
echo     "python.defaultInterpreterPath": "${execPath}\\..\\data\\lib\\python\\python.exe",
echo     "window.commandCenter": false
echo }
) > "%SettingsJson%"

REM ================================================
REM Install Python and Pip
REM ================================================
pushd "%TempDir%"
set "PyDir=%VSCodeDir%\data\lib\python"

curl -s --compressed https://www.python.org/downloads/windows/ > latest.html
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "$html=Get-Content -Raw 'latest.html'; $pat='Latest Python 3 Release - Python\s+(\d+\.\d+\.\d+)'; if ($html -match $pat) {Write-Output $matches[1]}"`) do (
    set "PyVer=%%A"
)
if "!PyVer!"=="" (
    echo Python version not found.
    exit /b 1
)
del latest.html

set "DownloadURL=https://www.python.org/ftp/python/%PyVer%/python-%PyVer%-embed-amd64.zip"
curl -L "%DownloadURL%" -o python.zip || exit /b 1
mkdir "%PyDir%"
tar -xf python.zip -C "%PyDir%"
del python.zip

set "ShortVer=%PyVer:.=%"
set "ShortVer=%ShortVer:~0,3%"
ren "%PyDir%\python%ShortVer%._pth" "__python%ShortVer%._pth" >nul 2>nul

echo Installing pip...
curl -O https://bootstrap.pypa.io/get-pip.py
"%PyDir%\python.exe" get-pip.py --no-warn-script-location
echo @echo off>"%PyDir%\pip.cmd"
echo "%%~dp0\python.exe" -m pip %%*>>"%PyDir%\pip.cmd"
del /f /q "%PyDir%\Scripts\pip*.exe" >nul 2>nul
del get-pip.py

popd

echo Python !PyVer! and pip installed at %PyDir%
echo VSCode installed successfully!
exit /b 0
