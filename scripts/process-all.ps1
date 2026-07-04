# =====================================================================
# process-all.ps1
# Extract every video in videos/ into a frame sequence under frames/.
# Expected names: videos/kitchen.*, videos/living.*, videos/bedroom.*, videos/bathroom.*
# Usage (from project root):
#   .\scripts\process-all.ps1
#   .\scripts\process-all.ps1 -Count 40
# (ASCII only: Windows PowerShell 5.1 mis-parses non-ASCII .ps1.)
# =====================================================================
param([int]$Count = 30)
$ErrorActionPreference = "Stop"

$rooms   = @("kitchen", "living", "bedroom", "bathroom")
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path   # scripts/
$root    = Split-Path -Parent $here                          # project root
$extract = Join-Path $here "extract-frames.ps1"

$lines = @()
foreach ($room in $rooms) {
  $video = $null
  foreach ($ext in @("mp4", "mov", "webm", "m4v")) {
    $cand = Join-Path $root "videos\$room.$ext"
    if (Test-Path $cand) { $video = $cand; break }
  }
  if (-not $video) { Write-Host "- skip '$room' (no videos\$room.*)"; continue }

  Write-Host "-> processing '$room' from $video ..."
  & $extract -Video $video -Room $room -Count $Count
  $made = (Get-ChildItem (Join-Path $root "frames\$room") -Filter "frame-*.jpg" -ErrorAction SilentlyContinue).Count
  $lines += ("  " + $room + " : frames: sequence(" + '"' + $room + '"' + ", $made)")
}

Write-Host ""
Write-Host "=================================================="
Write-Host "Update these lines in index.html (CHAPTERS):"
$lines | ForEach-Object { Write-Host $_ }
Write-Host "Then:  git add -A ; git commit -m 'real frame sequence' ; git push"
Write-Host "=================================================="
