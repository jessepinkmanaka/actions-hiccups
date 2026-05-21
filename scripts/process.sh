#!/bin/bash

set -e

cd downloads || exit 1

echo "MODE: $MODE"
echo "URL: $URL"

if [ "$MODE" = "720p" ]; then
    yt-dlp \
      -f "bestvideo[height<=720]+bestaudio/best[height<=720]" \
      --merge-output-format mp4 \
      "$URL" \
      -o "video.%(ext)s"

    INPUT=$(find . -type f -name "*.mp4" | head -n 1)
    
    if [ -z "$INPUT" ]; then
        echo "Error: No video file found"
        exit 1
    fi

    ffmpeg -i "$INPUT" \
      -vcodec libx264 \
      -crf 28 \
      -preset fast \
      ../output/output_720p.mp4

elif [ "$MODE" = "480p" ]; then
    yt-dlp \
      -f "bestvideo[height<=480]+bestaudio/best[height<=480]" \
      --merge-output-format mp4 \
      "$URL" \
      -o "video.%(ext)s"

    INPUT=$(find . -type f -name "*.mp4" | head -n 1)
    
    if [ -z "$INPUT" ]; then
        echo "Error: No video file found"
        exit 1
    fi

    ffmpeg -i "$INPUT" \
      -vcodec libx264 \
      -crf 30 \
      -preset fast \
      ../output/output_480p.mp4

elif [ "$MODE" = "audio" ]; then
    yt-dlp \
      -x \
      --audio-format mp3 \
      "$URL" \
      -o "audio.%(ext)s"

    INPUT=$(find . -type f -name "*.mp3" -o -name "*.opus" -o -name "*.m4a" | head -n 1)
    
    if [ -z "$INPUT" ]; then
        echo "Error: No audio file found"
        exit 1
    fi

    ffmpeg -i "$INPUT" \
      -b:a 192k \
      ../output/output_audio.mp3

else
    echo "Invalid mode: $MODE"
    exit 1
fi

cd ../output || exit 1

FILE=$(find . -type f | head -n 1)
SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE" 2>/dev/null)
LIMIT=$((95 * 1024 * 1024))

if [ -n "$SIZE" ] && [ "$SIZE" -gt "$LIMIT" ]; then
    echo "Splitting large file..."
    rar a -v95m split_archive.rar "$FILE"
    rm "$FILE"
fi