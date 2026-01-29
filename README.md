# MPV-Nvidia-VSR
Enhanced MPV media player configuration with auto-upscaling using Nvidia RTX Video Super Resolution (VSR). Includes a streamlined mpv.conf for high-quality playback and a Lua script for dynamic, delayed VSR application. Optimized for modern Nvidia GPUs on Windows.



 MPV-Nvidia-VSR

Enhanced configuration and scripting for the MPV media player, focusing on high-quality video playback with Nvidia RTX Video Super Resolution (VSR) for automatic upscaling. This setup is tailored for modern hardware like Ryzen 7 5800X3D and RTX 4070 Ti on Windows 11, but adaptable to similar Nvidia setups.

## Features
- **Streamlined mpv.conf**: Optimized for Vulkan/D3D11 rendering, advanced scalers (e.g., ewa_lanczossharp), debanding (toggleable), custom OSD, HDR support, and auto-profiles for specific content like WEB-DL anime.
- **Auto Nvidia VSR Lua Script**: Dynamically calculates and applies upscaling based on video vs. display resolution. Includes a 3-second delay for compatibility during file loading. Supports formats like nv12/yuv420p and avoids duplicate filters.
- **Performance-Focused**: Leverages hardware decoding (d3d11va) and GPU resources for smooth 4K+ playback.
- **Customizable**: Easy toggles for debanding, optional high-end shaders, and manual VSR control via keybinds.

## Requirements
- **MPV Version**: Latest stable (e.g., 0.37+ recommended for gpu-next VO).
- **Hardware**: Nvidia RTX 30/40-series GPU (for VSR support). Tested on RTX 4070 Ti.
- **Software**: Windows 10/11 with Nvidia drivers 551.23 or later (VSR enabled in Nvidia Control Panel under "RTX Video Enhancement").
- **Display**: High-resolution monitor (e.g., 1440p/4K) to benefit from upscaling.
- **Dependencies**: None beyond MPV; the Lua script uses built-in MPV APIs.

## Installation
1. **Install MPV**: Download from the [official MPV website](https://mpv.io/installation/) or use a package manager like Scoop/Chocolatey on Windows.
2. **Clone the Repo**:

   git clone https://github.com/yourusername/mpv-nvidia-vsr.git
   cd mpv-nvidia-vsr

3. **Copy Files**:
- Place `mpv.conf` in your MPV config directory (e.g., `%APPDATA%\mpv\mpv.conf` on Windows).
- Place `auto_nvidia_vsr.lua` in your MPV scripts directory (e.g., `%APPDATA%\mpv\scripts\`).
4. **Optional Shaders**: If using high-end shaders (commented in conf), download them (e.g., nnedi3, ArtCNN) and place in `~~/shaders/` (MPV home dir).

## Usage
- Launch MPV with a video file: `mpv video.mkv`.
- **VSR Auto-Apply**: The script triggers on file load/video params change, applying upscale after 3 seconds if needed (e.g., 1080p video on 4K display → scale=2).
- **Debanding Toggle**: Press `d` during playback for videos with banding artifacts.
- **Manual VSR Toggle** (Optional): Add to `input.conf` (e.g., `%APPDATA%\mpv\input.conf`):

  CTRL+v script-message toggle-vsr

Then update the Lua script with the toggle function (see script comments).
- **Testing**: Play a lower-res video and check the console (`~` key) for VSR application. Use `--msg-level=all=debug` for detailed logs.

## Configuration Details
### mpv.conf Highlights
- **GPU API**: Set to `d3d11` for VSR compatibility (switch to `vulkan` if not using VSR).
- **Hardware Decoding**: `d3d11va` (or `d3d11va-copy` for stability).
- **Scalers**: Luma: ewa_lanczossharp (up), mitchell (down); Chroma: ewa_lanczossharp.
- **Auto-Profile**: Enables debanding for specific WEB-DL anime sources.
- **Subtitles/Audio**: Prioritizes Japanese/English, custom fonts, and external audio loading.

Full config in [mpv.conf](./mpv.conf).

### Lua Script Highlights
- **Dynamic Scaling**: Calculates scale factor based on display/video dimensions.
- **Compatibility Delay**: 3-second timeout to avoid init issues.
- **Filters**: Applies only if upscale >1 and compatible format.

Full script in [auto_nvidia_vsr.lua](./auto_nvidia_vsr.lua).

## Troubleshooting
- **No Upscale**: Ensure VSR is enabled in Nvidia Control Panel. Check pixel format and resolutions.
- **Crashes/Errors**: Switch `hwdec` to `d3d11va-copy` or test without VSR (`gpu-api=vulkan`).
- **HDR Issues**: Add `target-colorspace-hint=yes` to conf if passthrough fails.
- **Performance**: On high-res content, disable shaders or reduce deband iterations.

## Contributing
Feel free to fork, submit PRs for improvements (e.g., more auto-profiles, macOS/Linux support), or open issues for bugs.

## Credits
- Based on MPV documentation and community configs.
- Nvidia VSR integration inspired by user scripts and forums.

Enjoy enhanced playback!

