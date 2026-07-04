#!/usr/bin/env bash
# =====================================================================
# extract-frames.sh  (macOS / Linux / Git-Bash)
# פירוק וידאו לרצף פריימים עבור אפקט ה-Image Sequence בגלילה.
# ---------------------------------------------------------------------
# דרישה: ffmpeg + ffprobe מותקנים.
# שימוש:
#   bash scripts/extract-frames.sh kitchen.mp4 kitchen
#   bash scripts/extract-frames.sh kitchen.mp4 kitchen 30
# הפלט: frames/<room>/frame-001.jpg ... frame-0NN.jpg
# =====================================================================
set -euo pipefail

VIDEO="${1:?usage: extract-frames.sh <video> <room> [count]}"
ROOM="${2:?usage: extract-frames.sh <video> <room> [count]}"
COUNT="${3:-30}"

OUT="frames/$ROOM"
mkdir -p "$OUT"

# משך הווידאו -> fps שייתן ~COUNT פריימים
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO")
FPS=$(awk "BEGIN{printf \"%.4f\", $COUNT/$DUR}")

# חיתוך לפורטרט 1080x1620 (2:3) + דגימה
ffmpeg -y -i "$VIDEO" \
  -vf "scale=1080:1620:force_original_aspect_ratio=increase,crop=1080:1620,fps=$FPS" \
  -q:v 3 "$OUT/frame-%03d.jpg"

MADE=$(ls "$OUT"/frame-*.jpg | wc -l | tr -d ' ')
echo ""
echo "✓ נוצרו $MADE פריימים ב-$OUT"
echo "  עדכן ב-index.html (CHAPTERS):  frames: sequence(\"$ROOM\", $MADE)"
