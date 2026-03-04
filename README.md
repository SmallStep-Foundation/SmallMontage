# SmallMontage

A non-linear video editor with support for **multiple video and audio tracks**, built with GNUstep and [SmallStepLib](../SmallStepLib), using [MLT (Media Lovin' Toolkit)](https://www.mltframework.org/) for playback and export.

## Features

- **Multiple tracks**: Add any number of video and audio tracks.
- **Clips**: Import media (MP4, MOV, AVI, MKV, WebM, MP3, WAV, etc.), place clips on the timeline with in/out points and position.
- **Timeline view**: Ruler, track rows, clip blocks, playhead, and clip selection.
- **Preview**: Play the timeline via MLT’s SDL2 consumer.
- **Export**: Render the project to MP4 (H.264 + AAC) using MLT’s avformat consumer.
- **Project file**: Save and open `.smallmontage` projects (property list XML).

## Dependencies

- **GNUstep** (base + gui)  
- **SmallStepLib**: build and install from `../SmallStepLib` first.  
- **MLT (Media Lovin' Toolkit)** and development headers:
  - Debian/Ubuntu: `sudo apt-get install libmlt-dev libmlt-7`
  - Or build from source: [MLT](https://www.mltframework.org/)

Optional for export: **FFmpeg** with libx264 and AAC (usually provided by MLT’s avformat module).

## Build

```bash
# 1. Build and install SmallStepLib
cd ../SmallStepLib && make && make install && cd -

# 2. Build SmallMontage
make
```

Run:

```bash
./SmallMontage.app/SmallMontage
# or
openapp ./SmallMontage.app
```

## Usage

- **New / Open / Save / Save As**: Standard file operations; project extension is `.smallmontage`.
- **Add Video Track / Add Audio Track**: Append a new track.
- **Import…**: Open one or more media files; they are appended to the first video or audio track (or default tracks are created).
- **Play**: Build the MLT graph from the project and start the SDL2 preview window.
- **Stop**: Stop preview.
- **Export…**: Render the timeline to an MP4 file (H.264 video, AAC audio).

Clips are placed sequentially on each track; use in/out and timeline position in the project model to control placement. The timeline view shows clips as blocks; click to select.

## Architecture

- **SmallStepLib**: App lifecycle (`SSHostApplication`, `SSAppDelegate`), menus (`SSMainMenu`), window style (`SSWindowStyle`), file dialogs (`SSFileDialog`).
- **Core**: `SMProject` (tracks, frame rate, dimensions), `SMTrack`, `SMClip`; `SMEngine` (MLT wrapper); `SMEngineBridge.c` (C/MLT: tractor, multitrack, playlists, blanks, sdl2/avformat consumers).
- **UI**: `SMMainWindow` (toolbar, scroll view), `SMTimelineView` (tracks, clips, ruler, playhead).

## License

Same as the SmallStep project; MLT is LGPL/GPL.
