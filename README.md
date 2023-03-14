# win-dotfiles
> Windows dotfiles with a strong linux flavor

### 1. Install scoop
``` powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser  # Optional: Needed to run a remote script the first time
Invoke-RestMethod get.scoop.sh | Invoke-Expression
scoop bucket add "extras"
scoop bucket add "versions"
scoop install "posh-git"
scoop install sudo gow
```
### 2. Install choco
``` powershell
$env:PATH += ";${env:ProgramData}\chocolatey\bin\"
Set-ExecutionPolicy Bypass
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
sudo choco feature enable -n allowGlobalConfirmation
sudo choco install 7zip sumatrapdf vscode visualstudio2019community rufus
```

> WIIIIIIIIIIIIP...
