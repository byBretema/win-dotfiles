# Written with <3 by Daniel (@Camba3D)


#======================================
# IMPORTS & SETTINGS
#======================================
# Moudles
$env:psmodulepath += ";$env:userprofile\scoop\modules"
Import-Module z
Import-Module posh-git
Import-Module scoop-completion
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# Settings
$env:POWERSHELL_TELEMETRY_OPTOUT = 1             # Avoid telemetry
Set-PSReadLineOption -HistoryNoDuplicates:$True  # Avoid duplicates
# Discarded Aliases
@("md", "cls") | ForEach-Object { if (Test-Path alias:$_) { Remove-Item -Force alias:$_ } }

#======================================
# PATH
#======================================
$env:PATH += ";${env:SystemDrive}/vcpkg"
$env:PATH += ";${env:ProgramFiles}/Git/bin"
$env:PATH += ";${env:userprofile}/scoop/shims"
$env:PATH += ";${env:SystemDrive}/Qt/Tools/QtCreator/bin"


Get-ChildItem ${env:userprofile}/scoop/apps/ -ErrorAction SilentlyContinue | `
	ForEach-Object { "$_\current" } | `
	ForEach-Object { $env:PATH += ";$_/;$_/bin" }

#======================================
# THEMES
# Cool ones => "atomic", "jandedobbeleer", "mojada", "montys", "takuya", "ys", "zash"
#======================================
function Set-Theme([string]$theme) { 
	$themePath = "${env:LocalAppData}/Programs/oh-my-posh/themes/$theme.omp.json"
	oh-my-posh init pwsh --config $themePath | Invoke-Expression 
} 
Set-Theme "zash"

#======================================
# ACTIVE PROJECT
#======================================
$CAPPATH = "$env:userprofile\.CurrentActiveProject.txt"
function Get-ActiveProject {
	$cap = "."
	if (Test-Path $CAPPATH) { $cap = import-clixml -path $CAPPATH }
	if (Test-Path $cap) { $cap } else { "." }
}
Set-Alias gcap Get-ActiveProject
function Set-ActiveProject { $PWD.Path | export-clixml -path $CAPPATH }
Set-Alias scap Set-ActiveProject
function Open-ActiveProject { Get-ActiveProject | Set-Location }
Set-Alias cap Open-ActiveProject

#======================================
# GIT
#======================================
function gitit {
	if (-not (Test-Path "./.git")) { Write-Output "fatal: not a git repository (or any of the parent directories): .git"; return }
	$http = ((((git remote -v)[0] -Split " ")[0] -Split "`t")[1])
	$ssh = ($http -Split "@")[1].Replace(":", "/")
	Start-Process "https://$http" -ErrorAction "SilentlyContinue"
	if (-not $?) { $error.clear(); Start-Process "https://$ssh" -ErrorAction "Continue" }
}

#======================================
# NAVIGATION
#======================================
# Location
function md { New-Item -ItemType Directory $args[0]; Set-Location $args[0] }
function cd { if ($args) { Push-Location $args } }
function b { Pop-Location $args }
function treeup ([int]$jumps) { for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. } }
# Clear
function clear { Clear-Host }
function k { Clear-Host; Get-ChildItem $args }
# Open Explorer
function oo { if ($args) { explorer $args[0] } else { explorer (Get-Location).Path } }

