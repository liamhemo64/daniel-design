# =====================================================================
# extract-frames.ps1  (Windows / PowerShell)
# Extract a video into a numbered frame sequence for the scroll effect.
# ---------------------------------------------------------------------
# Requires ffmpeg + ffprobe (winget install Gyan.FFmpeg).
# Usage:
#   .\scripts\extract-frames.ps1 -Video "kitchen.mp4" -Room "kitchen"
#   .\scripts\extract-frames.ps1 -Video "kitchen.mp4" -Room "kitchen" -Count 30
# Output: frames/<room>/frame-001.jpg ... frame-0NN.jpg
# (ASCII only on purpose: Windows PowerShell 5.1 mis-parses non-ASCII .ps1.)
# =====================================================================
param(
  [Parameter(Mandatory = $true)][string]$Video,
  [Parameter(Mandatory = $true)][string]$Room,
  [int]$Count = 30
)
# Not 'Stop' globally: native ffmpeg writes progress to stderr, which
# Windows PowerShell 5.1 would turn into a terminating error under 'Stop'.
$ErrorActionPreference = "Continue"

# Find ffmpeg/ffprobe: PATH first, else the WinGet install folder (no terminal restart needed).
function Resolve-Tool($name) {
  $c = Get-Command $name -ErrorAction SilentlyContinue
  if ($c) { return $c.Source }
  $p = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "$name.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($p) { return $p.FullName }
  throw "$name not found. Install with: winget install Gyan.FFmpeg (then reopen the terminal)."
}
$ffmpeg  = Resolve-Tool "ffmpeg"
$ffprobe = Resolve-Tool "ffprobe"

$outDir = Join-Path "frames" $Room
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# Video duration -> fps that yields ~Count frames
$dur = & $ffprobe -v error -show_entries format=duration -of csv=p=0 $Video
if (-not $dur) { throw "ffprobe could not read the duration of $Video" }
$fps = [math]::Round([double]$Count / [double]$dur, 4)

# Crop to portrait 1080x1620 (2:3, full-screen on mobile) + sample.
# -loglevel error keeps ffmpeg quiet so its stderr doesn't trip PS 5.1.
& $ffmpeg -y -loglevel error -i $Video `
  -vf "scale=1080:1620:force_original_aspect_ratio=increase,crop=1080:1620,fps=$fps" `
  -q:v 3 `
  (Join-Path $outDir "frame-%03d.jpg")
if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed (exit code $LASTEXITCODE)" }

$made = (Get-ChildItem $outDir -Filter "frame-*.jpg").Count
Write-Host ""
Write-Host "Done: $made frames in $outDir"
Write-Host ("Update index.html (CHAPTERS):  frames: sequence(" + '"' + $Room + '"' + ", $made)")
