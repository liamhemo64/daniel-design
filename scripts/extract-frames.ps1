# =====================================================================
# extract-frames.ps1  (Windows / PowerShell)
# פירוק וידאו לרצף פריימים עבור אפקט ה-Image Sequence בגלילה.
# ---------------------------------------------------------------------
# דרישה: ffmpeg + ffprobe מותקנים (winget install Gyan.FFmpeg)
# שימוש:
#   .\scripts\extract-frames.ps1 -Video "kitchen.mp4" -Room "kitchen"
#   .\scripts\extract-frames.ps1 -Video "kitchen.mp4" -Room "kitchen" -Count 30
# הפלט: frames/<room>/frame-001.jpg ... frame-0NN.jpg
# =====================================================================
param(
  [Parameter(Mandatory = $true)][string]$Video,
  [Parameter(Mandatory = $true)][string]$Room,
  [int]$Count = 30
)
$ErrorActionPreference = "Stop"

$outDir = Join-Path "frames" $Room
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# משך הווידאו בשניות -> חישוב fps שייתן ~Count פריימים
$dur = & ffprobe -v error -show_entries format=duration -of csv=p=0 $Video
$fps = [math]::Round([double]$Count / [double]$dur, 4)

# חיתוך לפורטרט 1080x1620 (יחס 2:3, מלא-מסך במובייל) + דגימה
& ffmpeg -y -i $Video `
  -vf "scale=1080:1620:force_original_aspect_ratio=increase,crop=1080:1620,fps=$fps" `
  -q:v 3 `
  (Join-Path $outDir "frame-%03d.jpg")

$made = (Get-ChildItem $outDir -Filter "frame-*.jpg").Count
Write-Host ""
Write-Host "✓ נוצרו $made פריימים ב-$outDir"
Write-Host "  עדכן ב-index.html (CHAPTERS):  frames: sequence(""$Room"", $made)"
