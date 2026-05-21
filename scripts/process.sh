#!/bin/bash
cd downloads

echo "MODE: $MODE"
echo "URL: $URL"

if [ "$MODE" = "720p" ]; then

    yt-dlp \
      -f "bestvideo[height<=720]+bestaudio/best[height<=720]" \
      --merge-output-format mp4 \
      "$URL" \
      -o "video.%(ext)s"

    INPUT=$(find . -type f | head -n 1)

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

    INPUT=$(find . -type f | head -n 1)

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

    INPUT=$(find . -type f | head -n 1)

    ffmpeg -i "$INPUT" \
      -b:a 192k \
      ../output/output_audio.mp3

fi

cd ../output

FILE=$(find . -type f | head -n 1)
SIZE=$(stat -c%s "$FILE")
LIMIT=$((95 * 1024 * 1024))

if [ $SIZE -gt $LIMIT ]; then

    echo "Splitting large file..."

    rar a -v95m split_archive.rar "$FILE"

    rm "$FILE"

fi