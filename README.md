# win-dotfiles
> Windows dotfiles with a strong linux flavor

### 1. Install newest powershell-core
``` powershell
winget install --id Microsoft.Powershell --source winget
"${env:ProgramFiles}/PowerShell/7/pwsh.exe" | Invoke-Expression
```
### 2. Install scoop
``` powershell
$env:PATH += ";${env:UserProfile}/scoop/shims"
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod get.scoop.sh | Invoke-Expression
scoop bucket add extras
scoop bucket add versions
scoop install sudo gow posh-git oh-my-posh
sudo pwsh
```
### 3. Install choco
``` powershell
$env:PATH += ";${env:ProgramData}/chocolatey/bin/"
Set-ExecutionPolicy Bypass
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
choco feature enable -n allowGlobalConfirmation
choco install 7zip sumatrapdf vscode # visualstudio2019community rufus
```
### 4. Extra configurations
``` powershell
# 7zip : Double-Click Simply Extract
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
New-Item -path "hkcr:\Applications\7zG.exe\shell\open\command" -value "`"${env:ProgramFiles}/7-Zip/7zG.exe`" x `"%1`" -o* -aou" -Force
# Disable telemetry
Set-Service DiagTrack -StartupType Disabled
New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -name "AllowTelemetry" -PropertyType DWORD -value 0 -Force
```



> WIIIIIIIIIIIIP...
