@echo off
setlocal enabledelayedexpansion

REM ================================================
REM Set working directories
REM ================================================

set "TempDir=C:\Temp"

if not exist "%TempDir%" mkdir "%TempDir%"

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

echo The font and PowerShell 7 installation has been completed.
exit /b 0
