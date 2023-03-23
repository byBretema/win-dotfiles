# Written with <3 by Daniel (@Camba3D)

# Package managers settings - Scoop
$env:psmodulepath += ";$env:userprofile\scoop\modules"
$env:PATH += ";${env:userprofile}/scoop/shims"
Get-ChildItem ${env:userprofile}/scoop/apps/ -ErrorAction SilentlyContinue | % { "$_\current" } | % { $env:PATH += ";$_/;$_/bin" }

# Package managers settings - Choco
function choco { "sudo `"$env:ChocolateyInstall/bin/choco.exe`" $args" | Invoke-Expression }
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

# Moudles
Import-Module z
Import-Module posh-git
Import-Module scoop-completion

# Settings - Pwsh
$env:POWERSHELL_TELEMETRY_OPTOUT = 1             # Avoid telemetry
Set-PSReadLineOption -HistoryNoDuplicates:$True  # Avoid duplicates

# Discarded custom aliases
@("md", "cls") | ForEach-Object { if (Test-Path alias:$_) { Remove-Item -Force alias:$_ } }

# Clean pwsh aliases to use gow ones -> https://github.com/bmatzelle/gow
@("awk", "basename", "bash", "bc", "bison", "bunzip2", "bzip2", "bzip2recover", "cat", "chgrp", "chmod", "chown", "chroot", "cksum", "clear", "cp", "csplit", "curl", "cut", "dc", "dd", "df", "diff", "diff3", "dirname", "dos2unix", "du", "egrep", "env", "expand", "expr", "factor", "fgrep", "flex", "fmt", "fold", "gawk", "gfind", "gow", "grep", "gsar", "gsort", "gzip", "head", "hostid", "hostname", "id", "indent", "install", "join", "jwhois", "less", "lesskey", "ln", "ls", "m4", "make", "md5sum", "mkdir", "mkfifo", "mknod", "mv", "nano", "ncftp", "nl", "od", "pageant", "paste", "patch", "pathchk", "plink", "pr", "printenv", "printf", "pscp", "psftp", "putty", "puttygen", "pwd", "rm", "rmdir", "scp", "sdiff", "sed", "seq", "sftp", "sha1sum", "shar", "sleep", "split", "ssh", "su", "sum", "sync", "tac", "tail", "tar", "tee", "test", "touch", "tr", "uname", "unexpand", "uniq", "unix2dos", "unlink", "unrar", "unshar", "uudecode", "uuencode", "vim", "wc", "wget", "whereis", "which", "whoami", "xargs", "yes", "zip") | ForEach-Object { if (Test-Path alias:$_) { Remove-Item -Force alias:$_ } }

# Add other paths to global PATH
$env:PATH += ";${env:SystemDrive}/vcpkg"
$env:PATH += ";${env:ProgramFiles}/Git/bin"
$env:PATH += ";${env:SystemDrive}/Qt/Tools/QtCreator/bin"

# THEMES : "atomic", "jandedobbeleer", "mojada", "montys", "takuya", "ys", "zash"
function Set-Theme([string]$theme) { 
	$themePath = "${env:LocalAppData}/Programs/oh-my-posh/themes/$theme.omp.json"
	oh-my-posh init pwsh --config $themePath | Invoke-Expression 
} 
Set-Theme "zash"

# Quick access folder a.k.a. CurrentActiveProject
$capFile = "$env:userprofile\.CurrentActiveProject.txt"
function Get-ActiveProject { try { return import-clixml -path $capFile } catch { return "." } }
Set-Alias gcap Get-ActiveProject
function Set-ActiveProject { $pwd.Path | export-clixml -path $capFile }
Set-Alias scap Set-ActiveProject
function Open-ActiveProject { Get-ActiveProject | Set-Location -ErrorAction Ignore; if (-not $?) { dev } }
Set-Alias cap Open-ActiveProject

# Git stuff that doesn't fit into .gitconfig
function gitit {
	git remote > $null; if (-not $?) { return; }
	$url = ((git remote -v) -Split "`t" -Split " ")[1]
	if ($url -like "*@*") { $url  = ($url -Split "@")[1].Replace(":", "/") }
	Start-Process "https://$url"
}

# Location management
Set-Alias pul Push-Location
Set-Alias pol Pop-Location
function md { New-Item -ItemType Directory $args[0]; Set-Location $args[0] } ## Create folder and enter on it
function treeup ([int]$jumps) { for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. } }

# Clear console
function clear { Clear-Host }
function k { Clear-Host; ll }

