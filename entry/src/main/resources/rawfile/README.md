# Rawfile Assets Directory

This directory contains raw media assets for the MusicBox application.

## Directory Structure

```
rawfile/
├── music/          # Audio files (MP3, AAC, etc.)
│   ├── song1.mp3
│   ├── song2.mp3
│   └── song3.mp3
├── images/         # Album cover images
│   ├── cover1.png
│   ├── cover2.png
│   └── cover3.png
└── lyrics/         # LRC format lyrics files
    ├── song1.lrc
    ├── song2.lrc
    └── song3.lrc
```

## Audio Files (music/)

Due to file size limitations, the actual audio files are not included in this repository.
Place your audio files in this directory with the following naming convention:
- `song1.mp3` - First demo song
- `song2.mp3` - Second demo song
- `song3.mp3` - Third demo song

Supported formats: MP3, AAC, WAV, FLAC, OGG

## Cover Images (images/)

Album cover images should be:
- Square images (recommended 500x500 pixels or higher)
- PNG or JPEG format
- Named consistently with songs: `cover1.png`, `cover2.png`, etc.

## Lyrics Files (lyrics/)

LRC format lyrics files should follow the standard format:
```
[ti:Song Title]
[ar:Artist Name]
[al:Album Name]
[offset:0]
[00:00.00]First line of lyrics
[00:05.00]Second line of lyrics
...
```

Note: The application uses built-in demo lyrics for testing purposes.
