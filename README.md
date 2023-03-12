# win-dotfiles
> Windows dotfiles with a strong linux flavor

### 1. Install scoop
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser  # Optional: Needed to run a remote script the first time
Invoke-RestMethod get.scoop.sh | Invoke-Expression
scoop install sudo gow
```
### 2. Install modules
* [Posh-Git](http://dahlbyk.github.io/posh-git/)
* [OhMyPosh](https://ohmyposh.dev/)  # Like [OhMyZSH](https://ohmyz.sh/) from Linux
```
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name "posh-git" -Force
Install-Module -Name "oh-my-posh" -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
```
### 3. Install choco
```
$env:PATH += ";${env:ProgramData}\chocolatey\bin\"
Set-ExecutionPolicy Bypass
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
choco feature enable -n allowGlobalConfirmation
choco install 7zip sumatrapdf vscode visualstudio2019community rufus
```

> WIIIIIIIIIIIIP...
