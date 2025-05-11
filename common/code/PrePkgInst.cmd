@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

REM ================================================
REM Set working directories
REM ================================================
set "TempDir=C:\Temp"
if not exist "%TempDir%" mkdir "%TempDir%"

REM ================================================
REM Check fonts by querying user/system font list
REM ================================================
echo Checking installed fonts...
for /f "tokens=1,2 delims=," %%A in ('powershell -NoProfile -Command ^
  "$fonts1 = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts';" ^
  "$fonts2 = Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts';" ^
  "$all = $fonts1.PSObject.Properties + $fonts2.PSObject.Properties;" ^
  "$names = $all | ForEach-Object { $_.Name };" ^
  "$hasNerd = $names | Where-Object { $_ -like '*0xProto Nerd Font Mono*' };" ^
  "$hasDalseo = $names | Where-Object { $_ -like '*달서힐링체*' };" ^
  "[string]::Join(',', [bool]($hasNerd), [bool]($hasDalseo))"') do (
    set "hasNerd=%%A"
    set "hasDalseo=%%B"
)

if /i "%hasNerd%"=="True" if /i "%hasDalseo%"=="True" (
  echo Fonts already installed. Skipping...
  goto :SKIP_FONTS
)

REM ================================================
REM Install Fonts (only if needed)
REM ================================================
echo Installing missing fonts...
set "FontsDir=%TempDir%\fonts"
set "UserFontDir=%LOCALAPPDATA%\Microsoft\Windows\Fonts"
mkdir "%FontsDir%" 2>nul
pushd "%FontsDir%"

if /i "%hasNerd%"=="False" (
    echo Downloading 0xProto fonts...
    curl -L -o "0xProto.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/0xProto.zip" || exit /b 1
    tar -xf "0xProto.zip" -C "%FontsDir%" && del /f /q "0xProto.zip"
    powershell -Command "Get-ChildItem '%FontsDir%\*' | Where-Object { $_.Name -notlike '*0xProtoNerdFontMono-Regular.ttf' } | Remove-Item -Force"
)

if /i "%hasDalseo%"=="False" (
    echo Downloading Dalseo fonts...
    curl -L -o "font_ttf2.zip" "https://dalseo.daegu.kr/cmsh/dalseo.daegu.kr/images/content/font_ttf2.zip" || exit /b 1
    tar -xf "font_ttf2.zip" -C "%FontsDir%" && del /f /q "font_ttf2.zip"
    powershell -Command "Get-ChildItem '%FontsDir%\Dalseo*' | Where-Object { $_.Name -notlike '*DalseoHealingMedium.ttf*' } | Remove-Item -Force"
)

echo Installing fonts...
powershell -Command ^
  "$shell = New-Object -ComObject Shell.Application; $fonts = $shell.Namespace(0x14); " ^
  "Get-ChildItem '%FontsDir%\*.ttf' | ForEach-Object { $fonts.CopyHere($_.FullName, 4); Start-Sleep -Milliseconds 500 }"

popd
rmdir /s /q "%FontsDir%"
echo Fonts installed successfully!
echo.

:SKIP_FONTS
echo.

REM ================================================
REM Install PowerShell 7 and modules
REM ================================================
set "ThemesPath=%LocalAppData%\Programs\oh-my-posh\themes"
for /f "delims=" %%i in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"') do set "DocPath=%%i"
set "PowerShellRoot=%DocPath%\PowerShell"

REM Check if PowerShell 7 is installed
where pwsh >nul 2>nul
if errorlevel 1 (
    echo Installing PowerShell 7...
    winget install Microsoft.PowerShell -s winget
) else (
    echo PowerShell 7 already installed. Skipping...
)

REM ================================================
REM Install OhMyPosh if not installed
REM ================================================
where oh-my-posh >nul 2>nul
if errorlevel 1 (
    echo Installing OhMyPosh...
    winget install JanDeDobbeleer.OhMyPosh -s winget
) else (
    echo OhMyPosh already installed. Skipping...
)

REM Install theme file if missing
if not exist "%ThemesPath%\tos-term.omp.json" (
    mkdir "%ThemesPath%" >nul 2>nul
    curl -L -o "%ThemesPath%\tos-term.omp.json" "https://raw.githubusercontent.com/PlanXStudio/tos/main/win/oh-my-posh/tos-term.omp.json"
)

REM Install required PowerShell modules only if not already installed
echo Configuring PowerShell 7 environment...

pwsh -NoProfile -ExecutionPolicy Bypass -Command ^
  "$mods = 'Terminal-Icons','modern-unix-win','PSFzf';" ^
  "$missing = @();" ^
  "foreach ($m in $mods) { if (-not (Get-Module -ListAvailable -Name $m)) { $missing += $m } };" ^
  "if ($missing.Count -gt 0) { " ^
  "  Write-Host 'Installing missing modules: ' ($missing -join ', ');" ^
  "  Install-Module $missing -Scope CurrentUser -Force -AllowClobber;" ^
  "  if (-not (Test-Path $env:PowerShellRoot)) { New-Item -ItemType Directory -Path $env:PowerShellRoot | Out-Null };" ^
  "  Push-Location -Path $env:PowerShellRoot;" ^
  "  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/PlanXStudio/tos/main/win/pwsh7/Microsoft.PowerShell_profile.ps1' -OutFile 'Microsoft.PowerShell_profile.ps1';" ^
  "  Pop-Location" ^
  "} else { Write-Host 'All required modules are already installed.' }"


echo.
echo The prepackage work has been completed.
exit /b 0
