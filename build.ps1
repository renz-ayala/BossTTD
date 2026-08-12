function Write-SlowHost {
    param([string]$Text, [ConsoleColor]$Color = "White", [int]$DelayMs = 100)
    Write-Host $Text -ForegroundColor $Color
    Start-Sleep -Milliseconds $DelayMs
}

Write-SlowHost "[1/4] Cleaning directories..." -Color Yellow
if (Test-Path -Path "target") { Remove-Item -Recurse -Force "target" }
if (Test-Path -Path "dist") { Remove-Item -Recurse -Force "dist" }

Write-SlowHost "[2/4] Compiling TypeScript to Lua with TSTL..." -Color Cyan
npx tstl

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: TSTL compilation failed." -ForegroundColor Red
    exit
}

Write-SlowHost "[3/4] Packaging Addon structure..." -Color Cyan
$targetDir = "target/BossTTD"
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$luaFile = Get-ChildItem -Path "dist" -Filter "BossTTD.lua" -Recurse | Select-Object -First 1

if ($null -eq $luaFile) {
    Write-Host "Error: File 'BossTTD.lua' was not found in 'dist' directory." -ForegroundColor Red
    exit
}

Copy-Item -Path $luaFile.FullName -Destination "$targetDir/BossTTD.lua" -Force
Copy-Item -Path "BossTTD.toc" -Destination "$targetDir/BossTTD.toc" -Force

Write-SlowHost "[4/4] Cleaning temporary builds..." -Color Yellow
Remove-Item -Recurse -Force "dist"

Write-Host "`nBuild completed successfully! Copy the './target/BossTTD' folder to your Interface/AddOns/ directory." -ForegroundColor Green