# Start process / apps / browser / ...
Set-Alias o Start-Process
function oo { if ($args) { explorer $args[0] } else { explorer (Get-Location).Path } }
function s { if ($args) { Start-Process "https://www.google.com/search?q=$($args -join '+')" } }
function tr ([string]$to, [string]$text) {
	try {
		$Uri = “https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($to)&dt=t&q=$text”
		$Response = Invoke-RestMethod -Uri $Uri -Method Get
		$Translation = $Response[0].SyncRoot | ForEach-Object { $_[0] }
		Write-Output $Translation
	}
 catch { "[ERR] - Bad `$to or `$text translating:`n`t'$text' to '$to'" }
}

# List dir content
function l { ls.exe -XALph $args }
function ll { ls.exe -XALphog $args }
function lll { ll "${args[0]}/*" }

# Soft Link 'alias'
function lns ([string]$to, [string]$from) { New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force } 

# Remove
function rmrf { Remove-Item -Force -Recurse $args }
#function trash {} # Send removed to RecycleBin, instead of hard-remove

# User(s)
function me { net user ${env:UserName} }

# System wide funcs or aliases
function aaa { sudo -plz }
function devices { mmc devmgmt.msc }
function installFromUrl ($tag, $url) { $tmpFile = "${env:TEMP}\${tag}.exe"; Invoke-WebRequest -URI $url -OutFile $tmpFile; ./$tmpFile }

# Kill
function ke { Stop-Process (Get-Process explorer).id }
function killp { 
	Get-Process "*$args*" -ErrorAction Ignore | ForEach-Object { Write-Output "$($_.Id)    $($_.ProcessName)" }; 
	$toKill = Read-Host "PID to kill"
	Stop-Process $toKill
}

# Shutdown machine shortcuts
function noff { shutdown /a }
function off { shutdown /hybrid /s /t $($args[0] * 60) }

# jobs
#function bg { Start-Process pwsh -NoNewWindow "-Command $args" }

# Langs
function py { python3  $args }
function py3 { python3 $args }

# Powershell
function editrc { code $PROFILE }
function reloadrc { . $PROFILE }
function pw { pwsh }
function spw { sudo pwsh }

# Network helpers
function netinfo {
	$pub = $(curl.exe -s icanhazip.com)
	$privW = $((Get-NetAdapter "Wi-Fi" | Get-NetIPAddress).IPAddress[1])
	Write-Host "IP (U/R):                 $pub / $privW"
	Write-Host "(8.8.8.8) time:       $((ping 8.8.8.8)[11])"
	Write-Host "(www.google.es) time: $((ping www.google.es)[11])"
	Write-Host "(www.google.com) time:$((ping www.google.com)[11])"
}

# BitLock
function bitLock { sudo manage-bde.exe -lock $args[0] }
function bitUnlock { sudo manage-bde.exe -unlock $args[0] -pw }

# QuickCoded linux-like tools
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

# Docker
#function x11 { xming -ac -multiwindow -clipboard }
#function whale { if ($args) { x11; docker run -v "$((Get-Location).path):/app" -e DISPLAY=$(display) -it $args } }
#function display { (Get-NetAdapter "vEthernet (DockerNAT)" | Get-NetIPAddress -AddressFamily "IPv4").IPAddress + ":0" 2> $null }

# AutoComplete - winget	
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)
	[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
	$Local:word = $wordToComplete.Replace('"', '""')
	$Local:ast = $commandAst.ToString().Replace('"', '""')
	winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}

# AutoComplete - z
Register-ArgumentCompleter -CommandName z -ScriptBlock {
	param($commandName, $parameterName, $wordToComplete) 
	Search-NavigationHistory $commandName -List | ForEach-Object { $_.Path } | ForEach-Object {
		New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_,
		$_,
		"ParameterValue",
		$_
	}
}

# Shortcuts to - Personal folders
function home { Set-Location "$env:userprofile" }
$tipiDir = "${env:UserProfile}/_tipi"  ##### That folder that u really wanna save if everything burns
function tipi { Set-Location "$tipiDir" }
$cDocsDir = "${env:UserProfile}/OneDrive/Documentos"
function cdocs { Set-Location $cDocsDir }
$docsDir = "${env:UserProfile}/_docs"
function docs { Set-Location $docsDir }

# Shortcuts to - Dev folders
$devDir = "${env:UserProfile}/_dev"
function dev { Set-Location "$devDir" }
function poet { Set-Location "$devDir/poet" }

# Shortcuts to - Job folders
$jobDir = "${env:UserProfile}/OneDrive - Skandal Technologies Oy/Documents"
function sk { Set-Location "$jobDir" }

# Home Page
if ($PWD.Path -eq ${env:UserProfile}) { cap }
