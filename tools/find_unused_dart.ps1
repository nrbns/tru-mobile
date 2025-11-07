# Requires PowerShell 5+
param(
  [string]$Root = "lib",
  [switch]$Move
)

Write-Host "Scanning for unused Dart files under $Root ..."

$dartFiles = Get-ChildItem -Path $Root -Recurse -Filter *.dart | Where-Object { $_.FullName -notmatch "(\.g\.dart$|\.freezed\.dart$)" }

$unused = @()

foreach ($file in $dartFiles) {
  $path = $file.FullName.Replace("\\", "/")
  # skip main.dart always
  if ($path -match "/lib/main\.dart$") { continue }

  # naive reference search: imports and string references
  $name = [System.IO.Path]::GetFileName($path)
  $rel = $path.Substring($path.IndexOf("lib/"))

  $hits = Select-String -Path $Root/**/*.dart -Pattern ([regex]::Escape($rel)) -SimpleMatch -Quiet
  if (-not $hits) {
    $hits2 = Select-String -Path $Root/**/*.dart -Pattern ([regex]::Escape($name)) -SimpleMatch -Quiet
  } else { $hits2 = $true }

  if (-not $hits -and -not $hits2) {
    $unused += $rel
  }
}

$reportDir = "tools/reports"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
$reportPath = "$reportDir/unused_dart_$(Get-Date -Format yyyyMMdd_HHmmss).txt"
$unused | Set-Content -Path $reportPath
Write-Host "Report written to $reportPath"

if ($Move -and $unused.Count -gt 0) {
  $dest = "deprecated"
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  foreach ($rel in $unused) {
    $src = $rel
    $target = Join-Path $dest $rel.Substring(4) # strip leading lib/
    $targetDir = Split-Path $target -Parent
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Move-Item -Force $src $target
  }
  Write-Host "Moved $($unused.Count) files to $dest/ for review."
}

