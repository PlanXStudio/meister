# install
- Cmd with Administrator
  ```sh
  winget install Microsoft.WindowsTerminal.Preview
  winget install Microsoft.PowerShell.Preview =s winget
  winget install JanDeDobbeleer.OhMyPosh -s winget
  winget install Git.Bit -s winget
  
  Install-Module -Name Terminal-Icons -Repository PSGallery
  install-module posh-git
  Install-Module -Name modern-unix-win
  Install-Module -Name PSFzf

  Install-Module -Name PSWindowsUpdate
  ```

# setting
> ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
  ```sh
  oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\quick-term.omp.json" | Invoke-Expression
  Import-Module -Name Terminal-Icons
  Import-Module -Name posh-git
  Import-Module -Name modern-unix-win

  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
  Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
  ```
