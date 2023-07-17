# CLI Environment for Windows

## Check system
- Check the packages currently installed on your PC
  ```sh
  winget list Microsoft.WindowsTerminal
  winget list Microsoft.PowerShell
  ```
- Find a package in the package repository  
  ```sh
  winget search Microsoft.WindowsTerminal
  winget search Microsoft.PowerShell
  ```

## Install Tools
- PowerShell Run at **Administrator**
- Install Tools
  ```sh
  winget install Microsoft.WindowsTerminal.Preview
  winget install Microsoft.PowerShell.Preview
  winget install JanDeDobbeleer.OhMyPosh -s winget

  oh-my-posh font install
  ```
  ```sh
  Select font
  ...
  > JetBrainsMono
  ```

## Settings of Windows Terminal
- Run Windows Terminal (with PowrShell)
- go to the Settings UI window (`ctrl`+,)
  ```text
  Startup >
    Default profile > PowerShell
    Default terminal application > Windows Terminal Preview
  color schemes > 
    Tango Dark > Set as default
  Profiles > 
    Defaults > Additional settings
      Appearance >
        Font face > JetBrainMono Nerd Font
        Automatically adjust lightness of indistinguishable text > Only for colors in the color scheme
        Transparency > Background opacity > 90%
      Advanced >
        Profile termination behavior > Close when precess exits, fails, or crashes
  Save
  ```

## Settings of PowerShell
- Create powershell folder for User
  ```sh
  $env:PSModulePath -split ';'    

  $env:MyDocument = [environment]::getfolderpath("mydocuments")
  if (!(Test-Path -Path $env:MyDocument/PowerShell)) { New-Item -ItemType Directory -Path $env:MyDocument/PowerShell -Force }
  ```

- Install Modules
  ```sh
  Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
  
  Install-Module -Name Terminal-Icons -Repository PSGallery 
  Install-Module -Name modern-unix-win 
  Install-Module -Name PSFzf 
  ```  
  - Check toools into modern-unix-win
    ```sh
    Get-ModernUnixTools
    ```

- Update Modules
  ```sh
  Get-Module
  Update-Module -Force
  ```

- PowerShell Settins
  ```sh
  (Get-Command oh-my-posh).Source
  oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\quick-term.omp.json" | Invoke-Expression

  Get-PoshThemes

  $PROFILE | Get-Member -Type NoteProperty
  
  if (!(Test-Path -Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
  
  echo 'oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\quick-term.omp.json" | Invoke-Expression'  > $PROFILE
  echo 'Import-Module -Name Terminal-Icons'  >> $PROFILE
  echo 'Import-Module -Name modern-unix-win' >> $PROFILE  
  echo 'Import-Module -Name PSFzf' >> $PROFILE
  echo "" >> $PROFILE
  echo 'Set-PSReadLineOption -PredictionSource History' >> $PROFILE
  echo 'Set-PSReadLineOption -PredictionViewStyle ListView' >> $PROFILE
  echo 'Set-PSReadLineOption -EditMode Windows' >> $PROFILE
  echo 'Set-PSReadlineOption –HistorySavePath ~\History.txt' >> $PROFILE
  echo "" >> $PROFILE
  echo "Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'" >> $PROFILE
  echo "" >> $PROFILE
  echo 'function which ($command) {' >> $PROFILE
  echo '  Get-Command -Name $command -ErrorAction SilentlyContinue | ' >> $PROFILE
  echo '  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue' >> $PROFILE
  echo '}' >> $PROFILE
  ```

- Clear History
  ```sh
  clear-history
  rm (Get-PSReadlineOption).HistorySavePath
  ```
  
- Remove file or directory
  ```sh
  Remove-Item .git -Recurse -Force
  ```
## Reference
*WinGet*
> Documentation (https://learn.microsoft.com/en-us/windows/package-manager/winget/)  
> GitHub (https://github.com/microsoft/winget-cli)

*Window Terminal*
> Documentation (https://learn.microsoft.com/en-us/windows/terminal/install)  
> GitHub (https://github.com/microsoft/terminal)  

*PowerShell*
> Documentation (https://learn.microsoft.com/en-us/powershell/)  
> GitHub (https://github.com/PowerShell/PowerShell)  

*OhMyPosh*
> Documentation (https://ohmyposh.dev/docs/installation/windows)  
> GitHub (https://github.com/JanDeDobbeleer/oh-my-posh)  
> Themes (https://ohmyposh.dev/docs/themes)
  
*Terminal Icons*
> GitHub (https://github.com/devblackops/Terminal-Icons)

*Nerd Fonts*
> WebSite (https://www.nerdfonts.com/font-downloads)

*PSReadline*
> Documentation (https://learn.microsoft.com/en-us/powershell/module/psreadline/)
> GitHub (https://github.com/PowerShell/PSReadLine)

*Modern Unix*
> GitHub (https://github.com/ibraheemdev/modern-unix)

*PSFzf*
> GitHub (https://github.com/kelleyma49/PSFzf)
