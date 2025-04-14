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

echo Python (!PyVer!) and pip installation has been completed.
exit /b 0
