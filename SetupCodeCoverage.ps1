$choices = '&Yes', '&No'
$question = "Do you want to install?"


if ($Host.UI.PromptForChoice("Install VSCode", $question, $choices, 1) -eq 0) {
  Install-Script Install-VSCode
  Install-VSCode.ps1 -BuildEdition "Stable-User" -AdditionalExtensions "ryanluker.vscode-coverage-gutters"
}
if ($Host.UI.PromptForChoice("Install Pester", $question, $choices, 1) -eq 0) {
  Install-Module Pester -MinimumVersion 5.2.0 -Scope CurrentUser
}

if ($Host.UI.PromptForChoice("Install Invoke-Test.ps1 and Invoke-Watch.ps1 to '$($PSGetPath.CurrentUserScripts)'", $question, $choices, 1) -eq 0) {
  Write-Host "Coping items..."
  "$PSScriptRoot\Invoke-Tests.ps1", "$PSScriptRoot\Invoke-Watch.ps1" | ForEach-Object { Copy-Item $PSItem $PSGetPath.CurrentUserScripts -Confirm }
}


mkdir $PWD\.vscode -ErrorAction SilentlyContinue
@'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run tests in current file with CC",
      "type": "PowerShell",
      "request": "launch",
      "script": "Invoker-Tests.ps1",
          "args": [
            "-Path", "'${file}'",
              "-Output", "${config:powershell.pester.debugOutputVerbosity}",
              "-CodeCoverage",
          ],
          "cwd": "${file}",
      }
  ]
}
'@| Set-Content -Path "$PWD\.vscode\launch.json" -Confirm:(Test-Path "$PWD\.vscode\launch.json")

@'
{
  // disable gutters to make breakpoints usable
  "coverage-gutters.showGutterCoverage": false,
  "coverage-gutters.showLineCoverage": true
}
'@| Set-Content -Path "$PWD\.vscode\settings.json" -Confirm:(Test-Path "$PWD\.vscode\settings.json")

@'
{
  "recommendations": ["ryanluker.vscode-coverage-gutters", "ms-vscode.powershell"]
}
'@| Set-Content -Path "$PWD\.vscode\extensions.json" -Confirm:(Test-Path "$PWD\.vscode\extensions.json")
