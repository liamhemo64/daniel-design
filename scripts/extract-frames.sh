#!/usr/bin/env bash
# =====================================================================
# extract-frames.sh  (macOS / Linux / Git-Bash)
# Extract a video into a numbered frame sequence for the scroll effect.
# ---------------------------------------------------------------------
# Requires ffmpeg + ffprobe.
# Usage:
#   bash scripts/extract-frames.sh kitchen.mp4 kitchen
#   bash scripts/extract-frames.sh kitchen.mp4 kitchen 30
# Output: frames/<room>/frame-001.jpg ... frame-0NN.jpg
# =====================================================================
set -euo pipefail

VIDEO="${1:?usage: extract-frames.sh <video> <room> [count]}"
ROOM="${2:?usage: extract-frames.sh <video> <room> [count]}"
COUNT="${3:-30}"

OUT="frames/$ROOM"
mkdir -p "$OUT"

# Video duration -> fps that yields ~COUNT frames
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO")
FPS=$(awk "BEGIN{printf \"%.4f\", $COUNT/$DUR}")

# Crop to portrait 1080x1620 (2:3) + sample
ffmpeg -y -i "$VIDEO" \
  -vf "scale=1080:1620:force_original_aspect_ratio=increase,crop=1080:1620,fps=$FPS" \
  -q:v 3 "$OUT/frame-%03d.jpg"

MADE=$(ls "$OUT"/frame-*.jpg | wc -l | tr -d ' ')
echo ""
echo "Done: $MADE frames in $OUT"
echo "Update index.html (CHAPTERS):  frames: sequence(\"$ROOM\", $MADE)"
