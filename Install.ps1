# SCOOP
$env:PATH += ";${env:UserProfile}/scoop/shims"
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod get.scoop.sh | Invoke-Expression
## Add 'sources'
@("extras", "nerd-fonts") | ForEach-Object { scoop bucket add $_ }
## Cli - tools
scoop install sudo git pwsh gow
## Cli - modules
scoop install z posh-git oh-my-posh
## Apps - dev
scoop install 7zip vscode meld zeal powertoys
## Apps - sys
scoop install ditto quicklook eartrumpet everything everything-cli rufus
## Apps - text
scoop install sumatrapdf notion
## Apps - media
scoop install blender spotify handbrake obs-studio
## Apps - internet
scoop install min googlechrome microsoft-teams zoom whatsapp vncviewer teamviewer
## Fonts
sudo scoop install -g FiraCode FiraCode-NF-Mono

# CHOCO
$env:PATH += ";${env:ProgramData}/chocolatey/bin/"
Set-ExecutionPolicy Bypass
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
## Enable auto accept
choco feature enable -n allowGlobalConfirmation
## Apps - office
sudo choco install sparkmail clipgrab icloud office365business visualstudio2019community
## Apps - media
sudo choco install k-litecodecpack-standard itch steam razer-synapse-3

# WINGET installs: VulkanSDK, NDI-Tools, 3DViewer(store)
@("KhronosGroup.VulkanSDK", "NewTek.NDI5Tools", "9NBLGGH42THS") | ForEach-Object { winget install --id "$_" -e }

# MANUALLY : DOWNLOAD + INSTALL
function installFromUrl ($tag, $url) { $tmpFile = "${env:TEMP}\${tag}.exe"; Invoke-WebRequest -URI $url -OutFile $tmpFile; ./$tmpFile }
installFromUrl "tosibox" "https://downloads.tosibox.com/downloads/tbsetup.exe"
installFromUrl "qt" "https://download.qt.io/official_releases/online_installers/qt-unified-windows-x64-online.exe"

# REG Stuff
function addRegDword ($path, $key, $val) { sudo REG ADD $path /v $key /t REG_DWORD /d $val /f }
$IsLaptop = ($null -ne (Get-CimInstance -Class win32_battery))
$PowerSettingsPath = "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings"

## Disable telemetry
Set-Service DiagTrack -StartupType Disabled
addRegDword "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0

## Only on laptops
if ($IsLaptop) { 
    ### Enable 'Hybernate After'
    addRegDword "${PowerSettingsPath}\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\9d7815a6-7ee4-497e-8888-515a05f02364" "Attributes" 2
}

# UTILITIES
## Enable OCR for all available languages
Get-WindowsCapability -Online | Where-Object { $_.Name -Like 'Language.OCR*' } | ForEach-Object { $_ | Add-WindowsCapability -Online }
