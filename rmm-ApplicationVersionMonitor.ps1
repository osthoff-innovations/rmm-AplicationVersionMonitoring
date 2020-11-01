# Kai Osthoff <ko@osthoff.net>
# Rainy November Day, 2020
# Today listening to https://open.spotify.com/playlist/37i9dQZF1DWXDvpUgU6QYl?si=lXw-cBpOQk6P8pFlyyrccQ while coding!

# License
# https://choosealicense.com/licenses/gpl-3.0/


# Initally designed to whatch if DATEV Belegtransfer < 3.66 installed, but can be used to monitor
# every other Application and create tickets to do some tasks.
# Automated or deliver Information like a SOP to your colleagues.


# Parameters: Defaults can be overriden by datto RMM
$ApplicationDisplayName = "Belegtransfer"
$ApplicationVersion = 0
$VersionOperator = $false
$githubLink = "https://github.com/mspautomation/rmmMonitor_ApplicationVersion"
$mspSOP = "https://osthoff-innovations.eu.itglue.com/1903207/docs/1871505083138222"


# Are there any input parametrs from AEM?
if (Test-Path env:\ApplicationDisplayName) {
    $ApplicationDisplayName = $env:ApplicationDisplayName
}

if (Test-Path env:\mspSOP) {
    $mspSOP = $env:mspSOP
}

if (Test-Path env:\ApplicationVersion) {
    $ApplicationVersion = $env:ApplicationVersion
}

if (Test-Path env:\VersionOperator) {
    $VersionOperator = $env:VersionOperator
}

# Need in every Script to use as Datto RMM-Monitoring Component
$aem_alertStart = "<-Start Result->"
$aem_alertEnd   = "<-End Result->"
$aem_diagStart  = "<-Start Diagnostic->"
$aem_diagEnd    = "<-End Diagnostic->"
$alert          = $false

#################################
# Script to get Version of Application from https://myrandomthoughts.co.uk/2015/07/win32_product/

$regSearch = 'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
Function Win32_Product
{
    Param ([string]$serverName, [string]$displayName)
    Try
    {
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $serverName)
        $regKey = $reg.OpenSubKey($regSearch)
        If ($regKey) { [array]$keyVal = $regKey.GetSubKeyNames() }
    }
    Catch { Return $null }
    $found = $false
    If (($regKey) -and ($keyVal.Count -gt 0)) {
        ForEach ($app In $keyVal) {
            $appKey = $regKey.OpenSubKey($app).GetValue('DisplayName')
            If ($appKey -like ('*' + $displayName + '*')) {
                $found = $true
                [string]$verCheck = $regKey.OpenSubKey($app).GetValue('DisplayVersion')
                If (-not $verCheck) { $verCheck = '0.1' } }
        }
        If ($found -eq $false) {
            If ($regSearch -like '*Wow6432Node*') {
                $regSearch = $regSearch.Replace('Wow6432Node', '')
                $verCheck = Win32_Product -serverName $serverName -displayName $displayName
            }
            Else { $verCheck = $null } }
    }
    Else { $verCheck = $null }
    $regKey.Close()
    $reg.Close()
    Return $verCheck
}


$MonitorVersion = Win32_Product -servername $env:COMPUTERNAME -displayName $ApplicationDisplayName


if($MonitorVersion -lt $ApplicationVersion) {
    $alert = $true
} else {
    $alert = $false
}

#Output Diagnostics
#Write-Output 'Start of AEM Output:'
Write-Output $aem_alertStart
if ($alert -eq $true) {
    $aem_alert = "Version Mismatch $ApplicationDisplayName=" + $MonitorVersion
            
    }

 Else {

    $aem_alert = "$ApplicationDisplayName=" + $MonitorVersion
}
Write-Output $aem_alert
Write-Output $aem_alertEnd



if ($alert -eq $true) {
Write-Output $aem_diagStart

Write-Output ""
Write-Output "`n`n"
Write-Output "SOP: " + $mspSOP +"`n"
Write-Output "Support and more for that genius Component: " + $githubLink 


Write-Output $aem_diagEnd

}




if ($alert -eq $true) { 
    Exit 1
    } Else
    {
    Exit 0
    }


#
#



