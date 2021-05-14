
<#PSScriptInfo

.VERSION 1.0

.GUID 277a140d-e44a-4b96-b187-cfae0dcad220

.AUTHOR maciej

.COMPANYNAME warszawski.pro

.COPYRIGHT 2021

.TAGS

.LICENSEURI

.PROJECTURI https://github.com/maciejw/invoke-watch/

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>





<#

.DESCRIPTION
File watcher. Can invoke an action when files are changed

.EXAMPLE
Invoke-Watch.ps1 { Invoke-Pester }

#>
param (
  [Parameter(Mandatory, Position = 0)]
  [scriptblock]
  $Action,
  $Path = ".",
  $Filter = "*.ps1",
  [bool]
  $Recursive = $true,
  $WatchTimeout = 2000
)


try {

  $RecursiveString = ""
  if ($Recursive) {
    $RecursiveString = "\**"
  }
  $FullPath = Resolve-Path $Path

  & $Action

  $watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList $FullPath, $Filter -Property @{
    IncludeSubdirectories = $Recursive
    EnableRaisingEvents   = $false
    NotifyFilter          = 'FileName', 'LastWrite'
  }
  Write-Warning "Monitoring '$FullPath$RecursiveString\$Filter'"

  while ($true) {
    $result = $watcher.WaitForChanged('All', $WatchTimeout)
    if ($result.TimedOut) {
      continue
    }
    Write-Debug "Starting action..."
    $elapsed = Measure-Command -Expression { & $Action } | Select-Object TotalMilliseconds
    Write-Debug "Action elapsed '$($elapsed.TotalMilliseconds)ms'"
    Write-Warning "Monitoring '$FullPath$RecursiveString\$Filter'"

  }
}
finally {
  Write-Debug "Exiting..."
  $watcher.Dispose()
}
