
## sudo is now a native feature of windows 11 24H2
## check how to activate it from this script
#### FIND REPLACES FOR:
#### --> scoop install z posh-git oh-my-posh
#### --> sudo scoop install -g FiraCode FiraCode-NF-Mono

######################################################
### WINGET Packages
######################################################

function install_winget($package) {
    winget install --disable-interactivity --accept-package-agreements --accept-source-agreements -e --id "$package"
}

# OS Utils
#---------------------
install_winget "Ditto.Ditto"                      # Ditto      : Clipboard History
install_winget "Win.QuickLook"                    # QuickLook  : macos-like Preview
install_winget "voidtools.Everything"             # Everything : The best file searcher
install_winget "voidtools.Everything.Cli"         # Everything : The best file searcher
install_winget "Flow-Launcher.Flow-Launcher"      # Laucher    : Spotlight/Alfred like
install_winget "7zip.7zip"                        # 7Zip
install_winget "Microsoft.PowerToys"              # PowerToys

# Media
#---------------------
install_winget "Rufus.Rufus"                      # To burn ISOs onto USBs
install_winget "CodecGuide.K-LiteCodecPack.Full"  # KLite
install_winget "9NBLGGH42THS"                     # 3D Previewer
install_winget "BlenderFoundation.Blender"        # Blender
install_winget "HandBrake.HandBrake"              # HandBrake : Video Coder
install_winget "OBSProject.OBSStudio"             # OBS Studio

# Communications
#---------------------
install_winget "XPFCS9QJBKTHVZ"                   # Spark Email
install_winget "Microsoft.Teams"                  # MS Teams
install_winget "TeamViewer.TeamViewer"            # TeamViewer

# Information
#---------------------
install_winget "SumatraPDF.SumatraPDF"            # Sumatra : PDF Reader
install_winget "Zen-Team.Zen-Browser.Optimized"   # Zen Browser
install_winget "Notion.Notion"                    # Notion
install_winget "Obsidian.Obsidian"                # Obsidian

# Dev
#---------------------
install_winget "Git.Git"                          # Git
install_winget "bmatzelle.Gow"                    # Linux Aliases
install_winget "Microsoft.PowerShell"             # Pwsh : Powershell 7
install_winget "KhronosGroup.VulkanSDK"           # Vulkan
install_winget "Microsoft.VisualStudioCode"       # VS Code
install_winget "Starship.Starship"                # Terminal prompt
install_winget "gsass1.NTop"                      # htop for Windows

# Personal
#---------------------
install_winget "Apple.iCloud"                     # iCloud
install_winget "Valve.Steam"                      # Steam
install_winget "RazerInc.RazerInstaller"          # Razer Lights


######################################################
### MANUALLY : DOWNLOAD + INSTALL
######################################################

function install_url ($tag, $url) {
    $tmp_file = "${env:TEMP}/${tag}.exe"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -URI $url -OutFile $tmp_file
    ./$tmp_file
}

install_url "clip" "https://download.clipgrab.org/clipgrab-3.9.11-dotinstaller.exe"
# install_url "tosibox" "https://downloads.tosibox.com/downloads/tbsetup.exe"
# install_url "qt" "https://download.qt.io/official_releases/online_installers/qt-unified-windows-x64-online.exe"


######################################################
### REG Stuff
######################################################

function add_reg_dword ($path, $key, $val) {
    sudo REG ADD $path /v $key /t REG_DWORD /d $val /f
}

$IsLaptop = ($null -ne (Get-CimInstance -Class win32_battery))
$PowerSettingsPath = "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings"

# Disable telemetry
Set-Service DiagTrack -StartupType Disabled
add_reg_dword "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0

# Only on laptops
if ($IsLaptop) {
    # Enable 'Hybernate After'
    $hibernate_key = "${PowerSettingsPath}\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\9d7815a6-7ee4-497e-8888-515a05f02364"
    add_reg_dword $hibernate_key "Attributes" 2
}


######################################################
### CAPABILITIES
######################################################

function install_capabilites($name) {
    $caps = Get-WindowsCapability -Online | Where-Object { $_.Name -Like "*$name*" }
    foreach ($cap in $caps) {
        $cap | Add-WindowsCapability -Online
    }
}

# Enable OCR for all available languages
install_capabilites "Language.OCR"


######################################################
### LINK
######################################################

function lns ([string]$to, [string]$from) {
    New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force
}

$prefix = ("", "OneDrive")[$true]
$docs_pwsh = "$home/$prefix/Documents/PowerShell"
lns "./profile.ps1" "$docs_pwsh/Microsoft.PowerShell_profile.ps1"
