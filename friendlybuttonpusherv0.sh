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

# Validate YouTube URL
validate_url() {
    local url=$1
    if [[ ! "$url" =~ ^https://(www\.)?youtube\.com/(channel/|c/|user/|@) ]]; then
        return 1
    fi
    return 0
}

# Create download directories
setup_directories() {
    local channel_name=$1
    mkdir -p "downloads/$channel_name/mp3"
    mkdir -p "downloads/$channel_name/mp4"
}

# Download function with error handling
download_content() {
    local url=$1
    local channel_name=$2
    local format=$3
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

# Main script
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

        # Validate URL
        if ! validate_url "$channel_url"; then
            echo "Error: Invalid YouTube channel URL. Please try again."
            continue
        fi

        # Get channel name from URL
        channel_name=$(yt-dlp --get-filename -o "%(channel)s" "$channel_url" 2>/dev/null)
        if [ -z "$channel_name" ]; then
            echo "Error: Could not fetch channel name."
            continue
        fi

        # Setup directories
        setup_directories "$channel_name"

        # Download content
        echo "Starting download for channel: $channel_name"
        
        if ! download_content "$channel_url" "$channel_name" "mp3"; then
            echo "Error: Failed to download MP3 content."
        fi

        if ! download_content "$channel_url" "$channel_name" "mp4"; then
            echo "Error: Failed to download MP4 content."
        fi

        echo "Download complete for $channel_name!"
        echo "Files saved in: downloads/$channel_name/"
        echo
    done
}

# Run main function
main

exit 0
