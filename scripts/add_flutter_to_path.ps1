# PowerShell script to add Flutter to PATH
# Run this script as Administrator

Write-Host "🔍 Finding Flutter installation..." -ForegroundColor Cyan

# Common Flutter installation paths
$flutterPaths = @(
    "C:\src\flutter\bin",
    "C:\flutter\bin",
    "$env:LOCALAPPDATA\Flutter\bin",
    "$env:USERPROFILE\flutter\bin"
)

$flutterFound = $false
$flutterPath = ""

# Check each path
foreach ($path in $flutterPaths) {
    if (Test-Path "$path\flutter.exe") {
        $flutterPath = $path
        $flutterFound = $true
        Write-Host "✅ Found Flutter at: $path" -ForegroundColor Green
        break
    }
}

# If not found, search common drives
if (-not $flutterFound) {
    Write-Host "🔍 Searching for Flutter..." -ForegroundColor Yellow
    $searchResults = Get-ChildItem -Path C:\ -Filter "flutter.exe" -Recurse -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 1
    if ($searchResults) {
        $flutterPath = $searchResults.DirectoryName
        $flutterFound = $true
        Write-Host "✅ Found Flutter at: $flutterPath" -ForegroundColor Green
    }
}

if (-not $flutterFound) {
    Write-Host "" 
    Write-Host "❌ Flutter not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Download Flutter from: https://docs.flutter.dev/get-started/install/windows"
    Write-Host "2. Extract to: C:\src\flutter"
    Write-Host "3. Run this script again"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

# Check if already in PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -like "*$flutterPath*") {
    Write-Host "ℹ️  Flutter is already in PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If Flutter still doesn't work:" -ForegroundColor Cyan
    Write-Host "1. Close and reopen your terminal"
    Write-Host "2. Restart your computer"
    Write-Host "3. Or use full path: $flutterPath\flutter.exe"
    exit
}

# Add to PATH
Write-Host ""
Write-Host "Adding Flutter to PATH..." -ForegroundColor Cyan
try {
    $newPath = "$currentPath;$flutterPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✅ Flutter added to PATH!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Close and reopen your terminal"
    Write-Host "2. Run: flutter --version"
    Write-Host "3. Run: flutter doctor"
} catch {
    Write-Host "❌ Failed to add Flutter to PATH" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try running PowerShell as Administrator" -ForegroundColor Yellow
}

Read-Host "Press Enter to exit"

