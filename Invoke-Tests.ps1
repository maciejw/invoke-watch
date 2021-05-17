param (
  [String] $Path = ".",
  [String] $Output = "Normal",
  [Switch] $CodeCoverage,
  [Pester.DecimalOption]
  $CoveragePercentTarget = 90
)

$Configuration = [PesterConfiguration]::Default

$Configuration.Run.Path = $Path

$Configuration.Output.Verbosity = $Output

$Configuration.CodeCoverage.Enabled = [bool] $CodeCoverage

$Configuration.CodeCoverage.OutputFormat = "CoverageGutters"
$Configuration.CodeCoverage.Path = "$PWD"
$Configuration.CodeCoverage.OutputPath = "$PWD\coverage.xml"
$Configuration.CodeCoverage.CoveragePercentTarget = $CoveragePercentTarget

$Configuration.Debug.WriteDebugMessages = $true
$Configuration.Debug.WriteDebugMessagesFrom = "CodeCoverage"


$isDirectory = (Get-Item $Path).PSIsContainer
$isTestFile = $Path.EndsWith($Configuration.Run.TestExtension.Value)
if (-not $isDirectory -and -not $isTestFile) {
  & $Path
  return
}

Invoke-Pester -Configuration $Configuration
