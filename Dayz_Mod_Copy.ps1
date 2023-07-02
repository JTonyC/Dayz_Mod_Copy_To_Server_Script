[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [String]$ModHTMLFile,
    [Parameter(Mandatory = $true)]
    [String]$UNCPathToServerRoot       #Enter the UNC Path to the Dayz Server Install
)
try {
    #Set-up logging Variables
    $logFileName = $MyInvocation.MyCommand.Name
    $loggingPath = "$PSScriptRoot\$logFileName.txt"
    $remotePath = "$UNCPathToServerRoot"
    $remotePathKeys = "$remotePath\keys"
    $modFileList = "$PSScriptRoot\$ModHTMLFile"
    $installPath = ''
    $smbmap = ''
    $LANServerIP = $UNCPathToServerRoot.split('\')[2]

    #Start Logging
    Start-Transcript -Path $loggingPath

    Write-Host ""
    Write-Host "Welcome to the Dayz Dedicated Server Mod Copy Script." -ForegroundColor Green
    Write-Host ""

    if((Test-Path -Path $UNCPathToServerRoot -ErrorAction:Ignore) -eq $false){
        Write-Host ("The UNC path entered could not be resolved. This might be due to permissions or an incorrect path entered." -f $UNCPathToServerRoot) -ForegroundColor Yellow
        Write-Host ("Please enter your Network Credentials. This will map the IPC$ share and test the path entered again.") -ForegroundColor Yellow
        $cred = Get-Credential
        $smbmap = New-SmbMapping -RemotePath "\\$LANServerIP\IPC$" -UserName $cred.UserName -Password $cred.GetNetworkCredential().password
        Start-Sleep 2
        if(($smbmap.Status) -eq 'OK' -and (Test-Path -Path $UNCPathToServerRoot)){
            Write-Host ("UNC Path {0} appears to be valid. Successful Test!" -f $UNCPathToServerRoot) -ForegroundColor Green
        }else{
            Write-Host ("Network Path specified {0} is not reachable. Please check and try again." -f $UNCPathToServerRoot) -ForegroundColor Red
            exit
        }
    }

    if(Test-Path -Path $modFileList){
        Write-Host ("The ModFile List provided {0} appears to be valid!" -f $modFileList) -ForegroundColor Green
    }else{
        Write-Host ("{0} is not valid. Please check the file exists and that there are no typo's in the script parameter and try again." -f $ModHTMLFile) -ForegroundColor Red
        exit
    }

    Write-host "Establishing if Steam is installed." -ForegroundColor Green
    #Establish if Steam is installed.
    if(Test-Path 'HKLM:\SOFTWARE\Valve\Steam'){
        $installPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam').InstallPath
    }

    if(Test-Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam'){
        $installPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam').InstallPath
    }

    if($installPath){
        Write-Host ("Found Steam install at $installPath. Locating Dayz Install..") -ForegroundColor Green
        if(Test-Path -Path $installPath\steamapps\appmanifest_221100.acf){
            Write-Host ("Found Dayz install (appmanifest_221100.acf present!). Checking for Steam Workshop Directory.." -f "$installPath\steamapps\appmanifest_221100.acf") -ForegroundColor Green
            Write-Host ""
        }else{
            Write-Host "Dayz install not Found!" -ForegroundColor Red
            exit
        }

        $DayzInstall = $installPath + "\steamapps\common\DayZ\!Workshop"

        $HTML = Invoke-WebRequest $modFileList -UseBasicParsing
        $site = New-Object -ComObject "HTMLFile"
        $site.IHTMLDocument2_write($HTML.RawContent)
        $dataArray = @($site.all.tags("td") | ForEach-Object innertext)
        $mods = @()
        $count = 0
        while($count -lt $dataArray.Count){
            $mods += "@" + $dataArray[$count];$count += 3
        }

        #Copy Mods
        ForEach($m in $mods){
            if(Test-Path -Path "$DayzInstall\$m"){
                Write-Host ("{0} is a valid path!" -f "$DayzInstall\$m")
                robocopy "$DayzInstall\$m\\" "$remotePath\$m\\" /r:60 /w:5 /MIR /MT:64
                if(Test-Path -Path "$DayzInstall\$m\keys\"){
                    Copy-Item -Path "$DayzInstall\$m\keys\*.bikey" -Destination $remotePathKeys -Force -Verbose
                }elseif(Test-Path -Path "$DayzInstall\$m\key\"){
                    Copy-Item -Path "$DayzInstall\$m\key\*.bikey" -Destination $remotePathKeys -Force -Verbose
                }elseif(Test-Path -Path "$DayzInstall\$m\*.bikey"){
                    Copy-Item -Path "$DayzInstall\$m\*.bikey" -Destination $remotePathKeys -Force -Verbose
                }
            }else{
                Write-Host ("{0} is not a valid path!" -f "$DayzInstall\$m") -ForegroundColor Red
            }
        }
    }else{
        Write-Host ("Steam is not installed. Exiting..")
        Exit;
    }

}
finally {
    if($smbmap){
        Write-Host "IPC$ share removed." -ForegroundColor Green
        Remove-SmbMapping -RemotePath "\\$LANServerIP\IPC$" -Confirm:$false
    }
    Stop-Transcript
}
