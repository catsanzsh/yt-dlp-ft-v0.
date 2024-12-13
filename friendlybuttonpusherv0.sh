#!/bin/bash

# Title: [Flames YT 1.0]
# Description: This script prompts until all MP3 and MP4 videos are downloaded from a given YouTube channel.

echo "Welcome to [Flames YT 1.0]! This script will download MP3 and MP4 videos from a YouTube channel."

while true; do
    # Prompt the user for the YouTube channel URL
    read -p "Enter the YouTube channel URL or type 'exit' to quit: " channel_url

    # Check if user wants to exit
    if [[ "$channel_url" == "exit" ]]; then
        echo "Exiting script."
        break
    fi

    # Check if the URL is valid
    if [[ ! "$channel_url" =~ ^https://www\.youtube\.com/channel/ ]]; then
        echo "Invalid YouTube channel URL. Please try again."
        continue
    fi

    # Download all MP3 and MP4 videos from the given channel URL
    echo "Downloading MP3 and MP4 videos from $channel_url..."
    yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 "$channel_url"  # Download MP3
    yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 "$channel_url"  # Download MP4

    echo "Download complete for $channel_url!"
done
## [CREDIT TO YT-DLP] and YT 
