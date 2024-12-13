#!/bin/bash

# YouTube Channel Downloader
# Dependencies: yt-dlp, ffmpeg
# Usage: ./youtube_channel_downloader.sh

# Check for dependencies
check_dependencies() {
    local deps=("yt-dlp" "ffmpeg")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: $dep is not installed. Please install it first."
            exit 1
        fi
    done
}

# Create download directories
setup_directories() {
    local channel_name="$1"
    mkdir -p "downloads/$channel_name/mp3"
    mkdir -p "downloads/$channel_name/mp4"
}

# Download content (mp3/mp4) with error handling
download_content() {
    local url="$1"
    local channel_name="$2"
    local format="$3"
    local output_dir="downloads/$channel_name/$format"

    echo "Downloading $format files from $url..."

    if [ "$format" = "mp3" ]; then
        yt-dlp -f "bestaudio" \
            --extract-audio \
            --audio-format mp3 \
            --audio-quality 0 \
            -o "$output_dir/%(title)s.%(ext)s" \
            --progress \
            --no-overwrites \
            --continue \
            "$url" || return 1
    else
        yt-dlp -f "bestvideo+bestaudio" \
            --merge-output-format mp4 \
            -o "$output_dir/%(title)s.%(ext)s" \
            --progress \
            --no-overwrites \
            --continue \
            "$url" || return 1
    fi
}

main() {
    # Check dependencies
    check_dependencies

    while true; do
        echo "YouTube Channel Downloader"
        echo "-------------------------"
        read -p "Enter the YouTube channel URL or type 'exit' to quit: " channel_url

        # Check for exit
        if [[ "$channel_url" == "exit" ]]; then
            echo "Exiting script."
            break
        fi

        # Basic sanity check: Ensure URL mentions youtube.com
        # This is a loose check, allowing yt-dlp to handle various formats.
        if [[ "$channel_url" != *"youtube.com"* ]]; then
            echo "Error: Invalid YouTube URL. Please enter a YouTube channel URL."
            continue
        fi

        # Get channel name from URL using yt-dlp
        channel_name=$(yt-dlp --get-filename -o "%(channel)s" "$channel_url" 2>/dev/null)
        if [ -z "$channel_name" ]; then
            echo "Error: Could not fetch channel name. Please verify the URL."
            continue
        fi

        # Setup directories
        setup_directories "$channel_name"

        echo "Starting download for channel: $channel_name"

        # Download MP3 content
        if ! download_content "$channel_url" "$channel_name" "mp3"; then
            echo "Error: Failed to download MP3 content."
        fi

        # Download MP4 content
        if ! download_content "$channel_url" "$channel_name" "mp4"; then
            echo "Error: Failed to download MP4 content."
        fi

        echo "Download complete for $channel_name!"
        echo "Files saved in: downloads/$channel_name/"
        echo
    done
}

main