#======================================
# ALIASES
#======================================
# start
Set-Alias o Start-Process
# ls
function l { ls -XALph $args }
function ll { ls -XALphog $args }
function lll { ll "${args[0]}/*" }
# soft-link
function lns([string]$to, [string]$from) { New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force } 
# remove
function rmrf { Remove-Item -Force -Recurse }
# user(s)
function me { net user ${env:UserName} }
# system
function devices { mmc devmgmt.msc }
# kill
function ke { Stop-Process (Get-Process explorer).id }
function killp { 
	Get-Process "*$args*" -ErrorAction Ignore | ForEach-Object { Write-Output "$($_.Id)    $($_.ProcessName)" }; 
	$toKill = Read-Host "PID to kill"
	Stop-Process $toKill
}
# shutdown
function noff { shutdown /a }
function off { shutdown /hybrid /s /t $($args[0] * 60) }
# jobs
#function bg { Start-Process pwsh -NoNewWindow "-Command $args" }
# langs
function py { python3  $args }
function py3 { python3 $args }
# sys
function choco { "sudo `"$env:ChocolateyInstall/bin/choco.exe`" $args" | Invoke-Expression }

#======================================
# HD
#======================================
function bitLock { sudo manage-bde.exe -lock $args[0] }
function bitUnlock { sudo manage-bde.exe -unlock $args[0] -pw }

#======================================
# NET
#======================================
# search on goolge
function s { if ($args) { Start-Process "https://www.google.com/search?q=$($args -join '+')" } }
# network info
function netinfo {
	$pub = $(curl.exe -s icanhazip.com)
	$privW = $((Get-NetAdapter "Wi-Fi" | Get-NetIPAddress).IPAddress[1])
	Write-Host "IP (U/R):                 $pub / $privW"
	Write-Host "(8.8.8.8) time:       $((ping 8.8.8.8)[11])"
	Write-Host "(www.google.es) time: $((ping www.google.es)[11])"
	Write-Host "(www.google.com) time:$((ping www.google.com)[11])"
}

#======================================
# WINDOWS Flavor
#======================================
function Clear-Bloatware {
	# Tasks
	@("usbceip", "microsoft", "consolidator", "silentcleanup", "dmclient", "scheduleddefrag", "office", "adobe") | ForEach-Object {
		$(Get-ScheduledTask -TaskName "*$_*") | ForEach-Object {
			Disable-ScheduledTask $_  2> $null
		}
	}
	# Services
	@("DiagTrack", "PcaSvc", "WSearch", "AJRouter", "Fax", "RemoteRegistry", "wisvc", "MapsBroker", "WpcMonSvc", "RetailDemo") | ForEach-Object {
		Set-Service $_ -StartupType Disabled
		Stop-Service $_
	}
	# Forbid telemetry
	New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -name "AllowTelemetry " -PropertyType DWORD -value 0 -Force
}

#======================================
# LINUX Flavor
#======================================
# gow aliases -> https://github.com/bmatzelle/gow
@("awk", "basename", "bash", "bc", "bison", "bunzip2", "bzip2", "bzip2recover", "cat", "chgrp", "chmod", "chown", "chroot", "cksum", "clear", "cp", "csplit", "curl", "cut", "dc", "dd", "df", "diff", "diff3", "dirname", "dos2unix", "du", "egrep", "env", "expand", "expr", "factor", "fgrep", "flex", "fmt", "fold", "gawk", "gfind", "gow", "grep", "gsar", "gsort", "gzip", "head", "hostid", "hostname", "id", "indent", "install", "join", "jwhois", "less", "lesskey", "ln", "ls", "m4", "make", "md5sum", "mkdir", "mkfifo", "mknod", "mv", "nano", "ncftp", "nl", "od", "pageant", "paste", "patch", "pathchk", "plink", "pr", "printenv", "printf", "pscp", "psftp", "putty", "puttygen", "pwd", "rm", "rmdir", "scp", "sdiff", "sed", "seq", "sftp", "sha1sum", "shar", "sleep", "split", "ssh", "su", "sum", "sync", "tac", "tail", "tar", "tee", "test", "touch", "tr", "uname", "unexpand", "uniq", "unix2dos", "unlink", "unrar", "unshar", "uudecode", "uuencode", "vim", "wc", "wget", "whereis", "which", "whoami", "xargs", "yes", "zip") | ForEach-Object { if (Test-Path alias:$_) { Remove-Item -Force alias:$_ } }
# top
function top_ {
	Clear-Host
	$saveY = [console]::CursorTop
	$saveX = [console]::CursorLeft
	while ($true) {
		Get-Process | Sort-Object -Descending CPU | Select-Object -First 30
		Start-Sleep -Seconds 2
		[console]::setcursorposition($saveX, $saveY + 3)
	}
}
# du
function du_ {
	Get-ChildItem $pwd | ForEach-Object {
		$name = $_
		Get-ChildItem -r $_.FullName | measure-object -property length -sum |
		Select-Object `
		@{ Name = "Name"; Expression = { $name } },
		@{ Name = "MB"; Expression = { "{ 0:N3 }" -f ($_.sum / 1MB) } },
		@{ Name = "Bytes"; Expression = { $_.sum } }
	} | Sort-Object "Bytes" -desc
}

#======================================
# AUTO-COMPLETEs
#======================================
# WinGet	
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)
	[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
	$Local:word = $wordToComplete.Replace('"', '""')
	$Local:ast = $commandAst.ToString().Replace('"', '""')
	winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}
# z
Register-ArgumentCompleter -CommandName z -ScriptBlock {
	param($commandName, $parameterName, $wordToComplete) 
	Search-NavigationHistory $commandName -List | ForEach-Object { $_.Path } | ForEach-Object {
		New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_,
		$_,
		"ParameterValue",
		$_
	}
}

#======================================
# DOCKER
#======================================
#function x11 { xming -ac -multiwindow -clipboard }
#function whale { if ($args) { x11; docker run -v "$((Get-Location).path):/app" -e DISPLAY=$(display) -it $args } }
#function display { (Get-NetAdapter "vEthernet (DockerNAT)" | Get-NetIPAddress -AddressFamily "IPv4").IPAddress + ":0" 2> $null }

#======================================
# ENV Shortcuts
#======================================
# My whole life - folder
$MWLPATH = "${env:UserProfile}/mwl"  # my whole life - folder
function mwl { Set-Location "$MWLPATH" }
function ho { Set-Location "$env:userprofile" }
# Dev path
$DEVPATH = "${env:UserProfile}/_DEV"
function dev { Set-Location "$DEVPATH" }
# Job path
$JOBPATH = "${env:UserProfile}/OneDrive - Skandal Technologies Oy/Documents"
function sk { Set-Location "$JOBPATH" }
function poet { Set-Location "$DEVPATH/poet" }
# Powershell
function editrc { code $PROFILE }
function reloadrc { . $PROFILE }
function pw { pwsh }
function spw { sudo pwsh }

#======================================
# HOME PAGE
#======================================

if ($PWD.Path -eq ${env:UserProfile}) { Set-Location "$DEVPATH" }
